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
  type 'a t = State.t -> ('a * State.t) Seq.t

  let return x s = List.to_seq [(x,s)]

  let bind m f s =
    Seq.flat_map (fun (a, s) -> (f a s)) (m s)

  let fail s = Seq.empty

  (* reverting state!!! *)
  let flip s = 
    List.to_seq [(true, s); (false, s)]

  let get s = List.to_seq [(s,s)]

  let put s _ = 
    List.to_seq [((), s)]

  let run s m = 
    Seq.map fst (m s)
end

(* version with printing state *)

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
  type 'a t = int -> ('a * int) Seq.t

  let return x s = List.to_seq [(x,s)]

  let bind m f s =
    Seq.flat_map (fun (a, s) -> (f a s)) (m s)

  let fail s = Seq.empty

  (* reverting state!!! *)
  let flip s = 
    List.to_seq [(true, s); (false, s)]

  let get s = List.to_seq [(s,s)]

  let put s _ = 
    List.to_seq [((), s)]

  let run s m = 
    Seq.map (fun (a,s) -> print_int s ; print_string " " ; a) (m s)
end

module M = SBT(Int)


let (let* ) = M.bind

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
  else M.fail *)