let test cur ok = 
  if cur = ok then ()
  else print_endline "WRONG!" 

let suffixes xs = 
  List.fold_right (fun x acc -> (x :: List.hd acc) :: acc) xs [[]]

;; test (suffixes [1;2;3]) [[1; 2; 3]; [2; 3]; [3]; []]
;; test (suffixes []) [[]]
;; test (suffixes [1]) [[1]; []]

(* let prefixes xs = List.fold_right (fun x acc -> [] :: (List.map (fun a -> x :: a) acc)) xs [[]] *)


(* f mowi o tym, co trzeba dokleic z przodu list wynikowych *)
let rec prefixes ?(f=(fun x -> x)) xs = 
  match xs with
  | [] -> [f []]
  | x :: xs -> (f []) :: (prefixes xs ~f:(fun a -> f (x :: a)))


;; test (prefixes [1;2;3]) [[]; [1]; [1; 2]; [1; 2; 3]]
;; test (prefixes []) [[]]
;; test (prefixes [1]) [[]; [1]]
