(def json-true (p)
    (if (begins p (coerce "true" 'cons))
         (return (nthcdr 4 p) t)))
