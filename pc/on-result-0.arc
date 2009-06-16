(def on-result (f parser)
  (fn (p)
    (iflet (p2 r) (parser p)
      (return p2 (f r)))))
