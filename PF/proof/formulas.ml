(* types & modules --- *)

type var = string
type sym = string

type term = 
  | Var of var
  | Sym of sym * term list


type formula =
  | False
  | Imp of formula * formula
  | App of sym * term list
  | ForAll of var * formula

module VarMap = Map.Make(String)


(* printers --- *)

let rec string_of_term_list (ts : term list) : string = 
  let rec aux ts = 
    match ts with
    | [] -> ""
    | [t] -> t
    | t::ts -> t ^ ", " ^ aux ts
  in 
  ts |> List.map string_of_term |> aux

and string_of_term (t : term) : string = 
  match t with
  | Var v -> v
  | Sym(s, ts) -> s ^ "(" ^ string_of_term_list ts ^ ")"


let rec string_of_formula f =
  match f with
  | False -> "⊥"
  | Imp(l, r) ->
    let ls = string_of_formula l and rs = string_of_formula r in
    begin match l with
    | Imp _ -> "(" ^ ls ^ ") → " ^ rs 
    | _ -> ls ^ " → " ^ rs
    end
  | App(s, ts) -> s ^ "(" ^ string_of_term_list ts ^ ")"
  | ForAll(v, f) -> "∀" ^ v ^ ". " ^ string_of_formula f

let pp_print_formula fmtr f =
  Format.pp_print_string fmtr (string_of_formula f)


(* free variables --- *)

let rec free_in_term v t = 
  match t with
  | Var x -> v = x
  | Sym(_, ts) -> List.exists (free_in_term v) ts

let rec free_in_formula v f = 
  match f with
  | False -> false
  | Imp(f1, f2) -> 
    free_in_formula v f1 || free_in_formula v f2
  | App(s, ts) -> List.exists (free_in_term v) ts
  | ForAll(x, f) -> 
    if x = v then false
    else free_in_formula v f


(* fresh variable --- *)

let cnt = ref 0

let fresh_var (fs : formula list) (ts : term list) : var = 
  incr cnt ;
  while 
  (List.exists (fun f -> free_in_formula ("x" ^ (string_of_int !cnt)) f) fs) || 
  (List.exists (fun t -> free_in_term ("x" ^ (string_of_int !cnt)) t) ts)  do
    incr cnt ;
  done ; 
  ("x" ^ (string_of_int !cnt))


(* substitutions --- *)

let subst_one (v : var) (m : term VarMap.t) : term = 
  match VarMap.find_opt v m with
  | None   -> Var v
  | Some t -> t

let rec psubst_in_term m t =
  match t with
  | Var v -> subst_one v m
  | Sym(s, ts) -> Sym(s, List.map (psubst_in_term m) ts)


let term_list (m : term VarMap.t) : term list = 
  List.map snd (VarMap.bindings m)

let term_list_var (m : var VarMap.t) : term list = 
  List.map (fun x -> Var (snd x)) (VarMap.bindings m)

let rec psubst_in_formula m f = 
  match f with
  | False -> f
  | Imp(f1, f2) -> Imp(psubst_in_formula m f1, psubst_in_formula m f2)
  | App(s, ts) -> App(s, List.map (psubst_in_term m) ts)
  | ForAll(v, f) -> 
    let bs = term_list m in 
    begin match VarMap.find_opt v m with 
    | Some t -> ForAll(v, psubst_in_formula (VarMap.remove v m) f)
    | None when (List.for_all (fun x -> not (free_in_term v x)) bs) -> 
      ForAll(v, psubst_in_formula m f)
    | _ -> let z = fresh_var [f] bs in
      ForAll(z, psubst_in_formula (VarMap.add v (Var z) m) f)
    end
  

let subst_in_term x s t = psubst_in_term (VarMap.singleton x s) t

let subst_in_formula x s f = psubst_in_formula (VarMap.singleton x s) f


(* substitution and equivalence --- *)

let rec subst_eq_term m1 m2 t1 t2 = begin match t1, t2 with
  | Var v1, Var v2 -> begin 
    match VarMap.find_opt v1 m1, VarMap.find_opt v2 m2 with
    | Some s1, Some s2 when s1 = s2 -> true
    | None, None       when v1 = v2 -> true
    | Some s1, None    when s1 = v2 -> true
    | None, Some s2    when v1 = s2 -> true
    | _ -> false
    end
  | Sym(s1, ts1), Sym(s2, ts2) when s1 = s2 -> 
    List.for_all2 (subst_eq_term m1 m2) ts1 ts2
  | _ -> false
  end

let rec subst_eq_formula m1 m2 f1 f2 = begin match f1, f2 with
  | False, False -> true
  | Imp(g1, g2), Imp(h1, h2) -> 
    subst_eq_formula m1 m2 g1 h1 && subst_eq_formula m1 m2 g2 h2
  | App(s1, ts1), App(s2, ts2) when s1 = s2 ->
    List.for_all2 (subst_eq_term m1 m2) ts1 ts2
  | ForAll(s1, f1), ForAll(s2, f2) ->
    let z = fresh_var [f1;f2] ((term_list_var m1) @ (term_list_var m2))  in
    subst_eq_formula (VarMap.add s1 z m1) (VarMap.add s2 z m2) f1 f2
  | _ -> false
  end


(* equivalence --- *)

let eq_term t1 t2 = 
  subst_eq_term VarMap.empty VarMap.empty t1 t2

let eq_formula f1 f2 = 
  subst_eq_formula VarMap.empty VarMap.empty f1 f2