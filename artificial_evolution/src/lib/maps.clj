(ns lib.maps)

;;return key by value
(defn keyByValue [value map]
  (first (filter (comp #{value} map) (keys map)))
  )

;;return a map of key from a map,
;;if it is more then one map it returns it as a list
(defn rand-key
  "return a random key from a map,
  if more then one map returns as list"
  ([map] (rand-nth (keys map)))
  ([map map2] (list (rand-nth (keys map))
                    (rand-nth (keys map2))))
  ([map map2 map3] (list (rand-nth (keys map))
                         (rand-nth (keys map2))
                         (rand-nth (keys map3))))
  )

;;return random key value as vector
(defn rand-asvec [map]
  (rand-nth (vec map))
  )

(defn rand-keyval
  "return a random key and value from a map,
  if more then one map returns as list"
  ([map] (rand-nth (vec map)))
  ([map map2] (list (rand-nth (vec map))
                    (rand-nth (vec map2))))
  ([map map2 map3] (list (rand-nth (vec map))
                         (rand-nth (vec map2))
                         (rand-nth (vec map3))))
  )
