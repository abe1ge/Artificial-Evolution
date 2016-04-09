(ns evolve.mutation)

(defn mutate

  [Dna]
  (let [dna Dna
        lenth (rand-int (.length dna))
        val (.charAt dna lenth)
        istr (= (.charAt dna lenth) \: )]
    (println (.charAt dna lenth))
    (if istr
      (mutate Dna)
      (str (subs dna 0 lenth)
           (if (= val \1) "0" "1")
           (subs dna (+ 1 lenth) (.length dna)))
      )
    )
  )
