(ns differ
  (:require [babashka.fs :as fs]
            [clojure.string :as str]
            [babashka.process :refer [sh]]))

;;; Differ is a tool to help decipher what the difference really is when Scala's munit test frawework
;;; produces a "long diff" containing many nested attributes of case classes

(defn split-lines [lines]
  (flatten (map #(str/split % #",") lines)))

(defn read-raw []
  (sh "/bin/sh", "-c",  "stty raw </dev/tty")            ; enter raw terminal mode
  (let [bytes (doall                                     ; realise the lazy sequence/stream
               (take-while #(not (= % 4))                ; take bytes until we reach EOF (CTRL+D)
                           (repeatedly #(.read *in*))))] ; read bytes from stdin

    (sh "/bin/sh", "-c", (str "stty sane </dev/tty"))    ; restore normal terminal mode 
    (str/split (apply str (map char bytes)) #"\n")))

(let [lines (read-raw)
      left (filter #(not (str/starts-with? % "+")) lines)
      right (filter #(not (str/starts-with? % "-")) lines)]
  (fs/write-lines "/tmp/diff-left.txt" (split-lines left))
  (fs/write-lines "/tmp/diff-right.txt" (split-lines right))
  (sh {:out *out*} "delta" "/tmp/diff-left.txt" "/tmp/diff-right.txt"))
