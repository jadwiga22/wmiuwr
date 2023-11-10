type 'a t = 
  | Leaf 
  | Node of 'a t * 'a * int * 'a t

let empty = Leaf

let minheap h = 
  match h with
  | Leaf -> 42
  | Node(l,x,len,r) -> x

let rightlength v = 
  match v with
  | Leaf -> 0
  | Node(l,x,len,r) -> len

  (* mozna  nazwac node - bo to smart constructor *)
let create v1 v2 x = 
  let r1 = rightlength v1 and r2 = rightlength v2 in
  if r1 >= r2 then Node(v1, x, r2 + 1, v2)
  else  Node(v2, x, r1 + 1, v1)

let rec merge v1 v2 = 
  match v1, v2 with
  | Leaf, v2 -> v2
  | v1, Leaf -> v1
  | Node(v1l,x1,r1,v1r), Node(v2l,x2,r2,v2r) ->
    if x1 < x2 then create v1l (merge v1r v2) x1
    else create v2l (merge v2r v1) x2

let insert v1 x = 
  merge v1 (create empty empty x)

let erasemin v =
  match v with
  | Leaf -> Leaf
  | Node(l,x,len,r) -> merge l r

;; assert (erasemin (insert (insert empty 7) 8) = insert empty 8)
;; assert (erasemin (erasemin (erasemin (insert (insert (insert empty 2) 3) 1))) = empty)

