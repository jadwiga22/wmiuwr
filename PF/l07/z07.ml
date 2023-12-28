module SBT(State : sig type t end) : sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val fail : 'a t
  val flip : bool t
  val get : State.t t
  val put : State.t -> unit t
  val run : State.t -> 'a t -> 'a Seq.t
end = struct
  (* changing definition of the type -> Nil also has state *)
  type 'a t = State.t -> 'a sbt_list
  and 'a sbt_list =
  | Nil  of State.t
  | Cons of 'a * State.t * 'a t
  (* state after the execution *)

  let fail s = Nil s

  let return x s = Cons(x, s, fail)

  let rec append (xs : 'a t) (ys : 'a t) (s : State.t) : 'a sbt_list = 
    match xs s with
    | Nil s -> ys s
    | Cons(a, s, xs) -> Cons(a, s,  append xs ys)

  let rec bind (m : 'a t) (f : 'a -> 'b t) (s : State.t) : 'b sbt_list =
    match m s with
    | Nil s -> Nil s
    | Cons(a, s, m) -> append (f a) (bind m f) s


  (* not reverting state!!! *)
  let flip s =
    Cons(true, s, fun s -> Cons(false, s, fail))

  let get s = Cons(s, s, fail)

  let put s _ = 
    Cons((), s, fail)

  let rec run s m () = 
    match m s with
    | Nil s -> Seq.Nil
    | Cons(a, s, m) -> Seq.Cons(a, run s m)
    
end

(* module SBT(State : sig type t end) : sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val fail : 'a t
  val flip : bool t
  val get : int t
  val put : int -> unit t
  val run : int -> 'a t -> 'a Seq.t
end = struct
  type 'a t = int -> 'a sbt_list
  and 'a sbt_list =
  | Nil
  | Cons of 'a * int * 'a t
  (* state after the execution *)

  let return x s = Cons(x, s, fun s -> Nil)

  let rec append (xs : 'a t) (ys : 'a t) (s : int) : 'a sbt_list = 
    match xs s with
    | Nil -> ys s
    | Cons(a, s, xs) -> Cons(a, s,  append xs ys)

  let rec bind (m : 'a t) (f : 'a -> 'b t) (s : int) : 'b sbt_list =
    match m s with
    | Nil -> Nil
    | Cons(a, s, m) -> append (f a) (bind m f) s

  let fail s = Nil

  (* not reverting state!!! *)
  let flip s =
    Cons(true, s, fun s -> Cons(false, s, fun s -> Nil))

  let get s = Cons(s, s, fun s -> Nil)

  let put s _ = 
    Cons((), s, fun s -> Nil)

  let rec run s m () = 
    match m s with
    | Nil -> Seq.Nil
    | Cons(a, s, m) -> print_int s ; print_string " " ; Seq.Cons(a, run s m)
    
end *)

module M = SBT(Int)

let (let* ) = M.bind

let expr = 
  let* _ = M.put 13 in
    let* c = M.flip in
    if c then 
      let* _ = M.put 42 in M.fail
    else
      M.get
  
;; M.run 0 expr |> List.of_seq ;;

let rec select a b =
  if a >= b then M.fail
  else
    let* c = M.flip in
    if c then M.return a
    else select (a+1) b

let triples n =
  let* a = select 1 n in
  let* b = select a n in
  let* c = select b n in
  let* s = M.get in
  let* p = M.put (s+1) in
  if a*a + b*b = c*c then M.return (a, b, c)
  else M.fail

;; M.run 0 (triples 40) |> List.of_seq;;