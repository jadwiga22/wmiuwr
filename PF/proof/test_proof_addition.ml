open Logic.Make(Peano);;
open Formulas ;;
open Proof ;;
open Peano ;;

#install_printer pp_print_proof ;;
#install_printer pp_print_formula ;;
#install_printer pp_print_theorem ;;

(* --------------- LEMMA 1 ------------------ *)
(* ∀x.∀y.x = y ⇒ y = x *)

let lem1 = ForAll("x", ForAll("y", Imp(App("=", [Var "x"; Var "y"]), App("=", [Var "y"; Var "x"]))))

let proof_lem1 =  proof [] lem1 
(* Fix x *)
  |> introA "x"
(* Fix y. Goal: x = y -> y = x *)
  |> introA "y"
(* Assume x = y. Goal: y = x. *)
  |> intro "H1"
(* Denote P(z) == (z = x). 
Then by axiom x = y -> P(x) -> P(y),
where P(y) == y = x (current goal). Goal: x = y. *)
  |> apply_thm (all_e (all_e (thm_axiom (EqElim("z", App("=", [Var "z"; Var "x"])))) (Var "x")) (Var "y"))
(* By assumption x = y. Goal: P(x) == x = x *)
  |> apply_assm "H1"
(* By axiom x = x. QED *)
  |> apply_thm (all_e (thm_axiom EqRefl) (Var("x")) )
  |> qed

;; assert (assumptions proof_lem1 = [])
;; assert (eq_formula lem1 (consequence proof_lem1))


(* --------------- LEMMA 2 ------------------ *)
(* ∀n.n + 0 = n *)

let lem2 = ForAll("n", App("=", [Sym("+", [Var "n"; Sym("z", [])]); Var "n"]))

let proof_lem2 = proof [] lem2
  |> apply_thm (thm_axiom (Induction("n", App("=", [Sym("+", [Var "n"; Sym("z", [])]); Var "n"])) ))
  |> apply_thm (all_e (thm_axiom (PlusZ)) (Sym("z", [])))
  |> introA "n"
  |> intro "H1"
  |> apply_thm (all_e (all_e (thm_axiom
        (EqElim("x", 
                App("=", [Sym("+", [Sym("s", [Var "n"]); Sym("z", [])]); 
                        Sym("s", [Var "x"])])))) (Sym("+", [Var "n"; Sym("z", [])]))) (Var "n"))
  |> apply_assm "H1"
  |> apply_thm (all_e (all_e (thm_axiom (PlusS)) (Var "n")) (Sym("z", [])))
  |> qed

;; assert (assumptions proof_lem2 = [])
;; assert (eq_formula lem2 (consequence proof_lem2))


(* --------------- LEMMA 3 ------------------ *)
(* ∀n.∀m.n + S(m) = S(n + m) *)

let lem3 = ForAll("n", ForAll("m", App("=", [Sym("+", [Var "n"; Sym("s", [Var "m"])]); Sym("s", [Sym("+", [Var "n"; Var "m"])])])))

let proof_lem3 = proof [] lem3
  |> apply_thm (thm_axiom (Induction ("n", ForAll("m", App("=", [Sym("+", [Var "n"; Sym("s", [Var "m"])]); Sym("s", [Sym("+", [Var "n"; Var "m"])])])))))
  |> introA "m"
  |> apply_thm (all_e (all_e (thm_axiom (EqElim("x", App("=",
         [Sym("+", [Sym("z", []); Sym("s", [Var "m"])]); Sym("s", [Var "x"])])))) (Var "m")) (Sym("+", [Sym("z", []); Var "m"])))
  |> apply_thm (all_e (all_e proof_lem1 (Sym("+", [Sym("z", []); Var "m"]))) (Var "m"))
  |> apply_thm (all_e (thm_axiom (PlusZ)) (Var "m"))
  |> apply_thm (all_e (thm_axiom (PlusZ)) (Sym("s", [Var "m"])))
  |> introA "n"
  |> intro "H1"
  |> introA "m"
  (* S(n+m) = S(n)+m -> S(n)+S(m) = S(S(n+m)) -> S(n)+S(m) = S(S(n)+m) *)
  |> apply_thm (all_e
        (all_e (thm_axiom (EqElim("x", 
        App("=",
        [Sym("+", [Sym("s", [Var "n"]); Sym("s", [Var "m"])]);
        Sym("s", [Var "x"])]))))
        (Sym("s", [Sym("+", [Var "n"; Var "m"])])))
        (Sym("+", [Sym("s", [Var "n"]); Var "m"])))
  (* S(n)+m = S(n+m) *)
  |> apply_thm (all_e (all_e proof_lem1 (Sym("+", [Sym("s", [Var "n"]); Var "m"]))) (Sym("s", [Sym("+", [Var "n"; Var "m"])]))) 
  (* ax : S(n)+m = S(n+m) *)
  |> apply_thm (all_e (all_e (thm_axiom (PlusS)) (Var "n")) (Var "m"))
  (* S(n+S(m)) = S(n)+S(m) -> S(n+S(m)) = S(S(n+m)) -> S(n)+S(m) = S(S(n+m)) *)
  |> apply_thm (all_e (all_e 
        (thm_axiom (EqElim("x", App("=", [Var "x"; (Sym("s", [Sym("s", [Sym("+", [Var "n"; Var "m"])])]))])))) 
        (Sym("s", [Sym("+", [Var "n"; Sym("s", [Var "m"])])])))
        (Sym("+", [Sym("s", [Var "n"]); Sym("s", [Var "m"])])))
  (* swap *)
  |> apply_thm (all_e (all_e proof_lem1
        (Sym("+", [Sym("s", [Var "n"]); Sym("s", [Var "m"])])))
        (Sym("s", [Sym("+", [Var "n"; Sym("s", [Var "m"])])])))
  |> apply_thm (all_e (all_e (thm_axiom (PlusS)) (Var "n")) (Sym("s", [Var "m"])))
  (* n+S(m) = S(n+m) -> S(n+S(m)) = S(n+S(m)) -> S(n+S(m)) = S(S(n+m)) *)
  |> apply_thm (all_e (all_e
        (thm_axiom (EqElim("x",
        App("=",
        [Sym("s", [Sym("+", [Var "n"; Sym("s", [Var "m"])])]);
        Sym("s", [Var "x"])]))))
        (Sym("+", [Var "n"; Sym("s", [Var "m"])])))
        (Sym("s", [Sym("+", [Var "n"; Var "m"])])))
  |> elimA "m" 
  |> apply_assm "H1"
  |> apply_thm (all_e (thm_axiom EqRefl) 
        (Sym("s", [Sym("+", [Var "n"; Sym("s", [Var "m"])])])))
  |> qed

;; assert (assumptions proof_lem3 = [])
;; assert (eq_formula lem3 (consequence proof_lem3))

(* --------------- THEOREM 1 ----------------- *)
(* ∀n.∀m.n + m = m + n *)

let thm1 = ForAll("n", ForAll("m", App("=", 
        [Sym("+", [Var "n"; Var "m"]);
         Sym("+", [Var "m"; Var "n"])])))
  
let proof_thm1 = proof [] thm1
  |> apply_thm (thm_axiom (Induction("n", ForAll("m", App("=", 
        [Sym("+", [Var "n"; Var "m"]);
        Sym("+", [Var "m"; Var "n"])])))))
  |> introA "m"
  |> apply_thm (all_e (all_e (thm_axiom (EqElim("x", App("=", 
        [Var "x"; Sym("+", [Var "m"; Sym("z", [])])]))))
        (Var "m"))
        (Sym("+", [Sym("z", []); Var "m"])))
  |> apply_thm (all_e (all_e proof_lem1 
        (Sym("+", [Sym("z", []); Var "m"])))
        (Var "m"))
  |> apply_thm (all_e (thm_axiom (PlusZ)) (Var "m"))
  |> apply_thm (all_e (all_e proof_lem1
        (Sym("+", [Var "m"; Sym("z", [])])))
        (Var "m"))
  |> apply_thm (all_e proof_lem2 (Var "m"))
  |> introA "n"
  |> intro "H1"
  |> introA "m"
  |> apply_thm (all_e (all_e (thm_axiom (EqElim("x", App("=",
        [Var "x";
        Sym("+", [Var "m"; Sym("s", [Var "n"])])]))))
        (Sym("s", [Sym("+", [Var "n"; Var "m"])])))
        (Sym("+", [Sym("s", [Var "n"]); Var "m"])))
  |> apply_thm (all_e (all_e proof_lem1 
        (Sym("+", [Sym("s", [Var "n"]); Var "m"])))
        (Sym("s", [Sym("+", [Var "n"; Var "m"])])))
  |> apply_thm (all_e (all_e (thm_axiom (PlusS))
        (Var "n"))
        (Var "m"))
  |> apply_thm (all_e (all_e (thm_axiom (EqElim("x", App("=",
        [Sym("s", [Var "x"]);
        Sym("+", [Var "m"; Sym("s", [Var "n"])])]))))
        (Sym("+", [Var "m"; Var "n"])))
        (Sym("+", [Var "n"; Var "m"])))
  |> apply_thm (all_e (all_e proof_lem1 
        (Sym("+", [Var "n"; Var "m"])))
        (Sym("+", [Var "m"; Var "n"])))
  |> elimA "m" 
  |> apply_assm "H1"
  |> apply_thm (all_e (all_e proof_lem1 
        (Sym("+", [Var "m"; Sym("s", [Var "n"])])))
        (Sym("s", [Sym("+", [Var "m"; Var "n"])])))
  |> apply_thm (all_e (all_e proof_lem3 
        (Var "m"))
        (Var "n"))
  |> qed

;; assert (assumptions proof_thm1 = [])
;; assert (eq_formula thm1 (consequence proof_thm1))