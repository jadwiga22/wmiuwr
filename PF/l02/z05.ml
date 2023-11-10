(* task 5 *)

let rec halve xs = 
  match xs with
  | [] -> ([], [])
  | x :: [] -> ([x], [])
  | x :: y :: xs -> let (x1, x2) = halve xs in (x :: x1, y :: x2)

let mergeTail2 f xs ys = 
  let rec it xs ys merged =
    match xs, ys with
    | [], [] -> merged
    | [], y :: ys -> it xs ys (y :: merged)
    | x :: xs, [] -> it xs ys (x :: merged)
    | x :: xs, y :: ys -> if f x y then (it xs (y :: ys) (x :: merged))
                                   else (it (x :: xs) ys (y :: merged))
    in it xs ys []

let rec mergesort2 f xs = 
  match xs with
  | [] -> []
  | [x] -> [x]
  (* | [x; y] -> if f x y then [x; y] else [y; x] *)
  | _ -> 
    let (x1, x2) = halve xs in
    mergeTail2 (fun x y -> not (f x y)) (mergesort2 (fun x y -> not (f x y)) x1) (mergesort2 (fun x y -> not (f x y)) x2)  
