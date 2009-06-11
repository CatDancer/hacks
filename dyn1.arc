(mac dynvar (name (o init))
  (w/uniq (param val)
    `(withs (,val ,init
             ,param (ac-scheme (make-parameter ,val)))
       (defvar ,name ,param))))

(mac dynamic (var value . body)
  (w/uniq (param v f)
    `(with (,param (defvar-impl ,var)
            ,v ,value
            ,f (fn () ,@body))
       (ac-scheme (parameterize ((,param ,v)) (,f))))))
