(def many1 (parser)
  (with-seq (r1 parser
             rs (many parser))
    (cons r1 rs)))
