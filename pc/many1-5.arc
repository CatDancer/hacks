(def many1 (parser)
  (cons-seq parser
            (many parser)))
