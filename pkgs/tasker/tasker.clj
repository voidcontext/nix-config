(ns tasker
  (:require
   [babashka.cli :as cli]
   [babashka.fs :as fs]
   [babashka.http-client :as http]
   [cheshire.core :as json]
   [clojure.edn :as edn]
   [clojure.string :as str]))

(require  '[babashka.deps :as deps])
(deps/add-deps '{:deps {io.github.lispyclouds/bblgum {:git/sha "1d4de3d49b84f64d1b71930fa1161f8d2622a4d9"}}})
(require '[bblgum.core :as b])

;; Setting up CLI
(def usage
  "Usage:

tasker [options] command

Available options:
")

(defn show-help
  [spec]
  (str usage (cli/format-opts (merge spec {:order [:help]}))))

(def valid-commands ["switch" "current" "list" "delete"])

(defn validation-for [name values]
  {:pred #(some #{%} values)
   :ex-msg (fn [_] (str "Possible values for '" name " are: " (str/join ", " values)))})

(def cli-spec
  {:spec {:help {:desc "Displays this help"
                 :alias :h}
          :cmd {:require true}}
   :validate {:cmd (validation-for "cmd" valid-commands)}
   :args->opts [:cmd :arg1]})

;; Lib - fs
(def tasker-dir (fs/path (System/getenv "HOME") ".tasker"))
(def tasks-file (fs/path tasker-dir "tasks.edn"))

(defn load-tasks []
  (if (fs/exists? tasks-file)
    (let [lines (fs/read-all-lines tasks-file)]
      (edn/read-string (str/join "" lines)))
    {:tasks {}}))

(defn write-tasks [tasks]
  (if (not (fs/directory? tasker-dir))
    (fs/create-dirs tasker-dir)
    nil)
  (fs/write-bytes tasks-file
                  (.getBytes (pr-str tasks))))

;; Lib - jira

(defn ticket-number [url]
  (re-find #"CUOPP-\d+" url))

;; Lib - output

(defn print-lines [lines]
  (println (apply str (interpose "\n" lines))))

;; Core logic

(defn abort [msg]
  (println msg)
  (System/exit 1))

(defn- safe-key [url]
  (keyword (str/replace url #"[:\/\.]" "-")))

(defn- task-info-lines [task]
  [(str "url           : " (:url task))
   (str "summary       : " (:summary task))
   (str "ticket number : " (:id task))])

(defn- print-task [task]
  (print-lines (task-info-lines task)))

(defn- create-new-task [url]
  (let [id (ticket-number url)
        issue (-> (http/get (str "https://" (System/getenv "JIRA_API_HOST") "/rest/api/2/issue/" id "?fields=summary")
                            {:basic-auth [(System/getenv "JIRA_API_USERNAME") (System/getenv "JIRA_API_TOKEN")]})
                  :body
                  (json/parse-string true))]
    {:url url
     :summary (-> issue :fields :summary)
     :id id}))

(defn- apply-switch
  "Applies the switching to a new or existing task by updating the tasks.edn file."
  [tasks url]
  (let [key (safe-key url)]
    (if (contains? tasks key)
      (write-tasks (assoc tasks :current key))
      (write-tasks
       (-> tasks
           (assoc :tasks (assoc (:tasks tasks) key (create-new-task url)))
           (assoc :current key))))
    (print-task (-> (load-tasks) :tasks key))))

(defn- delete-task 
  [tasks url]
  (let [key (safe-key url)]
    (-> tasks
        (update :tasks #(dissoc % key))
        (update :current #(if (= % key) nil %))
        (write-tasks)
        )))
    

(defn- choose-existing-task [tasks]
  (-> (b/gum :choose (map #(str (:url %)) (vals (:tasks tasks)))
             :selected.foreground "10"
             :item.foreground "7")
      :result
      first))

(defn switch-to
  "Switches to a new or an existing task defined by it's JIRA url.
  When the url param is nil, an existing task can be selected from a list."
  [url]
  (let [tasks (load-tasks)]
    (if (nil? url)
      (if (empty? (vals (:tasks tasks)))
        (abort "There aren't any recorded tasks")
        (let [choosen (choose-existing-task tasks)]
          (if (= choosen "user aborted")
            nil
            (apply-switch tasks choosen))))
      (apply-switch tasks url))))

(defn show-current-task
  "Displays the current task if set in the task.edn file"
  [field]
  (let [tasks (load-tasks)]
    (if (nil? (:current tasks))
      (abort "There's no current task")
      (let [current ((:current tasks) (:tasks tasks))]
        (if (nil? field)
          (print-task current)
          (println ((keyword field) current)))))))

(defn list-tasks
  []
  (let [tasks (load-tasks)]
    (print-lines
     (->> (:tasks tasks)
          (vals)
          (map #(cons (str "Task [" (:id %) "]") (task-info-lines %)))
          (interpose " ==== ### ====\n")
          (flatten)))))

(defn delete
  [url]
  (let [tasks (load-tasks)]
    (if (nil? url)
      (if (empty? (vals (:tasks tasks)))
        (abort "There aren't any recorded tasks")
        (let [choosen (choose-existing-task tasks)]
          (if (= choosen "user aborted")
            nil
            (delete-task tasks choosen))))
      (delete-task tasks url))))

;; Application
(defn -main
  [args]
  (if (or (some #{"-h"} args) (some #{"--help"} args) (empty? args))
    (println (show-help cli-spec))
    (let [opts (cli/parse-opts args cli-spec)]
      ; (println (str "Hello from tasker: " opts))
      (case (:cmd opts)
        "switch" (switch-to (:arg1 opts))
        "current" (show-current-task (:arg1 opts))
        "list" (list-tasks)
        "delete" (delete (:arg1 opts))))))

(-main *command-line-args*)
