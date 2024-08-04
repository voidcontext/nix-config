(ns gallery-manager
  (:require [babashka.fs :as fs]
            [babashka.cli :as cli]
            [babashka.process :refer [shell]]
            [cheshire.core :as json]
            [clj-yaml.core :as yaml]
            [clojure.string :as str]
            [clojure.edn :as edn]))

(defn debug [v]
  (println v)
  v)

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
               (str "🔅 " (:ShutterSpeed exif)  "s, f/" (:Aperture exif) ", ISO " (:ISO exif))
               (str "📅 " (-> (:DateTimeOriginal exif) (str/split  #"\ ") (first) (str/replace ":" "-")))]]
    (str/join "\n" lines)))

(defn load-exif [file]
  (-> (shell {:out :string} (str "exiftool -json \"" file "\""))
      :out
      (json/parse-string true)
      (first)
      (patch-exif)))
;; Utils

(defn load-config []
  (->> (fs/read-all-lines "config.edn")
       (str/join "")
       (edn/read-string)))

(defn write-front-matter [file yaml]
  (let [yaml-str (yaml/generate-string yaml :dumper-options {:flow-style :block})]
    (fs/write-bytes file (.getBytes (str "---\n" yaml-str "\n---\n")))))

(defn src-path-of [config img]
  (fs/path (:exports-dir config) img))

(defn- namespaced-claim [pv]
  (let [claim-ref (-> pv :spec :claimRef)]
    (str (:namespace claim-ref) "/" (:name claim-ref))))

(defn get-remote-sync-dir [claim]
  (let [pvs (-> (shell {:out :string} "kubectl get persistentvolumes -o json")
                :out
                (json/parse-string true))]
    (-> (filter #(= (namespaced-claim %) claim) (:items pvs))
        (first)
        :spec
        :local
        :path)))

;; Commands

(defn copy-content []
  (let [config (load-config)
        files (fs/glob "content" "**.md")]
    (doseq [f files]
      (let [front-matter (read-frontmatter f)]
        (doseq [img  (get-images front-matter)]
          (let [src (src-path-of config img)
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

(defn check-src []
  (let [config (load-config)
        files (fs/glob "content" "**.md")]
    (doseq [f files]
      (let [images (-> (read-frontmatter f) (get-images))]
        (doseq [img images]
          (let [src (src-path-of config img)]
            (when (not (fs/exists? src))
              (println (str "File missing: " src)))))))))

(defn print-info [file]
  (-> file
      (load-exif)
      (template-social)
      (println)))

(defn sync [dry-run]
  (let [config (load-config)
        sync-config (:sync config)
        cmd ["rsync" "--delete" "-z" "--progress" "-r"
             "." (str (:remote sync-config) ":" (get-remote-sync-dir (:pvc sync-config)))]]
    (if dry-run
      (println cmd)
      (apply shell (cons {:dir "public"} cmd)))))

;; Main
(def valid-commands {"copy-content" "Copies all images listed in 'featured_image' and 'resource.src' attrbutes"
                     "clean-content" "Removes all jpg files from the repo"
                     "update-md" "Updates index.md files with the photo information from exif"
                     "add-resources" "Adds image files from content dirs to index.md if missing"
                     "check-src" "Check if any expected resources are missing in source"
                     "sync" "Synchronize gallery with its remote"
                     "info" "Prints photo info of given file"})

(defn validation-for [name values]
  {:pred #(some #{%} values)
   :ex-msg (fn [_] (str "Possible values for '" name " are: " (str/join ", " values)))})

(def cli-spec
  {:spec {:help {:desc "Displays this help"
                 :alias :h}
          :cmd {:require true}
          :dry-run {:desc "Dry run command (works with sync)"
                    :alias :d}}
   :validate {:cmd (validation-for "cmd" (keys valid-commands))}
   :args->opts [:cmd :arg1]})

(def usage
  (str "Usage:

gallery-manager [options] command

Available commands:
"
       (str/join "\n" (map #(str "\t" (first %) ": " (second %)) valid-commands))
       "

Available options:
"))

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
        "check-src" (check-src)
        "sync" (sync (:dry-run opts))
        "info" (print-info (:arg1 opts))
        :default (println (show-help cli-spec))))))

(-main *command-line-args*)
