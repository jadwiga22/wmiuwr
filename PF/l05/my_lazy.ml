type 'a state = 
| Promise of (unit -> 'a)
| Val of 'a
| Eval 

type 'a my_lazy =
  ('a state) ref

let force (l : 'a my_lazy) : 'a = 
  match (!l) with
  | Promise(f) ->
    l := Eval ;
    let v = f () in
    l := Val(v) ;
    v
  | Eval -> failwith "evaluating!"
  | Val(v) -> v


let fix (f : ('a my_lazy -> 'a)) : 'a my_lazy =
  let dummy = ref (ref Eval) in
  let res = ref (Promise(fun () -> f !dummy)) in
  dummy := res ; 
  res

(* ok   : (fun l -> force l) ;; *)
(* fail : force (fix (fun l -> force l)) ;;  *)

type 'a node = 
  | Nil
  | Cons of 'a * ('a llist)
and 'a llist = ('a node) my_lazy

let head (ll : 'a llist) : 'a = 
  match (force ll) with
  | Nil -> failwith "empty!"
  | Cons(x, _) -> x

let tail (ll : 'a llist) : 'a llist = 
  match (force ll) with
  | Nil -> failwith "empty!"
  | Cons(_, x) -> x

let stream_of_ones = fix (fun stream_of_ones -> Cons(1, stream_of_ones))

(* fix let us write recursive functions

   type of fix : (’a my_lazy -> ’a) -> ’a my_lazy
   so the most natural way to define nats would be
   to pass to fix function with type
   (int node) my_lazy -> (int node)
   then fix would return (int node) my_lazy = int llist

   but it doesn't work
   so we have to change the type of this function
*)

   
(* in nats_from n
   we pass to fix function with type
   (int -> int llist) my_lazy -> (int -> int llist)

   because we want to change one integer to llist of integers
   this int is first number in stream
*)
let nats_from (n : int) : int llist = 
  let nats_from : (int -> int llist) my_lazy  = 
    fix (fun (nats_from : (int -> int llist) my_lazy) -> 
          (fun k -> ref (Promise(fun () -> Cons(k, force nats_from (k+1))))))
  in force nats_from n

let nats = nats_from 0

(* in take_while 
   we pass to fix function with type
   ('a llist -> 'a llist) my_lazy -> ('a llist -> 'a llist)
   
   because we want to change one llist to another llist 
*)
let take_while (p : 'a -> bool) (xs : 'a llist) : 'a llist = 
  let take_while : ('a llist -> 'a llist) my_lazy  = 
    fix (fun (take_while : ('a llist -> 'a llist) my_lazy) -> 
          (fun (xs : 'a llist) : 'a llist -> 
            ref (Promise( fun () -> 
            begin match force xs with
              | Cons(x, xs) when p x ->  (Cons(x, force take_while xs))
              | _ -> Nil
          end))))
  in force take_while xs

(* in filter 
   we pass to fix function with type
   ('a llist -> 'a llist) my_lazy -> ('a llist -> 'a llist)
   
   because we want to change one llist to another llist 
*)
let filter (p : 'a -> bool) (xs : 'a llist) : 'a llist = 
  let filter : ('a llist -> 'a llist) my_lazy = 
    fix (fun (filter : ('a llist -> 'a llist) my_lazy) -> 
      (fun (xs : 'a llist) : 'a llist -> 
        ref (Promise(fun () -> begin match (force xs) with
          | Nil -> Nil
          | Cons(x, xs) when p x -> Cons(x, (force filter) xs)
          | Cons(_, xs) -> force ((force filter) xs)
        end))))
  in force filter xs

(* in primes 
   we pass to fix function with type
   (int llist -> int llist) my_lazy -> (int llist -> int llist)
   
   because we want to change one llist of integers to another llist of integers
   
   we are removing numbers divisible by the head
   using filter
*)
let primes : int llist = 
  let primes : (int llist -> int llist) my_lazy = 
    fix (fun (primes : (int llist -> int llist) my_lazy) -> 
      (fun (xs : int llist) : int llist ->
        ref (Promise( fun () ->
          begin match force xs with
          | Nil -> Nil
          | Cons(x, xs) -> Cons(x, force primes (filter (fun a -> a mod x <> 0) xs))
        end))))
  in
  (force primes) (nats_from 2)

(* in nth n xs 
   we pass to fix function with type
   (int -> 'a llist -> 'a) my_lazy -> (int -> 'a llist -> 'a)
   
   because we want to change int and llist to an element of that list
*)
let nth (n : int) (xs : 'a llist) : 'a = 
  let nth : (int -> 'a llist -> 'a) my_lazy = 
    fix (fun (nth : (int -> 'a llist -> 'a) my_lazy) -> 
      (fun (n : int) (xs : 'a llist) : 'a -> 
        begin match force xs with
        | Nil -> failwith "not found!"
        | Cons(x, xs) when n = 0 -> x
        | Cons(_, xs) -> (force nth) (n-1) xs
        end))
      
  in (force nth) n xs

;; assert ((nth 0 primes) = 2)
;; assert ((nth 5 primes) = 13)
;; assert ((nth 6 primes) = 17)
;; assert ((nth 57 primes) = 271)
