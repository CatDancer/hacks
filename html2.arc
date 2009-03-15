(def flatstring xs
  (apply + "" (map [coerce _ 'string] (flat xs))))

; copied from pr-escaped in arc2/html.arc
;
(def esc-c (c)
  (case c #\<  "&#60;"  
          #\>  "&#62;"  
          #\"  "&#34;"  
          #\&  "&#38;"
          c))

(def esc (s)
  (flatstring (map esc-c (coerce (string s) 'cons))))

(def render-class (val)
  (aif (flat val)
       (apply string (intersperse " " (map string it)))))

(def render-option (key val)
  (case key
    class  (render-class val)
           val))

(def tag-option ((key val))
  (aif (render-option key val)
       (string " " key "=\"" it #\")
       ""))

(def tag-options2 (options)
  (map tag-option (pair options)))

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

(edef html-tag ((tag attrs . body) nl)
  (flatstring
   "<" tag (tag-options2 attrs) (if nl "\n") ">"
   (map (if nl nlhtml html) body)
   (if (no (find tag html-single-tags*)) (list "</" tag (if nl "\n") ">"))))

(edef html1 (x (o nl))
  (if (no x)
       ""
      (isa x 'string)
       x
      (and (acons x) (isa (car x) 'sym))
       (html-tag x (if nl "\n"))
      (acons x)
       (apply (if nl nlhtml html) x)
       (err "Can't convert to html" x)))

(edef html args
  (apply + "" (map html1 args)))

(edef nlhtml args
  (apply + "" (map [html1 _ t] args)))

(def ckh (x)
  (html1 x)
  x)
