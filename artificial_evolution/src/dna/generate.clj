(ns dna.generate
  (require [dna.genes :refer :all]
           [lib.maps :refer :all]
           [lib.numbers :refer :all]))


;;generate gene given the value of the gene

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
        y [Transfer-Rna]]
    (keyByValue x y)))

;;generate a randome gene sequince
(defn rand-gene []
  (gen-gene (rand-int-range 50 150)))

(defn string-to-charbits [s]
  (let [bits (java.util.BitSet.)]
    (for [c s]
      (.set bits (int c)))
    bits))