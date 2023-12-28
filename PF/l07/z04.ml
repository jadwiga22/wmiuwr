module type Monad = sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module Err : sig
  include Monad
  val fail : 'a t
  val catch : 'a t -> (unit -> 'a t) -> 'a t
  val run : 'a t -> 'a option
end = struct
  type 'r ans = 'r option 
  type 'a t = { run : 'r. ('a -> 'r ans) -> 'r ans}

  let return x = {run = fun cont -> cont x}

  let bind (m : 'a t) (f : 'a -> 'b t) : 'b t =
    {run = fun cont ->
      m.run (fun a -> (f a).run cont)}

  let fail = 
    {run = fun cont -> None}
    
  let catch m f = 
    match m.run (fun v -> Some v) with
    | None -> f ()
    | Some v -> return v

  let run e = 
    e.run (fun x -> Some x)
end


module BT : sig
  include Monad
  val fail : 'a t
  val flip : bool t
  val run : 'a t -> 'a Seq.t
end = struct
  type 'r ans = 'r Seq.t 
  type 'a t = { run : 'r. ('a -> 'r ans) -> 'r ans}

  let return x = {run = fun cont -> cont x}

  let bind (m : 'a t) (f : 'a -> 'b t) : 'b t =
    {run = fun cont ->
      m.run (fun a -> (f a).run cont)}
    (* let mx = m.run (fun x -> Seq.empty) in
    {run = fun cont -> 
      Seq.flat_map (fun x -> (f x).run cont) mx} *)

  let fail = 
    {run = fun cont -> Seq.empty}
    
  let flip = 
    {run = fun cont -> Seq.concat_map cont (List.to_seq [ true; false ])}

  let run e = 
    e.run (fun a -> List.to_seq [a])
end


module St(State : sig type t end) : sig
  include Monad
  val get : State.t t
  val set : State.t -> unit t
  val run : State.t -> 'a t -> 'a
end = struct
  type 'r ans = State.t -> 'r * State.t
  type 'a t = { run : 'r. ('a -> 'r ans) -> 'r ans}

  let return x =
    {run = fun cont -> cont x}

  let bind m f = 
    {run = fun cont ->
      m.run (fun a -> (f a).run cont)}
      (* let mx = m.run (fun x -> fun s -> (x, s)) in 
      fun s -> (f (fst (mx s))).run cont s} *)

  let get = 
    {run = fun cont s -> cont s s}

  let set s = 
    {run = fun cont -> (fun _ -> (fst (cont () s), s))}

  let run s m = 
    fst (m.run (fun x s -> (x, s)) s)
end

let (let* ) = BT.bind

let rec select a b =
  if a >= b then BT.fail
  else
    let* c = BT.flip in
    if c then BT.return a
    else select (a+1) b

let triples n =
  let* a = select 1 n in
  let* b = select a n in
  let* c = select b n in
  if a*a + b*b = c*c then BT.return (a, b, c)
  else BT.fail