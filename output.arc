(def output (expr)
  (with (result nil
         error nil)
    (let out (tostring
              (= result
                 (on-err (fn (c)
                           (= error details.c)
                           nil)
                         (fn ()
                           (eval (fromstring expr (read)))))))
      (write `((result ,(tostring:write result))
               (out ,out)
               (error ,error)))
      (prn))))
