type var = string
type sym = string

type term = 
  | Var of var
  | Sym of sym * term list

module VarMap : sig 
    include Map.S
end

type formula =
  | False
  | Imp of formula * formula
  | App of sym * term list
  | ForAll of var * formula


(* converting formula to string *)
val string_of_formula : formula -> string

(* printing formula *)
val pp_print_formula : Format.formatter -> formula -> unit

(* free variables in term *)
val free_in_term : var -> term -> bool

(* free variables in formula *)
val free_in_formula : var -> formula -> bool

(* substitution in term *)
val subst_in_term : var -> term -> term -> term

(* substitution in formula *)
val subst_in_formula : var -> term -> formula -> formula

(* substitution and equivalence of terms *)
val subst_eq_term : var VarMap.t -> var VarMap.t -> term -> term -> bool

(* substitution and equivalence of formulas *)
val subst_eq_formula : var VarMap.t -> var VarMap.t -> formula -> formula -> bool

(* equivalence of terms *)
val eq_term : term -> term -> bool

(* equivalence of formulas *)
val eq_formula : formula -> formula -> bool

(* fresh variable *)
val fresh_var :  formula list -> term list -> var