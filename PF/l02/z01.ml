let test cur ok = 
  if cur = ok then ()
  else print_endline "WRONG!"


(* left jest ogonowy!!! więc lepiej fold_left *)
let length = List.fold_left (fun acc x -> (acc + 1)) 0 

;; test (length [1;2;3]) 3
;; test (length []) 0
;; test (length [7]) 1

let rev = List.fold_left (fun acc x -> x :: acc) []

;; test (rev [1;2;3]) [3;2;1]
;; test (rev []) []
;; test (rev [3;7;1;4]) [4;1;7;3]

let map f xs = List.fold_right (fun x acc -> (f x) :: acc) xs []

;; test (map (fun x -> 1) [1;2;3]) [1;1;1]
;; test (map (fun x -> (x+1)) [1;2;3]) [2;3;4]
;; test (map (fun x -> 1) []) []

let append = List.fold_right (fun x acc -> x :: acc) 

;; test (append [1;2;3] [4;5]) [1;2;3;4;5]
;; test (append [1;2;3] []) [1;2;3]
;; test (append [] [1;2;3]) [1;2;3]
;; test (append [] []) []

let rev_append xs ys = List.fold_left (fun acc x -> x :: acc) ys xs

;; test (rev_append [1;2;3] [4;5]) [3;2;1;4;5]
;; test (rev_append [] [4;5]) [4;5]
;; test (rev_append [1;2;3] []) [3;2;1]
;; test (rev_append [] []) []


let filter pred xs = 
  List.fold_right (fun x acc -> if pred x then x :: acc else acc) xs []

;; test (filter (fun x -> x = 2) [1;2;3;2]) [2;2]
;; test (filter (fun x -> x > 3) [3;4;1;5;7;2;2;1]) [4;5;7]
;; test (filter (fun x -> x > 3) []) []

let rev_map f = List.fold_left (fun acc x -> f x :: acc) []

;; test (rev_map (fun x -> -x) [1;2;3]) [-3;-2;-1]
;; test (rev_map (fun x -> -x) []) []
;; test (rev_map (fun x -> x + 1) [1;2;3]) [4;3;2]