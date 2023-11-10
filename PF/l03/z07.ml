open Logic

(* ⊢ p → p *)

let _ = imp_i (Var("p")) (by_assumption (Var("p")))

(*  ⊢ p → q → p *)

let _ = imp_i (Var("p")) (imp_i (Var("q")) (by_assumption (Var("p"))))  ;;

(* ⊢ (p → q → r) → (p → q) → p → r *)

let f1 = (Imp(Var("p"), Imp(Var("q"), Var("r")))) in
let f2 = Imp(Var("p"), Var("q")) in 
let tp = by_assumption (Var("p")) in
let t1 = by_assumption f1 in
let t2 = by_assumption f2 in
let t3 = imp_e t1 tp in
let t4 = imp_e t2 tp in
let t5 = imp_e t3 t4 in
imp_i f1 (imp_i f2 (imp_i (Var("p")) t5))

(* ⊥ → p *)

let _ = imp_i False (bot_e (Var("p")) (by_assumption False))
