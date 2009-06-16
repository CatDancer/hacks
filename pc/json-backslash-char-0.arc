(def json-backslash-char (c)
  (case c
    #\" #\"
    #\\ #\\
    #\/ #\/
    #\b #\backspace
    #\f #\page
    #\n #\newline
    #\r #\return
    #\t #\tab
    (err "invalid backslash char" c)))
