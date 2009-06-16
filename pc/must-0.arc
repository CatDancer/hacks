(def must (errmsg parser)
  (fn (p)
    (or (parser p)
        (err errmsg))))
