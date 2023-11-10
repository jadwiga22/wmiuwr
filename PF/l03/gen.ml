(* module type OrderedType = sig
  type t
  val compare : t -> t -> int
end *)

module type P = sig
  (* type key *)
  type t
  (** permutacja jako funkcja *)
  (* val apply : t -> key -> key *)
  (** permutacja identycznościowa *)
  val id : t
  (** permutacja odwrotna *)
  val invert : t -> t
  (** permutacja która tylko zamienia dwa elementy miejscami *)
  (* val swap : key -> key -> t *)
  (** złożenie permutacji (jako złożenie funkcji) *)
  val compose : t -> t -> t
  (** porównywanie permutacji *)
  val compare : t -> t -> int
end

module type S = sig
  type t
  val is_generated : t -> t list -> bool
end

module Make(Prm : P) = struct
  type t = Prm.t
  module M = Set.Make(Prm)

  let is_generated p xs = 
    let next xn = 
      M.fold 
        (fun x a -> 
          M.union (M.map (fun y -> Prm.compose x y) xn) a)
        xn 
        (M.fold (fun x -> M.add (Prm.invert x)) xn xn)
    in
    let rec aux xn =
      match M.find_opt p xn with
      | None -> let xn1 = next xn in
                if M.equal xn xn1 then false
                else aux xn1
      | _ -> true
    in aux (M.add Prm.id (M.of_list xs))
end
