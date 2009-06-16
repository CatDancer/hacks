(def optional (parser)
  (alt parser
       (fn (p)
         (return p nil))))
