let rec fix f x = f (fix f) x

let fib_f fib n =
  if n <= 1 then n
  else fib (n-1) + fib (n-2)

let fib1 = fix fib_f

let rec fix_with_limit (n : int) (f : (('a -> 'b) -> 'a -> 'b)) (x : 'a) : 'b =
  if n < 0 then failwith "exceeded max recursion depth"
  else f (fix_with_limit (n-1) f) x


let max_iter = 100000

(* fast! *)
let fix_memo (f : (('a -> 'b) -> 'a -> 'b))  =
  let cache = Hashtbl.create max_iter in
  let rec aux f x =
    match Hashtbl.find_opt cache x with 
    | None    -> let y = f (aux f) x in ((Hashtbl.add cache x y) ; y)
    | Some(y) -> y
  in aux f

(* slow - why? :( 
   just added x as an argument *)
(* let fix_memo (f : (('a -> 'b) -> 'a -> 'b)) x  =
  let cache = Hashtbl.create max_iter in
  let rec aux f x =
    match Hashtbl.find_opt cache x with 
    | None    -> let y = f (aux f) x in ((Hashtbl.add cache x y) ; y)
    | Some(y) -> y
  in aux f x *)

(* fast - but cache is shared :/ *)
(* let cache = Hashtbl.create max_iter
let rec fix_memo (f : (('a -> 'b) -> 'a -> 'b)) (x : 'a) : 'b =
  match Hashtbl.find_opt cache x with 
  | None    -> let y = f (fix_memo f) x in ((Hashtbl.add cache x y) ; y)
  | Some(y) -> y *)

let fib2 = fix_with_limit 10 fib_f
let fib3 = fix_memo fib_f

;; assert (fib2 10 = 55)
;; assert (fib2 11 = 89)

(* too deep recursion *)
(* ;; fib2 12 *)
(* ;; fib2 20 *)

let time f n =
  let t = Sys.time() in
  let fx = f n in
  Printf.printf "Execution time: %fs\n" (Sys.time() -. t)


;; time fib3 max_iter
;; time fib3 max_iter
;; time fib3 max_iter

