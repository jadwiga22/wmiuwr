module Id : sig
  type 'a t

  val return : 'a -> 'a t
  val bind   : 'a t -> ('a -> 'b t) -> 'b t

end = struct
  type 'a t = 'a

  let return x = x

  let bind e1 e2 =
    e2 e1
end

module Lazy : sig
  type 'a t

  val return : 'a -> 'a t
  val bind   : 'a t -> ('a -> 'b t) -> 'b t

end = struct
  type 'a t = unit -> 'a

  let return x = fun () -> x

  (* adding unit as an argument to delay *)
  let bind e1 e2 () =
    e2 (e1 ()) ()
end