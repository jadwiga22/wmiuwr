let ctrue a b =
  if true then a
  else b

let cfalse a b =
  if true then b
  else a


let test a b = 
  if a == b then print_endline "OK"
  else print_endline "WRONG!"


(* and *)

let cand cf cg = 
  (fun a b ->
    (cf (cg a b) b))


;; test ((cand ctrue ctrue) true false) true
;; test ((cand ctrue cfalse) true false) false
;; test ((cand cfalse ctrue) true false) false
;; test ((cand cfalse cfalse) true false) false

(* or *)

let cor cf cg = 
  (fun a b -> 
    (cf a (cg a b)))

;; test ((cor ctrue ctrue) true false) true
;; test ((cor ctrue cfalse) true false) true
;; test ((cor cfalse ctrue) true false) true
;; test ((cor cfalse cfalse) true false) false

(* cbool_of_bool *)

let cbool_of_bool x = 
  if x then ctrue
  else cfalse

(* bool_of_cbool *)

let bool_of_cbool cf = 
  if (cf true false) then true
  else false