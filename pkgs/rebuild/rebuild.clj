(ns rebuild
  (:require
   [babashka.cli :as cli]
   [babashka.fs :as fs]
   [babashka.process :refer [shell]]
   [clojure.string :as str]))

(defn hostname []
  (-> (shell {:out :string} "hostname")
      :out
      (str/replace #"\.(lan|local)\n$" "")))

(def usage
  "Usage:

rebuild [options] command [host]

Available options:
")

(defn show-help
  [spec]
  (str usage (cli/format-opts (merge spec {:order [:help :system :dir]}))))

(def valid-systems ["darwin" "linux"])

(def valid-commands ["build" "switch"])

(defn validate-system [system]
  (some #{system} valid-systems))

(defn validate-cmd [cmd]
  (some #{cmd} valid-commands))

(def cli-spec
  {:spec
   {:help {:desc "Displays this help"
           :alias :h}
    :system {:desc "system" :require true}
    :dir {:desc "working directory" :default "."}
    ;; positional
    :cmd {:require true}
    :host {:default (hostname)}}

   :validate {:system {:pred validate-system
                       :ex-msg (fn [_] (str "Valid systems are: "
                                            (str/join ", " valid-systems)))}
              :cmd {:pred validate-cmd
                    :ex-msg (fn [_] (str "Valid commands are: "
                                         (str/join ", " valid-commands)))}}
   :args->opts [:cmd :host]})

(defn check-for-danger [dir]
  (if (not (fs/exists? (fs/path dir ".__DANGER__")))
    (do
      (println "!!!DANGER!!!

You probably want to run this command with unlocked extras.")
      (System/exit 1))
    nil))

(defn rebuild-darwin [dir host cmd]
  (shell {:dir dir}
         (str "nix build .#darwinConfigurations." host ".system")
         "--extra-experimental-features" "nix-command"
         "--extra-experimental-features" "flakes"
         "--show-trace")
  (shell {:dir dir}
         "./result/sw/bin/darwin-rebuild" cmd "--flake" (str ".#" host))
  (shell {:dir dir}
         "update-symlinks"))

(defn rebuild-linux [dir host cmd]
  (shell {:dir dir} "sudo" "nixos-rebuild" cmd "--flake" (str ".#" host) "--show-trace"))

; (println (hostname))
(defn -main
  [args]
  (if (or (some #{"-h"} args) (some #{"--help"} args) (empty? args))
    (println (show-help cli-spec))
    (let [{dir :dir cmd :cmd host :host system :system} (cli/parse-opts args cli-spec)]
      (check-for-danger dir)
      (case system
        "darwin" (rebuild-darwin dir host cmd)
        "linux"  (rebuild-linux dir host cmd)))))

(-main *command-line-args*)

