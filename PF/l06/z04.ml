let rec fold_left_cps (f : ('a -> 'b -> ('a -> 'c) -> 'c)) (acc : 'a) (xs : 'b list) (cont : 'a -> 'c) : 'c = 
  match xs with
  | x :: xs ->  f acc x (fun res -> fold_left_cps f res xs cont)
  | [] -> cont acc

let fold_left (f : ('a -> 'b -> 'a)) (acc : 'a) (xs : 'b list) : 'a = 
  fold_left_cps (fun acc x cont -> cont (f acc x)) acc xs (fun x -> x)

let for_all (p : 'a -> bool) (xs : 'a list) : bool = 
  fold_left_cps
  (fun acc x cont -> if p x then cont acc else false)
  true
  xs
  (fun x -> x)

let mult_list (xs : int list) : int = 
  fold_left_cps
  (fun acc x cont -> if x = 0 then 0 else cont (acc * x))
  1
  xs
  (fun x -> x)

let sorted (xs : int list) : bool =
  fold_left_cps
  (fun acc x cont ->
    match acc with
    | None -> cont (Some(x))
    | Some(acc) -> 
      if acc > x then false
      else cont (Some(x)))
  None
  xs
  (fun x -> true)

let rec my_list n =
  if n <= 0 then []
  else false :: my_list (n-1)

(* ;; let ls = my_list 100000 in
    for i = 0 to 1000 do
      if List.fold_left (fun acc x -> acc && x = true) true ls 
      then ()
      else ()
    done *)

;; let ls = my_list 100000 in
    for i = 0 to 1000 do
      if for_all (fun x -> x = true) ls 
      then ()
      else ()
    done


;; assert (fold_left (fun acc x -> x :: acc) [] [1;2;3] = [3;2;1])

;; assert (for_all (fun x -> Lazy.force x = 2) ls = false)
;; assert (for_all (fun x -> x = true) [false;false;false] = false)
;; assert (for_all (fun x -> x = false) [false;false;false] = true)

;; assert (mult_list [2;3;1;0;4;2;5] = 0)
;; assert (mult_list [1;2;3;4;5] = 120)

;; assert (sorted [] = true)
;; assert (sorted [1] = true)
;; assert (sorted [1;2;3;4;5;6] = true)
;; assert (sorted [2;1;3;4;5] = false)
;; assert (sorted [1;2;3;4;6;5] = false)
