(= css* '())

(def css (id . text)
  (unless (is (type id) 'sym) (err "forgot sym"))
  (let v (apply + "" (map string text))
    (aif (assoc id css*)
          (= (cadr it) v)
          (= css* (+ css* (list (list id v))))))
  id)

(def all-css ()
  (apply string (map cadr css*)))


(= javascript* '())

(def javascript (id . text)
  (let v (apply + "" (map string text))
    (aif (assoc id javascript*)
          (= (cadr it) v)
          (= javascript* (+ javascript* (list (list id v))))))
  id)

(def all-javascript ()
  (apply string (map cadr javascript*)))


(def selected-javascript (keys)
  (apply string
         (map (fn (x)
                (if (is (type x) 'sym)
                     (alref javascript* x)
                    (is (type x) 'string)
                     x
                     (err "type?" x)))
              keys)))

(def css-unselectable ()
  "  -moz-user-select: none;
  -khtml-user-select: none;
  user-select: none;
")

(css 'unselectable
"
.unselectable {
" (css-unselectable) "
}
")

(javascript 'unselectable
"
function return_false () {
    return false;
}

function make_unselectable (element) {
    $(element).addClass('unselectable');
    //element.onselectstart = return_false;
}

$(function () {
    //if ($.browser.msie) {
    //    $('.unselectable').each(function () {
    //        this.onselectstart = return_false;
    //    });
    //}
});
")


(= doctype*
"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">")

(def doctype ()
  (prn doctype*))

(def inline-css args
  `(style (type "text/css")
     "\n"
     ,@args
     "\n"))

(def qu xs
  `("&ldquo;" ,@xs "&rdquo;"))
