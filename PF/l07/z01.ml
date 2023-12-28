module type RandomMonad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val random : int t
end


module Shuffle(R : RandomMonad) : sig
  val shuffle : 'a list -> 'a list R.t
end = struct
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
    
end