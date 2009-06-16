(mac with-result (vars parser . body)
  `(on-result (fn (,vars) ,@body)
              ,parser))
