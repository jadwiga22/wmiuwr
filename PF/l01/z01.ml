(** fun x -> x  ma typ 'a -> 'a*)

(** int -> int, funkcja id *)
fun x -> x + 0 

(* (’a -> ’b) -> (’c -> ’a) -> ’c -> ’b *)
fun f -> (fun g -> (fun x -> f (g x)))

(* ’a -> ’b -> ’a *)
fun x -> (fun y -> x)

(* ’a -> ’a -> ’a *)
(fun a b ->
  if a == b then a
  else b)

(* (fun (a : 'a) (b : 'a) -> a) *)

(* 'a -> 'b *)
let rec f x = (f x)

(* let rec f x = (f x) in (f ()) *)
(* Obj.magic 'a -> 'b : funkcja identycznosciowa ale z oszukanym typem :) *)
