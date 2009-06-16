(mac forward (parser)
  (w/uniq p
    `(fn (,p) (,parser ,p))))
