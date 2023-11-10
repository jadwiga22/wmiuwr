type 'a nlist =
  | Nil
  | Zero of ('a * 'a) nlist
  | One  of 'a * ('a * 'a) nlist

type 'a blist = 
| BNil
| BZero of ('a * 'a) blist
| BOne  of 'a * ('a * 'a) blist
| BTwo of 'a * 'a * ('a * 'a) blist

let rec cons : 'a. 'a -> 'a nlist -> 'a nlist =
  fun x xs ->
  match xs with
  | Nil        -> One(x, Nil)
  | Zero xs    -> One(x, xs)
  | One(y, xs) -> Zero (cons (x, y) xs)

let rec consb : 'a. 'a -> 'a blist -> 'a blist =
  fun x xs ->
  match xs with
  | BNil           -> BOne(x, BNil)
  | BZero xs       -> BOne(x, xs)
  | BOne(y, xs)    -> BTwo(x, y, xs)
  | BTwo(y, z, xs) -> BOne(x, consb (y, z) xs)

let rec view : 'a. 'a nlist -> ('a * 'a nlist) option =
  function
  | Nil -> None
  | Zero xs ->
    begin match view xs with
    | None -> None
    | Some((x, y), xs) -> Some(x, One(y, xs))
    end
  | One(x, xs) -> Some(x, Zero xs)

let rec viewb : 'a. 'a blist -> ('a * 'a blist) option =
  function
  | BNil -> None
  | BZero xs ->
    begin match viewb xs with
    | None -> None
    | Some((x, y), xs) -> Some(x, BOne(y, xs))
    end
  | BOne(x, xs)    -> Some(x, BZero xs)
  | BTwo(x, y, xs) -> Some(x, BOne(y, xs))

let rec nth : 'a. 'a nlist -> int -> 'a =
  fun xs n ->
  match xs with
  | Nil -> raise Not_found
  | Zero xs ->
    let (x, y) = nth xs (n / 2) in
    if n mod 2 = 0 then x
    else y
  | One(x, xs) ->
    if n = 0 then x
    else nth (Zero xs) (n-1)

let rec nthb : 'a. 'a blist -> int -> 'a =
  fun xs n ->
  match xs with
  | BNil -> raise Not_found
  | BZero xs ->
    let (x, y) = nthb xs (n / 2) in
    if n mod 2 = 0 then x
    else y
  | BOne(x, xs) ->
    if n = 0 then x
    else nthb (BZero xs) (n-1)
  | BTwo(x, y, xs) ->
    if n = 0 then x
    else nthb (BOne(y, xs)) (n-1)


let xx = consb 7 (consb 10 BNil)
let x0 = consb 1 xx
let x1 = consb 3 x0

;; assert (nthb x1 0 = 3)
;; assert (nthb x1 1 = 1)
;; assert (nthb x1 2 = 7)
;; assert (nthb x1 3 = 10)

;; assert (viewb x1 = Some(3, x0))
;; assert (viewb BNil = None)

let rec iter (n : int) (xs : 'a nlist) : unit = 
  if n = 0 then ()
  else match view xs with
  | None -> failwith "Empty list"
  | Some(x, xs) -> iter (n-1) (cons x xs)

let rec iterb (n : int) (xs : 'a blist) : unit = 
  if n = 0 then ()
  else match viewb xs with
  | None -> failwith "Empty list"
  | Some(x, xs) -> iterb (n-1) (consb x xs)


(* time tests *)

let time f n xs =
  let t = Sys.time() in
  let fx = f n xs in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t)

let timeb f n xs =
  let t = Sys.time() in
  let fx = f n xs in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t)

let rec list n = 
  if n < 0 then []
  else n :: list (n-1)

let xxl = list 65535
let xn = List.fold_right cons  xxl Nil
let xb = List.fold_right consb xxl BNil
let n_max = 10000000

;; time iter  n_max xn
;; time iterb n_max xb

(* nlisty działają w około 2.7s 
   a blisty w 0.5s *)
