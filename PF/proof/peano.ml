open Formulas ;;

type axiom =
  | EqRefl (* ∀x.x = x *)
  | EqElim of var * formula (* ∀y.∀z.y = z ⇒ φ{x → y} ⇒ φ{x → z} *)
  | PlusZ (* ∀n.0 + n = n *)
  | PlusS (* ∀n.∀m.S(n) + m = S(n + m) *)
  | Induction of var * formula

let axiom ax =
  match ax with
  | EqRefl ->
    let x = fresh_var [] [] in
    ForAll(x, App("=", [Var x; Var x]))
  | EqElim(x, f) ->
    let y = fresh_var [f] [Var x]  in
    let z = fresh_var [f] [Var y; Var x]  in
    ForAll(y, ForAll(z, Imp(
      App("=", [Var y; Var z]),
      Imp(
        subst_in_formula x (Var y) f,
        subst_in_formula x (Var z) f))))
  | PlusZ ->
    let n = fresh_var [] []  in
    ForAll(n, App("=",
    [ Sym("+", [Sym("z", []); Var n])
    ; Var n
    ]))
  | PlusS ->
    let n = fresh_var [] []  in
    let m = fresh_var [] [Var n] in
    ForAll(n, ForAll(m, App("=",
    [ Sym("+", [Sym("s", [Var n]); Var m])
    ; Sym("s", [Sym("+", [Var n; Var m])])
    ])))
  | Induction(x, f) ->
    let n = fresh_var [f] [Var x] in
    Imp(
      subst_in_formula x (Sym("z", [])) f,
      Imp(
        ForAll(n, Imp(
          subst_in_formula x (Var n) f,
          subst_in_formula x (Sym("s", [Var n])) f)),
        ForAll(n, subst_in_formula x (Var n) f)))
