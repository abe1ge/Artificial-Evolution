(ns lib.numbers
  (:require [clojure.set :as set]))

(defn parse-int [s]
  (Integer. (re-find  #"\d+" s )))

(defn String->Number [str]
  (let [n (read-string str)]
    (if (number? n) n nil)))

(defn unique-random-numbers [int]
  (let [a-set (set (take int (repeatedly #(rand-int int))))]
    (concat a-set (set/difference (set (take int (range)))
                                  a-set))))

(defn rand-int-range [min max]
  (+ (rand-int (- max min)) min))