(ns dna.transcription
  (require [dna.genes :refer :all]
           [lib.maps :refer :all])
  (use [clojure.string :only (split)]))

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
(defn all-gene-end [DNA]
  (loop [end1 (find-geneEnd DNA)
         result []]
    (if-not (= end1 -1)
      result
      (recur (subs (str DNA) end1)    ;loop with 2 new arguments
             (conj result (nth DNA end1)))))
  )

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


(defn afterend [str1 int1]
  (subs
    (str str1)
    int1
    )
  )
(defn reststr [str1]
  (loop [x (str str1)
         y (find-geneStart str1)
         tot 0
         result []]
    (if (= y -1)
      (rest result)
      (recur (afterend x (+ 1 (find-geneStart x))) ;loop with 2 new arguments
             (find-geneStart x)
             (+ tot y)
             (conj result (vector x)))
      ))
  )

(defn genomes []
  ;(first (first (reststr test-rnaM)))
  (for [x (reststr test-rnaM)
        y [find-geneEnd]
        z [subs]
        ]
    [(z (first x) 0 (y (first x)))]
    )
  )

(defn split-genomes []
  (for [x (genomes)
        ]
     (split (first x) #" ")
    ))

(defn val-exess []
  (for [x (split-genomes)
        ]
    (reduce + (rest (for [y x
          ]
      (Transfer-Rna (keyword (subs y 1)))
      )))
    ))








