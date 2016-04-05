(ns lib.numbers)

(defn parse-int [s]
  (Integer. (re-find  #"\d+" s )))
