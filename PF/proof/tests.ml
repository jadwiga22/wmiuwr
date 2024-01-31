open Logic.Make(Peano);;
open Formulas ;;
open Proof ;;

#use "topfind" ;;
#require "ounit2"
open OUnit2 ;;


#install_printer pp_print_proof ;;
#install_printer pp_print_formula ;;
#install_printer pp_print_theorem ;;


let f1 = ForAll("z", App("=", [Var "z"; Var "x1"])) 
let f2 = ForAll("z", App("=", [Var "x1"; Var "x1"])) 
let f3 = ForAll("x", App("=", [Var "x"; Var "x1"])) 

let p1 = ForAll("x", App("f", [Var "x"]))
let p2 = ForAll("x", ForAll("y", App("f", [Var "x"; Var "y"; Var "z"])))
let p3 = ForAll("y", App("f", [Var "y"]))
let p4 = ForAll("x", App("g", [Var "x"]))

let t1 = Var "x"
let t2 = Var "y"
let t3 = Var "x"

(* ----- FORMULAS ----- *)

(* equivalence tests --- *)

;; assert (not (eq_formula f1 f2))
;; assert (eq_formula f1 f3)

;; assert (eq_formula p1 p3)
;; assert (not (eq_formula p1 p4))
;; assert (not (eq_formula p1 p2))

;; assert (eq_term t1 t3)
;; assert (not (eq_term t1 t2))


(* free variables tests --- *)

;; assert (not (free_in_formula "y" p1))
;; assert (not (free_in_formula "x" p1))
;; assert (free_in_formula "z" p2)
;; assert (not (free_in_formula "x" p2))
;; assert (not (free_in_formula "y" p2))


(* fresh variable tests --- *)

let z = fresh_var [f1; f2; f3; p1; p2; p3] [t1; t2; t3]
;; assert (List.for_all (fun x -> not (free_in_formula z x)) [f1; f2; f3; p1; p2; p3])
;; assert (List.for_all (fun x -> not (free_in_term z x)) [t1; t2; t3])


(* substitution tests --- *)

;; assert (subst_in_formula "x" (Var "t") p1 = p1)
;; assert (subst_in_formula "y" (Var "t") p1 = p1)

;; assert (subst_in_formula "x" (Var "t") p2 = p2)
;; assert (subst_in_formula "y" (Var "t") p2 = p2)
;; assert (subst_in_formula "z" (Var "t") p2 = 
          ForAll("x", ForAll("y", App("f", [Var "x"; Var "y"; Var "t"]))))


(* ----- LOGIC ----- *)

(* by_assumption tests --- *)

let th = by_assumption f1
;; assert (consequence th = f1)
;; assert (assumptions th = [f1])

(* imp_i tests --- *)

let f = (App("p", []))
let t = by_assumption f
let th = imp_i f t

;; assert (consequence th = (Imp(App("p", []), App("p", []))))
;; assert (assumptions th = [])

(* imp_e tests --- *)

let t1 = by_assumption (Imp(App("p", []), App("q", [])))
let t2 = by_assumption (App("p", []))
let th = imp_e t1 t2

;; assert (consequence th = (App("q", [])))
;; assert (assumptions th = [Imp(App("p", []), App("q", [])); App("p", [])])

let t3 = by_assumption (App("q", []))

;; assert_raises (Failure "imp_e: inconsistent consequences of theorems") 
  (fun () -> imp_e t1 t3)


(* bot_e tests --- *)

let f = False
let f2 = (App("q", []))
let t = by_assumption f
let t = bot_e f2 t

;; assert (consequence t = f2)
;; assert (assumptions t = [False])
;; assert_raises (Failure "bot_e: wrong constructor of theorem consequence!")
  (fun () -> bot_e f2 (by_assumption f2))


(* all_i tests --- *)

let f = ForAll("n", (App("=", [Var "m"; Var "n"])))
let t = by_assumption f
let t2 = all_i t "z"

;; assert (consequence t2 = (ForAll("z", f)))

;; assert_raises (Failure "all_i: variable is free!") 
  (fun () -> all_i t "m")


(* all_e tests --- *)

let f = ForAll("n", (App("=", [Var "m"; Var "n"])))
let t = by_assumption f
let t2 = all_e t (Var "z")

;; assert (consequence t2 = (App("=", [Var "m"; Var "z"])))
;; assert_raises (Failure "all_e: wrong constructor of theorem consequence!")
  (fun () -> all_e (by_assumption False) (Var "x"))


(* ----- PROOF ----- *)

(* introA tests --- *)

let f13 = ForAll("z", App("=", [Var "z"; Var "m"]))

;; assert_raises (Failure "introA") (fun () -> introA "m" (proof [] f13))
