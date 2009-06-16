(def hexdigit (c)
  (and (isa c 'char)
       (or (<= #\a c #\f) (<= #\A c #\F) (<= #\0 c #\9))))

(= fourhex
  (must "four hex digits required after \\u"  
    (with-seq (h1 (match hexdigit)
               h2 (match hexdigit)
               h3 (match hexdigit)
               h4 (match hexdigit))
      (coerce (int (coerce (list h1 h2 h3 h4) 'string) 16) 'char))))
