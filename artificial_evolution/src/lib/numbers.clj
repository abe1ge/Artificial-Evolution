(ns lib.numbers)

(defn parse-int [s]
  (Integer. (re-find  #"\d+" s )))

(defn String->Number [str]
  (let [n (read-string str)]
    (if (number? n) n nil)))