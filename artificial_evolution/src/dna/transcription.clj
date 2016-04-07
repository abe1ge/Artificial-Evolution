(ns dna.transcription
  (require [dna.genes :refer :all]))

;;RNA plymerase... find the gene and extract it


(defn find-geneEnd

  [DNA]
  (.indexOf (str DNA) (str gene-end))
  )

(defn find-geneStart

  [DNA]
  (.indexOf (str DNA) (str gene-start))
  )

;(defn restrest [DNA]
;
;  (loop [end ()
;         result []]
;    (if-not (> end1 start)
;      result
;      (recur (- end1 1)    ;loop with 2 new arguments
;             (conj result (nth DNA end1)))))
;  )


(defn dna-ranM
  "takes RNA and returns
  the start and end index of first gene"
  [DNA]

  (vector (find-geneStart DNA)
  (find-geneEnd DNA))
  )

;;this outputs messenger RNA

;;The messenger RNA needs to be proccesed so the
;; only the gene is left
