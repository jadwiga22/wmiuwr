(* let rec fix f x = f (fix f) x *)

let id =
  ref (fun f -> failwith "error")

let fix1 f x =
  f ((!id) f) x

let () = id := fix1

let fib_f fib n =
  if n <= 1 then n
  else fib (n-1) + fib (n-2)

let fib1 = fix1 fib_f

(* https://en.wikipedia.org/wiki/Fixed-point_combinator *)

(* 
   we can have infinite loop
   (fun x -> x x) (fun x -> x x)

   but it does nothing; so we add a function there

   (fun x -> f (x x)) (fun x -> f (x x))

   and now we have f(f(f(f(f(...))))) 
   - so exactly what the fixed point combinator does

   so: we have to do sth like

   let fix f z =
    (fun x z -> f (x x) z) (fun x z -> f (x x) z) z

  but type error occurs - type of x is recursive,
  so we add recursive type
*)

(* x will have type 'a recursion *)
(* x is a function that returns sth - 
   let's call it 'a
   and takes itself as a parameter
   so the type of the parameter is the same
   as the type of x *)
type 'a recursion = 
  | In of ('a recursion -> 'a) 

(* unpacking x - to apply it to itself *)
let out (In(x)) = x

let fix2 f z = 
  (fun x z -> f (out x x) z) (In(fun x z -> f (out x x) z)) z

let fib2 = fix2 fib_f 

;; assert (fib1 10 = 55) 
;; assert (fib2 10 = 55)

(* notes: 

  let fix f =  g
   g = f g
   h := half of g
   i.e. ->  g = h h 
   
   h h = f (h h)
   
   let fix f = let h h = f (h h) in h h
   
   adding an argument:   
   let fix f = let h h x = f (h h) x in h h*)
