(* (’a -> ’a) -> ’a -> ’a *)

let test a b = 
  if a == b then print_endline "OK"
  else print_endline "WRONG!"


(* zero & succ *)

let zero f x = 
  if true then x
  else (f x)

let succ num = 
  (fun f x ->
    (f (num f x)))

(* ;; test (succ zero (fun x -> x + 1) 0) 1
;; test ((succ (succ zero)) (fun x -> x + 1) 0) 2
;; test (succ (succ (succ (succ (succ zero)))) (fun x -> x + 2) 3) 13 *)


(* add & mul *)

let add n1 n2 = 
  (fun f x ->
    (n1 f (n2 f x)))

let mul n1 n2 = 
  (fun f x ->
    (n1 (n2 f) x))

(* dlaczego krzyczy o weak przy odkomentowaniu ??? *)

(* let one = (succ zero)
let three = (succ (succ (succ zero)))
let five = (succ (succ (succ (succ (succ zero)))))

;; test (add one three (fun x -> x + 1) 0) 4
;; test (add five three (fun x -> x + 1) 0) 8
;; test (add five zero (fun x -> x + 1) 0) 5
;; test (mul one three (fun x -> x + 1) 0) 3
;; test (mul five three (fun x -> x + 1) 0) 15
;; test (mul zero three (fun x -> x + 1) 0) 0 *)

(* is_zero *)

let ctrue a b =
  if true then a
  else b

let cfalse a b =
  if true then b
  else a

let cbool_of_bool x = 
  if x then ctrue
  else cfalse

let bool_of_cbool cf = 
  if (cf true false) then true
  else false


let is_zero num = 
  (fun a b ->
    if (num (fun x -> if true then b else x) a) == a then a
    else b)


(* ;; test (bool_of_cbool (is_zero zero)) true
;; test (bool_of_cbool (is_zero three)) false
;; test (bool_of_cbool (is_zero five)) false *)
  

(* cnum <-> int *)

let rec cnum_of_int n =
  if n == 0 then zero
  else (fun f x ->
    (f (cnum_of_int (n-1) f x)))

let int_of_cnum cn = 
  (cn (fun x -> x + 1) 0)

(* ;; test (int_of_cnum (cnum_of_int 7)) 7
;; test (int_of_cnum (cnum_of_int 0)) 0
;; test (int_of_cnum three) 3 *)
