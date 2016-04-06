(ns dna.generate
  (require [dna.definitions :refer :all]
           [lib.maps :refer :all]))

(defn amuno-binary-needed [num]
  (+ 1 (quot num 15))
  )

(defn butlast-amuno-Binary [num]
  (* 15 (amuno-binary-needed num))
  )

(defn last-amuno-binary [num]
  (- 15 (- (butlast-amuno-Binary num) num))
  )

(defn gene [num]
  (flatten (list (unary (- (amuno-binary-needed num) 1)) (last-amuno-binary num)))
  )

(defn gen-gene [num]
  (for [x (vec (gene num))
        y [amuno-binary]]
    (keyByValue x y)))