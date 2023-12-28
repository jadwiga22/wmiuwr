(* lazy trees *)
type 'a tree =
  | Leaf
  | Node of ('a lazy_tree) * 'a * ('a lazy_tree)
and 'a lazy_tree = ('a tree) Lazy.t

(* returns value in root *)
let get_val t = 
  match Lazy.force t with
  | Leaf -> failwith "no value in leaf"
  | Node(l, a, r) -> a

(* returns subtree with x as a root, uses cmp as comparator
   (assuming bst structure)
   fails if x is not in tree *)
let rec go (t : 'a lazy_tree) (x : 'a) (cmp : 'a -> 'a -> bool) : 'a lazy_tree = 
  match Lazy.force t with
  | Leaf -> failwith "not found"
  | Node(l, a, r) -> 
    if cmp x a then go l x cmp
    else if cmp a x then go r x cmp
    else t

(* returns left subtree *)
let go_left (t : 'a lazy_tree) : 'a lazy_tree = 
  match Lazy.force t with 
  | Leaf -> failwith "go left"
  | Node(l, a, r) -> l

(* returns right subtree *)
let go_right (t : 'a lazy_tree) : 'a lazy_tree = 
  match Lazy.force t with 
  | Leaf -> failwith "go right"
  | Node(l, a, r) -> r

(* maps every node in t with f *)
let rec tree_map (t : 'a lazy_tree) (f : 'a -> 'b) : 'b lazy_tree = 
  lazy begin match Lazy.force t with
  | Leaf          -> Leaf
  | Node(l, a, r) -> Node(tree_map l f, f a, tree_map r f)
  end

(* rational numbers tree *)

(* returns "middle" of the interval *)
let get_middle ((a,b), (c,d)) = 
  (a+c, b+d)

type fraction = int * int
type interval = fraction * fraction

(* returns interval in left subtree *)
let get_left ((a,b), (c,d)) =
  ((a,b), get_middle ((a,b), (c,d)))

(* returns interval in right subtree *)
let get_right ((a,b), (c,d)) = 
  (get_middle ((a,b), (c,d)), (c,d))

let rec q_tree_from (ints : interval) : fraction lazy_tree = 
  lazy (Node(q_tree_from (get_left ints), get_middle ints, q_tree_from (get_right ints)))

let qt = q_tree_from ((0,1), (1,0))

;; get_val (go_right (go_right (go_left (go_left (go_left qt)))))