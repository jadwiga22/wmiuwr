(* open Seq ;;

type _ fin_type =
| Unit : unit fin_type
| Bool : bool fin_type
| Pair : 'a fin_type * 'b fin_type -> ('a * 'b) fin_type

(* product from library implements this *)

let rec combine_one : type a b. a -> b Seq.t -> (a * b) Seq.t -> (a * b) Seq.t =
  fun x ys acc () ->
    match ys () with
    | Nil -> acc ()
    | Cons(y, ys) -> Cons((x,y), combine_one x ys acc)

let rec combine : type a b. a Seq.t -> b Seq.t -> (a * b) Seq.t =
  fun xs ys () ->
    match xs () with
    | Nil -> Nil
    | Cons(x, xs) -> combine_one x ys (combine xs ys) ()

let rec all_values : type a. a fin_type -> a Seq.t = 
  fun t () ->
    match t with
    | Unit -> (Cons((), fun () -> Nil))
    | Bool -> (Cons(true, fun () -> (Cons(false, fun () -> Nil))))
    | Pair(tp1, tp2) -> 
      let s1 = all_values tp1 in 
      let s2 = all_values tp2 in
      combine s1 s2 ()

let to_list = 
  Seq.fold_left (fun acc x -> x :: acc) [] 

;; (all_values (Pair(Unit, Bool))) ()
;; (all_values (Pair(Pair(Unit, Bool), Bool))) ()
   *)

open Seq ;;

type empty = |

type _ fin_type =
| Empty  : empty fin_type
| Either : 'a fin_type * 'b fin_type -> (('a, 'b) Either.t) fin_type
| Unit   : unit fin_type
| Bool   : bool fin_type
| Pair   : 'a fin_type * 'b fin_type -> ('a * 'b) fin_type

let rec combine_one : type a b. a -> b Seq.t -> (a * b) Seq.t -> (a * b) Seq.t =
  fun x ys acc () ->
    match ys () with
    | Nil -> acc ()
    | Cons(y, ys) -> Cons((x,y), combine_one x ys acc)

let rec combine : type a b. a Seq.t -> b Seq.t -> (a * b) Seq.t =
  fun xs ys () ->
    match xs () with
    | Nil -> Nil
    | Cons(x, xs) -> combine_one x ys (combine xs ys) ()

let rec make_either_right : type a b. b Seq.t -> ((a, b) Either.t) Seq.t =
  fun xs () ->
    match xs () with
    | Nil -> Nil
    | Cons(x, xs) -> Cons(Either.Right(x), make_either_right xs)

let rec append : type a b. a Seq.t -> b Seq.t -> ((a, b) Either.t) Seq.t =
  fun xs ys () ->
    match xs () with
    | Nil -> make_either_right ys ()
    | Cons(x, xs) -> 
      Cons(Either.Left(x), append xs ys)

let rec all_values : type a. a fin_type -> a Seq.t = 
  fun t () ->
    match t with
    | Empty -> Nil
    | Either(tp1, tp2) -> append (all_values tp1) (all_values tp2) ()
    | Unit -> (Cons((), fun () -> Nil))
    | Bool -> (Cons(true, fun () -> (Cons(false, fun () -> Nil))))
    | Pair(tp1, tp2) -> 
      let s1 = all_values tp1 in 
      let s2 = all_values tp2 in
      combine s1 s2 ()

(* let to_list = 
  Seq.fold_left (fun acc x -> x :: acc) []  *)

(* ;; (all_values (Pair(Unit, Bool))) ()
;; (all_values (Pair(Pair(Unit, Bool), Bool))) () *)
