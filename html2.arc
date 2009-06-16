(def flatstring xs
  (apply + "" (map [coerce _ 'string] (flat xs))))

; copied from pr-escaped in arc2/html.arc
;
(def esc-nilc (c)
  (case c #\<  "&#60;"  
          #\>  "&#62;"  
          #\"  "&#34;"  
          #\&  "&#38;"))


(def esc-c (c)
  (or (esc-nilc c) c))

(def esc (s)
  (flatstring (map esc-c (coerce (string s) 'cons))))

(def render-class (val)
  (aif (flat val)
       (apply string (intersperse " " (map string it)))))

(def render-option (key val)
  (case key
    class  (render-class val)
           val))

(def tag-option (emit (key val))
  (if (is key 'javascript)
       (emit 'javascript val)
      (and (acons val) (is car.val 'javascript))
       (emit 'javascript (str "' " key "=\"'+" cadr.val "+'\"'"))
       (aif (render-option key val)
             (emit 'literal (string " " key "=\"" it #\")))))

(def tag-options2 (emit options)
  (map [tag-option emit _] (pair options)))

(def attrtab (attrs)
  (listtab (pair attrs)))

(def unpair (pairs)
  (apply + '() pairs))

(def attr-pos (attrs k)
  (pos [is (car _) k] (pair attrs)))

(def combine-attr-values (k v1 v2)
  (if (is k 'class)
       (dedup (flat (list v1 v2)))
       v2))

(def combine-attr-at (attrs i v2)
  (let a (pair attrs)
    (unpair (+ (cut a 0 i)
               (let (k v1) (a i)
                 (list (list k (combine-attr-values k v1 v2))))
               (cut a (+ i 1))))))

(def prepend-attr (attrs k v)
  (+ (list k v) attrs))

(def add-attr (attrs k v)
  (aif (attr-pos attrs k)
        (combine-attr-at attrs it v)
        (prepend-attr attrs k v)))

(def attr (k v html)
  (let (tag attrs . body) html
    `(,tag ,(add-attr attrs k v) ,@body)))

; http://www.w3.org/TR/html401/index/elements.html where
; end tag forbidden ("F")
;
(= html-single-tags*
   '(area base basefont br col frame hr img input isindex link meta param))

(edef html-tag (emit (tag attrs . body) nl)
   (emit 'literal "<")
   (emit 'literal string.tag)
   (tag-options2 emit attrs)
   (if nl (emit 'literal "\n"))
   (emit 'literal ">")
   (inhtml emit nl body)
   (if (no (find tag html-single-tags*))
        (do (emit 'literal "</")
            (emit 'literal string.tag)
            (if nl (emit 'literal "\n"))
            (emit 'literal ">"))))

(edef html1 (emit x (o nl))
  (if (no x)
       nil
      (isa x 'string)
       (emit 'literal x)
      (and (acons x) (is (car x) 'javascript))
       (emit 'javascript cadr.x)
      (and (acons x) (isa (car x) 'sym))
       (html-tag emit x (if nl "\n"))
      (acons x)
       (inhtml emit nl x)
       (err "Can't convert to html" x)))

(def inhtml (emit nl xs)
  (map [html1 emit _ nl] xs))

(def foo (ignore x)
  (unless (isa x 'string) (err "not a string" x))
  (pr x))

(edef html args
  (tostring:inhtml foo nil args))

(edef nlhtml args
  (tostring:inhtml foo t args))

(def jshtml0 (h)
  (accum a
    (let emit (fn (type x)
                (a:case type
                  literal    tojson.x
                  javascript x
                             (err "unknown emit type" type)))
      (inhtml emit nil (list h)))))

(def jshtml (h)
  (apply string (intersperse "," jshtml0.h)))

(def ckh (x)
  (html1 x)
  x)
