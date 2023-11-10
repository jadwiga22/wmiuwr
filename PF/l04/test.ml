;; open Logic 
;; open Proof

;; #install_printer pp_print_proof
;; #install_printer pp_print_formula
;; #install_printer pp_print_theorem

(* ;; let p = Imp(Imp(Var("p"), Imp(Var("q"), Var("r"))), Imp(Imp(Var("p"), Var("q")), Imp(Var("p"), Var("r")))) *)
    
(* ;; intro "assm3" (intro "assm2" (intro "assm1" (proof [] p))) 
;; elimF (intro "assm2" (intro "assm1" (proof [] p)))
;; elim (proof [] p) (Var("a")) *)
(* ;; let a = Imp(Var("a"), Imp(Var("b"), Imp(Var("p"), Var("r"))))
;; let a1 = Imp(Var("a"), Imp(Var("b"), Imp(Imp(Var("p"), Var("r")), False)))

;; let pf = (intro "assm2" (intro "assm1" (proof [] p))) *)

(* ;; fold a (Imp(Var("p"), Var("r"))) (proof [] p) *)
(* ;; apply a (intro "assm2" (intro "assm1" (proof [] p)))  *)
(* ;; apply a1 (intro "assm2" (intro "assm1" (proof [] p)))  *)


(* p → (p → q) → q *)
;; proof [] (Imp(Var("p"), Imp(Imp(Var("p"), Var("q")), Var("q"))))
  |> intro "H1"
  |> intro "H2"
  |> apply_assm "H2" 
  |> apply_assm "H1"
  |> qed

(* p → q → r) → (p → q) → p → r *)
;; proof [] (Imp(Imp(Var("p"), Imp(Var("q"), Var("r"))), Imp(Imp(Var("p"), Var("q")), Imp(Var("p"), Var("r")))))
  |> intro "H1"
  |> intro "H2"
  |> intro "H3"
  |> apply_assm "H1"
  |> apply_assm "H3"
  |> apply_assm "H2"
  |> apply_assm "H3"
  |> qed

(* (((p → ⊥) → p) → p) → ((p → ⊥) → ⊥) → p *)
;; proof [] (Imp(Imp(Imp(Imp(Var("p"), False), Var("p")), Var("p")), Imp(Imp(Imp(Var("p"), False), False), Var("p"))))
  |> intro "H1"
  |> intro "H2"
  |> apply_assm "H1"
  |> intro "H3"
  |> apply_assm "H2"
  |> apply_assm "H3"
  |> qed

(* (((p → ⊥) → ⊥) → p) → ((p → ⊥) → p) → p *)
;; proof [] (Imp(Imp(Imp(Imp(Var("p"), False), False), Var("p")), Imp(Imp(Imp(Var("p"), False), Var("p")), Var("p"))))
  |> intro "H1"
  |> intro "H2"
  |> apply_assm "H1"
  |> intro "H3"
  |> apply_assm "H3"
  |> apply_assm "H2"
  |> apply_assm "H3"
  |> qed

(* p → q → p *)
;; proof [] (Imp(Var("p"), Imp(Var("q"), Var("p"))))
  |> intro "H1"
  |> intro "H2"
  |> apply_assm "H1"
  |> qed

 (* p → p *)
;; proof [] (Imp(Var("p"), Var("p")))
  |> intro "H1"
  |> apply_assm "H1"
  |> qed


(* ;; proof [] (Var("p"))
  |> apply (Imp(Var("p1"), Imp(Var("p2"), Imp(Var("p3"), Var("p")))))
  |> next
  |> next
  |> next
  |> next *)

