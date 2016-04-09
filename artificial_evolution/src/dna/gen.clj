(ns dna.gen
  (require [dna.genes :refer :all]
           [lib.numbers :refer :all]
           [lib.maps :refer :all]
           )
  (use [clojure.string :only (split)]))

(def mygean1 "101010001010101010")

(defn gen-gean [num ]
  (def mygean1 "1 ")
  (println mygean1)
  (loop [x num]
    (when (> x 1)
      (def mygean1
        (str mygean1 (rand-int 2))
        )
      (recur (- x 1))))
  )

(def agent1 "(setup-rabbits1 0.1 blue 123)")

;Chang string to int
(defn str-int [str]
  (let [n (read-string str)]
    (if (number? n) n nil)))


(def geans-list [speed colour])


;;find the gean from gene list using which gene it is

;(defn new-gene [id rtn map-list]
;  (for [x map-list]
;    (str id (rand-key rtn x)))
;  )


(defn new-gean-str [id]

    (apply str (str id) (flatten (for [x geans-list
                          y [rand-key]]
                      (y list x))))
  )

(defn new-gean-list [id]

  (concat (list id)
          (flatten
            (for [x geans-list
                  y [rand-key]]
              (y list x))
            )
          )
  )

(defn createDNA [id])


(defn sep-gean [gean]
  (split gean #":")
  )


