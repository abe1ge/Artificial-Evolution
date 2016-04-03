(ns dna.definitions
  (require [comm.translater :refer :all])
  (use [clojure.string :only (split)])
  )


(def speed
  {:0000 0.2
   :0001 0.3
   :0010 0.4
   :0011 0.5
   :0100 0.6
   :0101 0.7
   :0110 0.8
   :0111 0.9
   :1000 1
   :1001 1.1
   :1010 1.2
   :1011 1.3
   :1100 1.4
   :1101 1.5
   :1110 1.6
   :1111 1.7
   })

(def colour
  {:0000 "gray"
   :0001 "red"
   :0010 "orange"
   :0011 "brown"
   :0100 "yellow"
   :0101 "green"
   :0110 "lime"
   :0111 "turquoise"
   :1000 "cyan"
   :1001 "sky"
   :1010 "blue"
   :1011 "violet"
   :1100 "magenta"
   :1101 "pink"
   :1110 "black"
   :1111 "white"
   })

(def speed2
  {:0000 1
   :0001 2
   :0010 3
   :0011 4
   :0100 5
   :0101 6
   :0110 7
   :0111 8
   :1000 9
   :1001 10
   :1010 11
   :1011 12
   :1100 13
   :1101 14
   :1110 15
   :1111 16
   })

(def geans-list [speed colour])


(defn get-speed [gean]
  (let [x (rand-nth (keys gean))]
    x
    )
  )
(defn new-gean-str [id]
  (let [x id]
    (str x (get-speed speed) (get-speed colour))
    )
  )

(defn new-gean-list [id]
  (let [x id]
    (list x (get-speed speed) (get-speed colour))
    )
  )

(defn sep-gean [gean]
  (split gean #":")
  )

(defn get-color []
  (rand-nth (vec colour)))

(defn nlogotranslate [id]
  (nlogo-translate-cmd (concat '(try) (new-gean-list id))))

