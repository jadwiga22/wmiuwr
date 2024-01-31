open Formulas ;;

type axiom =
  | EqRefl (* ∀x.x = x *)
  | EqElim of var * formula (* ∀y.∀z.y = z ⇒ φ{x → y} ⇒ φ{x → z} *)
  | PlusZ (* ∀n.0 + n = n *)
  | PlusS (* ∀n.∀m.S(n) + m = S(n + m) *)
  | Induction of var * formula

val axiom : axiom -> formula