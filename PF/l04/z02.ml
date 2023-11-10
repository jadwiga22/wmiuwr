(*  idea reprezentacji: odwrócony prefiks i sufiks *)

type 'a zlist = 
  'a list * 'a list

let of_list (xs : 'a list) : 'a zlist = 
  ([], xs)

let to_list (zs : 'a zlist) : 'a list = 
  List.rev_append (fst zs) (snd zs)

let elem (zs : 'a zlist) : 'a option = 
  match zs with
  | (_, [])      -> None
  | (_, x :: xs) -> Some(x)

let move_left (zs : 'a zlist) : 'a zlist = 
  match zs with
  | (x :: xs, ys) -> (xs, x :: ys)
  | _             -> zs

let move_right (zs : 'a zlist) : 'a zlist = 
  match zs with
  | (xs, y :: ys) -> (y :: xs, ys)
  | _             -> zs

let insert (x : 'a) (zs : 'a zlist) : 'a zlist =
  (x :: fst zs, snd zs)

let remove (zs : 'a zlist) : 'a zlist = 
  match zs with
  | ([], ys)      -> zs
  | (x :: xs, ys) -> (xs, ys)



(* --------- testy --------- *)

let z = of_list [1;2;3]

;; assert (to_list z = [1;2;3])
;; assert (elem z = Some(1))
;; assert (elem (move_left z) = Some(1))
;; assert (elem (move_right (move_right z)) = Some(3))
;; assert (elem (move_right (move_right (move_right z))) = None)
;; assert (to_list (insert 4 (move_right z)) = [1;4;2;3])
;; assert (to_list (move_right (move_left z)) = [1;2;3])
;; assert (to_list (remove (move_right (move_right z))) = [1;3])
;; assert (to_list (move_right (move_right z)) = [1;2;3])
