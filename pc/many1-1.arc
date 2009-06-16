(def many1 (parser)
  (fn (p)
    (iflet (p2 (r1 rs)) ((seq parser
                              (many parser))
                         p)
      (return p2 (cons r1 rs)))))
