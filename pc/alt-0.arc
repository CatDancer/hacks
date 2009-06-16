(def alt parsers
  (fn (p)
    (some [_ p] parsers)))
