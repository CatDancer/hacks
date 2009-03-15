; This code is in the public domain.

(def escape-perl-string (s)
  (mz:regexp-replace* "[\\\\']" s "\\\\&"))

(def strperl (s)
  (if (mz:bytes? s)
       ((mz bytes-append) (mz #"'") (escape-perl-string s) (mz #"'"))
       (string            "'"       (escape-perl-string s) "'")))
