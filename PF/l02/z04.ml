(* additional *)

let list n = 
  let rec it cur acc = 
    if cur = 0 then acc
    else (it (cur - 1) (cur :: acc))
  in it n []

(* task 4 *)

let rec merge f xs ys = 
  match xs,ys with
  | [], ys -> ys
  | xs, [] -> xs
  | x :: xs, y :: ys -> if f x y then x :: (merge f xs (y :: ys))
                        else y :: (merge f (x :: xs) ys)

(* let mergeTail f xs ys = 
  let rec it xs ys merged =
    match xs, ys with
    | [], ys -> List.append merged ys
    | xs, [] -> List.append merged xs
    | x :: xs, y :: ys -> if f x y then (it xs (y :: ys) (List.append merged [x]))
                                   else (it (x :: xs) ys (List.append merged [y]))
    in it xs ys [] *)

let mergeTail f xs ys = 
  let rec it xs ys merged =
    match xs, ys with
    | [], [] -> List.rev merged
    | [], y :: ys -> it xs ys (y :: merged)
    | x :: xs, [] -> it xs ys (x :: merged)
    | x :: xs, y :: ys -> if f x y then (it xs (y :: ys) (x :: merged))
                                   else (it (x :: xs) ys (y :: merged))
    in it xs ys []


let mergeTailCPS f xs ys = 
  (* cont mowi co dokleic do wyniku *)
  let rec it xs ys cont = 
    match xs, ys with
    | [], ys -> cont ys
    | xs, [] -> cont xs
    | x :: xs, y :: ys -> if f x y then (it xs (y :: ys) (fun a -> cont (x :: a)))
                                   else (it (x :: xs) ys (fun a -> cont (y :: a)))
    in it xs ys (fun x -> x)


let rec halve xs = 
  match xs with
  | [] -> ([], [])
  | x :: [] -> ([x], [])
  | x :: y :: xs -> let (x1, x2) = halve xs in (x :: x1, y :: x2)


let rec mergesort f xs =
  match xs with
  | [] -> []
  | [x] -> [x]
  | _ -> 
    let (x1, x2) = halve xs in
    mergeTail f (mergesort f x1) (mergesort f x2)  


(* task 5 *)

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

;; assert (mergesort2 (<=) [1;2;3] = [1;2;3])
;; assert (mergesort2 (<=) (List.append (List.rev (list 6)) (List.rev (list 5))) = [1; 1; 2; 2; 3; 3; 4; 4; 5; 5; 6])
;; assert (mergesort2 (<=) [10; 3; 5; 1; 4; 9; 2; 11; 15; 14; 7; 12; 6; 8; 13] = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15])
;; assert (mergesort2 (<=) [1;2] = [1;2])
;; assert (mergesort2 (<=) [] = [])
;; assert (mergesort2 (<=) [1] = [1])

(* ---------------------- TESTS ---------------------- *)

;; assert ((merge (<=) [1; 2; 5] [3; 4; 5]) = [1; 2; 3; 4; 5; 5])
;; assert ((merge (<=) [] [1;2;3]) = [1;2;3])
;; assert ((merge (<=) [1;2;3] []) = [1;2;3])
;; assert ((merge (<=) [] []) = [])

;; assert ((mergeTail (<=) [1; 2; 5] [3; 4; 5]) = [1; 2; 3; 4; 5; 5])
;; assert ((mergeTail (<=) [] [1;2;3]) = [1;2;3])
;; assert ((mergeTail (<=) [1;2;3] []) = [1;2;3])
;; assert ((mergeTail (<=) [] []) = [])

;; assert ((mergeTailCPS (<=) [1; 2; 5] [3; 4; 5]) = [1; 2; 3; 4; 5; 5])
;; assert ((mergeTailCPS (<=) [] [1;2;3]) = [1;2;3])
;; assert ((mergeTailCPS (<=) [1;2;3] []) = [1;2;3])
;; assert ((mergeTailCPS (<=) [] []) = [])

;; assert ((halve [1;2;3;4]) = ([1;3], [2;4]))
;; assert ((halve [1;2;3]) = ([1;3], [2]))
;; assert ((halve [1] = ([1], [])))
;; assert ((halve []) = ([], []))
;; assert ((halve (list 10)) = ([1;3;5;7;9], [2;4;6;8;10]))

;; assert ((mergesort (<=) [2;3;8;1;3;0;2;3;1]) = [0;1;1;2;2;3;3;3;8])
;; assert ((mergesort (<=) []) = [])
;; assert ((mergesort (<=) [1]) = [1])
;; assert ((mergesort (<=) [7;6;5;4]) = [4;5;6;7])
;; assert ((mergesort (<=) (List.rev (list 10000))) = list 10000)

(* -------------------- TIME TESTS -------------------------- *)

(* let time f cmp x y =
  let t = Sys.time() in
  let fx = f cmp x y in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t)

let time2 f cmp xs =
  let t = Sys.time() in
  let fx = f cmp xs in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t) *)

(* ;; print_int 1000
;; time merge (<=) (list 1000) (list 1000) 
;; time mergeTail (<=) (list 1000) (list 1000)  *)
(* ;; time mergeTailCPS (<=) (list 1000) (list 1000)  *)

(* ;; print_int 50000
;; time merge (<=) (list 50000) (list 50000) 
;; time mergeTail (<=) (list 50000) (list 50000)  *)
(* ;; time mergeTailCPS (<=) (list 50000) (list 50000)  *)

(* merge sa porownywalne - roznie wychodzi czas *)

(* ;; print_int 1000
;; time2 mergesort (<=) (List.rev (list 1000))
;; time2 mergesort2 (<=) (List.rev (list 1000))

;; print_int 50000
;; time2 mergesort (<=) (List.rev (list 50000))
;; time2 mergesort2 (<=) (List.rev (list 50000)) *)

(* mergesort2 jest ok. 1.5-2 razy wolniejszy niz mergesort (uzywajacy funkcji merge lub mergeTail) *)


