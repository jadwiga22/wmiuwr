open Lazy ;;

(* lazy doubly linked lists *)
type 'a dllist = 'a dllist_data lazy_t
and 'a dllist_data =
  { prev : 'a dllist
  ; elem : 'a
  ; next : 'a dllist
  }

let prev ds = 
  (force ds).prev 

let elem ds =
  (force ds).elem

let next ds = 
  (force ds).next

(* returns dllista_data containing x as an element *)
let rec dummy (x : 'a) : 'a dllist_data = 
  ({prev = lazy (dummy x); elem = x; next = lazy (dummy x)})

(* prev - previous dllist
   xs - current list
   first - dllist of the first element in the sequence 
   
   returns pair of dllists
   [current dllist, last dllist] *)
let rec aux_of_list (prev : 'a dllist) (xs : 'a list) (first : 'a dllist) : ('a dllist) * ('a dllist) = 
  match xs with
  | [] -> (first, prev)
  | x :: xs ->
    let last = ref (lazy (dummy x)) in
    let rec cur = lazy begin
      let (f, p) = aux_of_list cur xs first in
      last := p; 
      {prev = prev; elem = x; next = f}
    end in
    let res = force cur in  (* force to update last *)
    (lazy res, !last)

(* returns cyclic dllist *)
let of_list (xs : 'a list) : 'a dllist = 
  match xs with
  | [] -> failwith "empty"
  | x :: xs ->
    let rec first = lazy begin
      let (f, p) = aux_of_list first xs first in
      {prev = p; elem = x; next = f}
    end in first
  
;; let d = of_list [1] 
;; assert (elem d = 1) 
;; assert (prev (next d) == d)
;; assert (next (prev d) == d)

;; let d = of_list [1;2;3] 
;; assert (elem d = 1)  
;; assert (prev (next d) == d)
;; assert (next (prev d) == d)
;; assert (next (prev (next d)) == (next d))

let rec go_left (cur : int dllist) : int dllist = 
  let rec news = lazy begin
    {prev = (go_left news); elem = (elem cur)-1; next = cur}
  end in 
  news

let rec go_right (cur : int dllist) : int dllist = 
  let rec news = lazy begin
    {prev = cur; elem = (elem cur)+1; next = (go_right news)}
  end in 
  news

let integers : int dllist = 
  let rec first = lazy begin
    {prev = (go_left first); elem = 0; next = (go_right first)}
  end in
  first

;; assert (elem (next (next (prev (prev integers)))) = 0)
;; assert (elem (prev (prev (next (next integers)))) = 0)
;; assert (elem (next (next (next integers))) = 3)
;; assert (elem (prev (prev (prev (prev integers)))) = -4)
;; assert (integers == (prev (next integers)))
;; assert (integers == (next (prev integers)))
;; assert (integers == (next (next (prev (prev integers)))))
;; assert (integers == (prev (prev (next (next integers)))))
;; assert (integers == (prev (next (prev (prev (next (next integers)))))))