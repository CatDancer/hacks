(def many1 (parser)
  (seq parser
       (many parser)))
