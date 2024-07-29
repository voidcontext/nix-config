(ns pgm_symlink
  (:require [babashka.fs :as fs]
            [babashka.cli :as cli]
            [babashka.process :refer [shell]]
            [cheshire.core :as json]
            [clj-yaml.core :as yaml]
            [clojure.string :as str]))

;; Hugo utils
(defn read-frontmatter [file]
  (let [lines (fs/read-all-lines file)]
    (if (= "---" (first lines))
      (let
       [yaml-lines (take-while #(not (= % "---")) (rest lines))]
        (yaml/parse-string (str/join "\n" yaml-lines)))
      nil)))

(defn get-images [yaml]
  (cond-> []
    (contains? yaml :featured_image) (conj (:featured_image yaml))
    (contains? yaml :resources) (concat (map #(:src %) (:resources yaml)))))

;; Exif utils

(def lens-nisi {:LensModel "NiSi 9mm f/2.8 ASPH"
                :FocalLength35efl "9mm (35 mm equivalent: 14.0 mm)"
                :Aperture "?"})

(defn is-manual-lens [exif]
  (= (:LensSpec exif) "0mm f/0 MF"))

(defn is-wide-angle [exif]
  (= (:FocalLength exif) "13.0 mm"))

(defn patch-exif [exif]
  (if (and (is-manual-lens exif) (is-wide-angle exif))
    (merge exif lens-nisi)
    exif))

(defn template-social
  [exif]
  (let [lines [(str "📷 " (:Model exif))
               (str "🔭 " (:LensModel exif))
               (str "📏 " (:FocalLength35efl exif))
               (str "🔅  " (:ShutterSpeed exif)  "s, f/" (:Aperture exif) ", ISO " (:ISO exif))]]
    (str/join "\n" lines)))

(defn load-exif [file]
  (-> (shell {:out :string} (str "exiftool -json \"" file "\""))
      :out
      (json/parse-string true)
      (first)
      (patch-exif)))
;; Utils

(defn write-front-matter [file yaml]
  (let [yaml-str (yaml/generate-string yaml :dumper-options {:flow-style :block})]
    (fs/write-bytes file (.getBytes (str "---\n" yaml-str "\n---\n")))))

;; Commands

(defn copy-content []
  (let [files (fs/glob "content" "**.md")]
    (doseq [f files]
      (let [front-matter (read-frontmatter f)]
        (doseq [img  (get-images front-matter)]
          (let [src (fs/path "/Users/gaborpihaj/Pictures/Photos/exported/public" img)
                dst (fs/path (fs/parent f) img)]
            (shell (str "cp " src " " dst))))))))

(defn- clean-content []
  (shell "find content -name \"*.jpg\" -exec rm {} ;"))

(defn- wrap-info [info]
  (str "<!--photo-info-->\n<hr style=\"border-width: 1px\"><p style=\"font-size: 0.8em\">" info "</p>"))

(defn patch-resource-with-photo-info
  "Appends the photo info section if doesn't exist, or replacing an existing one. 
   When the '<--!photo-into-->' marker doesn't exist, then the whole title will be replaced"
  [parent resource]
  (let [orig-title (-> (:title resource)
                       (str/split #"\n"))
        custom-title (->> orig-title
                          (take-while #(not (= "<!--photo-info-->" %))) ;; Take all lines before the marker
                          (str/join "\n"))
        generated-title (-> (fs/path parent (:src resource))            ;; append filename to parent path
                            (load-exif)
                            (template-social)                           ;; create template
                            (str/replace #"\n" "<br/>\n")               ;; add html line breaks
                            (wrap-info))]                               ;; wrap raw info in html
    (assoc resource :title (str custom-title "\n" generated-title))))

(defn update-md []
  (let [files (fs/glob "content" "**.md")]
    (doseq [f files]
      (let [front-matter (read-frontmatter f)
            updated (assoc front-matter :resources
                           (map #(patch-resource-with-photo-info (fs/parent f) %) (:resources front-matter)))]
        (write-front-matter f updated)))))

(defn- resource-exists? [resources file]
  (seq (filter #(= (:src %) (fs/file-name file)) resources)))

(defn- add-missing-resources
  [resources images]
  (reduce
   (fn [resources img]
     (if (resource-exists? resources img)
       resources
       (conj resources
             (->> {:src (fs/file-name img) :title ""}                  ;; create resource from file
                  (patch-resource-with-photo-info (fs/parent img)))))) ;; and add photo info from exif
   resources
   images))

(defn add-resources []
  (let [files (fs/glob "content" "**/index.md")] ;; only leaf index.mds are updated
    (doseq [f files]
      (let [images (fs/glob (fs/parent f) "*.jpg")
            front-matter (read-frontmatter f)
            updated (assoc front-matter
                           :resources
                           (add-missing-resources (:resources front-matter) images))]
        (write-front-matter f updated)))))

;; Main
(def valid-commands ["copy-content" "clean-content" "update-md" "add-resources"])

(defn validation-for [name values]
  {:pred #(some #{%} values)
   :ex-msg (fn [_] (str "Possible values for '" name " are: " (str/join ", " values)))})

(def cli-spec
  {:spec {:help {:desc "Displays this help"
                 :alias :h}
          :cmd {:require true}}
   :validate {:cmd (validation-for "cmd" valid-commands)}
   :args->opts [:cmd :arg1]})

(def usage
  "Usage:

gallery-manager [options] command

Available options:
")

(defn show-help
  [spec]
  (str usage (cli/format-opts (merge spec {:order [:help]}))))

(defn -main
  [args]
  (if (or (some #{"-h"} args) (some #{"--help"} args) (empty? args))
    (println (show-help cli-spec))
    (let [opts (cli/parse-opts args cli-spec)]
        ; (println (str "Hello from tasker: " opts))
      (case (:cmd opts)
        "copy-content" (copy-content)
        "clean-content" (clean-content)
        "update-md" (update-md)
        "add-resources" (add-resources)
        :default (println (show-help cli-spec))))))

(-main *command-line-args*)
