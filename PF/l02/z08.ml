open Heap 
;; 

let rec tolist h =
  if h = empty then []
  else minheap h :: tolist (erasemin h)

let heapsort xs = 
  tolist (List.fold_left insert empty xs)


;; assert ((heapsort [2;1;6;2;7;0]) = [0;1;2;2;6;7])
;; assert ((heapsort [3;2;1]) = [1;2;3])
;; assert ((heapsort []) = [])