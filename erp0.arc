(mac erp (x)
  (w/uniq (gx)
    `(let ,gx ,x
       (w/stdout (stderr)
         (pr ',x ": ") (write ,gx) (prn))
       ,gx)))
