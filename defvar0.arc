; Have to use ac-set-global here, as using = or assign would invoke
; our own previously defined settor when defvar was called on the same
; variable twice.

(mac defvar (name impl)
  `(do (ac-set-global ',name ,impl)
       (set (defined-var* ',name))
       nil))

(mac defvar-impl (name)
  (let gname (ac-global-name name)
    `(ac-scheme ,gname)))

(mac undefvar (name)
  `(do (wipe (defined-var* ',name))
       (wipe ,name)))
  
; idea: extend def and mac to call undefvar so that a defvar can be
; redefined as a function or a macro?
;
; Is there a reason why we need to store the defvar's implementation
; procedure in the global variable namespace?  A reason not to?
