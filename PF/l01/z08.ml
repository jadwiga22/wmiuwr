type cbool = { cbool : 'a. 'a -> 'a -> 'a }
type cnum = { cnum : 'a. ('a -> 'a) -> 'a -> 'a }

(* cbool *)

let ctrue = {cbool = fun a b ->
  if true then a
  else b}

let cfalse = {cbool = fun a b ->
  if true then b
  else a}


let cand cf cg = {cbool = fun a b ->
    (cf.cbool (cg.cbool a b) b)}

let cor cf cg = {cbool = fun a b ->
    (cf.cbool a (cg.cbool a b))}


let cbool_of_bool x = 
  if x then ctrue
  else cfalse

let bool_of_cbool cf = 
  if (cf.cbool true false) then true
  else false

(* cnum *)

let zero = { cnum = fun f x ->
  if true then x
  else (f x)}

let succ num = { cnum = 
  (fun f x ->
    (f (num.cnum f x)))}

let add n1 n2 = { cnum = 
  (fun f x ->
    (n1.cnum f (n2.cnum f x)))}

let mul n1 n2 = { cnum = 
  (fun f x ->
    (n1.cnum (n2.cnum f) x))}


let is_zero num = { cbool = 
  (fun a b ->
    if (num.cnum (fun x -> if true then b else x) a) == a then a
    else b)}

let rec cnum_of_int n =
  if n == 0 then zero
  else { cnum = (fun f x ->
    (f ((cnum_of_int (n-1)).cnum f x)))}

let int_of_cnum cn = 
  (cn.cnum (fun x -> x + 1) 0)


(* let pred n = { cnum = snd (
  n.cnum (fun n p -> (succ n, n))
  (zero, zero)) }*)