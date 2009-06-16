(def many1 (parser)
  (with-result (r1 rs) (seq parser
                            (many parser))
    (cons r1 rs)))
