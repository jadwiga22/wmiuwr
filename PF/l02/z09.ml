type 'a clist = { clist : 'z. ('a -> 'z -> 'z) -> 'z -> 'z }

(* basic functions *)

let cnil = {clist = (fun f z -> z)}

let ccons a xs = { clist = (fun f z -> f a (xs.clist f z)) }

let map g xs = {clist = 
  (fun f z -> xs.clist (fun a z -> f (g a) z) z)}

let append xs ys = { clist = 
  (fun f z -> xs.clist f (ys.clist f z))}

let clist_to_list xs = 
  xs.clist (fun a z -> a :: z) []

let rec clist_of_list xs = 
  match xs with
  | [] -> cnil
  | x :: xs -> {clist = (fun f z -> f x ((clist_of_list xs).clist f z)) }

(* TESTS *)

let mylist = (ccons 1 (ccons 2 (ccons 3 cnil)))
let mylist2 = (ccons 4 (ccons 5 (ccons 6 cnil)))

;; assert ((cnil.clist (fun a b -> a :: b) []) = [])
;; assert (mylist.clist (fun a b -> a :: b) [] = [1;2;3])
;; assert (clist_to_list (map (fun x -> 1) mylist) = [1;1;1])
;; assert (clist_to_list (map (fun x -> 1 + x) mylist) = [2;3;4])
;; assert (((append mylist mylist2).clist (fun a b -> a :: b) []) = [1;2;3;4;5;6])
;; assert (((append mylist cnil).clist (fun a b -> a :: b) []) = [1;2;3])
;; assert (clist_to_list (clist_of_list [1;2;3]) = [1;2;3])
;; assert (clist_to_list (clist_of_list []) = [])


(* other functions *)

(* before reduction *)
(* let prod xs ys = { clist =
  (fun f z -> xs.clist (fun a za -> (ys.clist (fun b zb -> f (a, b) zb) za)) z)} *)

(* after reduction *)
let prod xs ys = { clist =
  (fun f -> xs.clist (fun a -> (ys.clist (fun b -> f (a, b)))))}

(* cartesian product of lists *)
;; assert (clist_to_list (prod mylist mylist2) = [(1, 4); (1, 5); (1, 6); (2, 4); (2, 5); (2, 6); (3, 4); (3, 5);(3, 6)])
;; assert (clist_to_list (prod mylist cnil) = [])


(* with definition like that the type of the result changes :( *)
(* let rec pow xs n = { clist = 
  if n = 1 then xs
  else prod xs (pow xs (n-1))} *)

  