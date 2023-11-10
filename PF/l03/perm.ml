module type OrderedType = sig
  type t
  val compare : t -> t -> int
end

module type S = sig
  type key
  type t
  (** permutacja jako funkcja *)
  val apply : t -> key -> key
  (** permutacja identycznościowa *)
  val id : t
  (** permutacja odwrotna *)
  val invert : t -> t
  (** permutacja która tylko zamienia dwa elementy miejscami *)
  val swap : key -> key -> t
  (** złożenie permutacji (jako złożenie funkcji) *)
  val compose : t -> t -> t
  (** porównywanie permutacji *)
  val compare : t -> t -> int
end

module Make(Elt : OrderedType) = struct
  module M = Map.Make(Elt)
  type key = Elt.t
  type t = (key M.t) * (key M.t)

  let apply p x =
     match M.find_opt x (fst p) with
     | None -> x
     | Some(v) -> v

  let id = (M.empty, M.empty)

  let invert p = (snd p, fst p)

  let swap a b = 
    let inv = M.add b a (M.add a b M.empty)
  in (inv, inv)

  let compose p s = 
    (M.merge (fun k fp fs -> 
      let v = apply p (apply s k) in
      if v = k then None
      else Some(v))
      (fst p) (fst s),
    M.merge (fun k fp fs -> 
      let v = apply (invert s) (apply (invert p) k) in
      if v = k then None
      else Some(v))
      (snd s) (snd p))

  let compare p s = 
    M.compare Elt.compare (fst p) (fst s)
end
