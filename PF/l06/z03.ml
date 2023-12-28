exception Stop_fold 

let for_all (p : 'a -> bool) (xs : 'a list) : bool = 
  try
  List.fold_left 
  (fun acc x -> if p x then true else raise Stop_fold)
  true
  xs
  with
  | Stop_fold -> false
  | e -> raise e

let mult_list (xs : int list) : int = 
  try
    List.fold_left 
    (fun acc x -> 
      let nxt = acc * x in
      if nxt = 0 then raise Stop_fold
      else nxt)
    1
    xs
    with
    | Stop_fold -> 0
    | e -> raise e

let sorted (xs : int list) : bool =
  try
    begin match List.fold_left 
    (fun acc x -> 
      begin match acc with
      | None -> Some x
      | Some y -> if y <= x then Some(x) else raise Stop_fold
      end )
    None xs with
    | _ -> true
    end
  with
  | Stop_fold -> false
  | e -> raise e

let ls = 
  [lazy 2 ; lazy 3; lazy (1/0)]

;; assert (for_all (fun x -> Lazy.force x = 2) ls = false)
;; assert (for_all (fun x -> x = true) [false;false;false] = false)
;; assert (for_all (fun x -> x = false) [false;false;false] = true)

;; assert (mult_list [] = 1)
;; assert (mult_list [2;3;1;0;4;2;5] = 0)
;; assert (mult_list [1;2;3;4;5] = 120)

;; assert (sorted [] = true)
;; assert (sorted [1] = true)
;; assert (sorted [1;2;3;4;5;6] = true)
;; assert (sorted [2;1;3;4;5] = false)
;; assert (sorted [1;2;3;4;6;5] = false)

let rec my_list n =
  if n <= 0 then []
  else false :: my_list (n-1)

;; let ls = my_list 100000 in
    for i = 0 to 1000 do
      if for_all (fun x -> x = true) ls 
      then ()
      else ()
    done