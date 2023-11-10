(* task 3 *)

let hd s = (s 0)

let tl s = (fun x -> (s (x + 1)))

let add s a = (fun x -> (a + (s x)))

let map s f = (fun x -> (f (s x)))

let replace s n a = 
  (fun x -> 
    if x == n then a
    else (s x))


let take_every s n = 
  (fun x ->
    (s (x * n)))


let natural x = x
let ones x = 1
let quad x = (x * x)

let test a b = 
  if a == b then print_endline "OK"
  else print_endline "WRONG!"


(* ;; test (hd ones) 1
;; test (hd (tl (tl natural))) 2
;; test (hd (tl (add natural 7))) 8
;; test (hd (tl (tl (tl (add quad 10))))) 19
;; test (replace natural 7 10 7) 10
;; test ((replace natural 7 10) 100) 100
;; test ((take_every quad 2) 7) 196 *)
;;

(* task 4 *)

let scan f a s = 
  let rec news x =
    if x == 0 then (f a (s 0))
    else (f (news (x - 1)) (s x)) 
  in news

(* wersja z cwiczen! *)
(* let rec scan f a s x = 
    if x = 0 then (f a (s 0))
    else (f (scan f a s (x - 1)) (s x)) *)


;; test ((scan (+) 0 natural) 5) 15
;; test ((scan (+) 0 natural) 0) 0
;; test ((scan (+) 0 natural) 100) 5050

(* task 5 *)

let rec tabulate s ?(beg=0) en = 
  if beg > en then []
  else (s beg) :: (tabulate s ~beg:(beg + 1) en)

let test_list xs ys =
  if List.equal (=) xs ys then print_endline "LIST OK"
  else print_endline "LIST WRONG!"

(* ;; let () = List.iter (Printf.printf "%d ") (tabulate natural 7) *)
;; test_list (tabulate natural 7) [0;1;2;3;4;5;6;7]
;; test_list (tabulate natural ~beg:100 105) [100;101;102;103;104;105]
;; test_list (tabulate ones 3) [1;1;1;1]

(* nazwane parametry *)
(* let foo ~x = 0 *)