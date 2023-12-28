module type RandomMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val random : int t
  val run : int -> 'a t -> 'a
end

module RS : sig include RandomMonad 
end =
struct
  type 'a t = int -> 'a * int

  let random = 
    fun (a : int) -> 
      let b = (16807 * (a mod 127773)) - (2836 * (a / 127773)) in
      if b > 0 then (a, b)
      else (a, b + 2147483647)

  (* result, state *)
  let return x n =  (x, n)

  let bind (e1 : 'a t) (e2 : 'a -> 'b t) (st : int) = 
    let (r1, st) = e1 st in
    e2 r1 st

  let run (n : int) (e : 'a t) : 'a = 
    fst (e n)
end

module Shuffle(R : RandomMonad) : sig
  val shuffle : 'a list -> 'a list R.t
  val get_shuffled_list : 'a list -> int -> 'a list
end = 
struct
  let (let*) = R.bind

  let remove (i : int) (xs : 'a list) : 'a list = 
    List.filteri (fun idx elt -> i <> idx) xs

  let rec shuffle (xs : 'a list) : 'a list R.t = 
    match xs with
    | [] -> R.return []
    | x :: s -> 
      let* r = R.random in
      let idx = r mod (List.length xs) in
      let hd = List.nth xs idx in
      let* tl = shuffle (remove idx xs) in 
      R.return (hd :: tl)

  let get_shuffled_list (xs : 'a list) (n : int) : 'a list = 
    R.run n (shuffle xs)
end

;; module M = Shuffle(RS)

;;  M.get_shuffled_list [1;2;3;4;5;6;7;8;9;10] 2 
;;  M.get_shuffled_list [1;2;3;4;5;6;7;8;9;10] 10 
;;  M.get_shuffled_list [1;2;3;4;5;6;7;8;9;10] 3787

