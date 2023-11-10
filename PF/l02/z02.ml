let test cur ok = 
  if cur = ok then ()
  else print_endline "WRONG!" 

(* let rec sublists xs = 
  match xs with
  | [] -> [[]]
  | x :: xs -> let cur = sublists xs in 
      List.fold_right (fun a acc -> (x :: a) :: acc) cur cur  *)

let rec sublists ?(doklejanie_el=(fun x -> x)) ?(appendix=[]) xs = 
  match xs with
  | [] -> doklejanie_el [] :: appendix
  | x :: xs -> sublists xs ~doklejanie_el:(fun ls -> (doklejanie_el (x :: ls))) ~appendix:(sublists xs ~doklejanie_el ~appendix)



;; test (sublists [1;2;3]) [[1; 2; 3]; [1; 2]; [1; 3]; [1]; [2; 3]; [2]; [3]; []]
;; test (sublists []) [[]]
;; test (List.length (sublists [1;2;3;4;5])) 32


