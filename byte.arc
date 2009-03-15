(lib "http://catdancer.github.com/extend.arc")

(extend instring byte mz:bytes? mz:open-input-bytes)

(def bytestring args
  (apply
    mz:bytes-append
    (map (fn (a)
           (if (mz:bytes? a)
                a
                ((mz string->bytes/utf-8) (string a))))
         args)))
