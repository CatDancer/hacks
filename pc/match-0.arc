(def match (f)
  (fn (p)
    (and p
         (let x car.p
           (if (f x)
             (return cdr.p x))))))
