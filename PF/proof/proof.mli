open Formulas ;;
open Logic.Make(Peano);;

type proof

(* Prints proof *)
val pp_print_proof : Format.formatter -> proof -> unit

(* Creates empty proof of the given formula *)
val proof : (string * formula) list -> formula -> proof

(* Changes finished proof to the theorem *)
val qed : proof -> theorem

(* If the proof is finished, returns None. Otherwise returns
   Some(Γ, φ), where Γ and φ are respectively assumptions
   and a formula to prove in an active goal *)
val goal : proof -> ((string * formula) list * formula) option

(* Switches active goal to the next acitve goal (from left to right, cyclically) *)
val next : proof -> proof


(* Calling intro name pf corresponds to introduction of implication.
  That is, an active goal is filled with a rule

  (new active goal)
   (name,ψ) :: Γ ⊢ φ
   -----------------(→I)
       Γ ⊢ ψ → φ

  If an active goal is not an implication, call ends with an error. *)
val intro : string -> proof -> proof


(* Calling apply ψ₀ pf corresponds to elimination of implication and
  elimination of false. That is, if φ is an active goal and ψ₀ is in
  a form of ψ₁ → ... → ψₙ → φ, then active goal is filled with the 
  following rules:
  
  (new active goal) (new goal)
        Γ ⊢ ψ₀          Γ ⊢ ψ₁
        ----------------------(→E)  (new goal)
                ...                   Γ ⊢ ψₙ
                ----------------------------(→E)
                            Γ ⊢ φ

  

  However if ψ₀ is in a form of ψ₁ → ... → ψₙ → ⊥, then active goal
  is filled with the following rules:

  (new active goal) (new goal)
        Γ ⊢ ψ₀          Γ ⊢ ψ₁
        ----------------------(→E)  (new goal)
                ...                   Γ ⊢ ψₙ
                ----------------------------(→E)
                            Γ ⊢ ⊥
                            -----(⊥E)
                            Γ ⊢ φ *)
val apply : formula -> proof -> proof



(* Calling apply_thm thm pf
 works in a similar way to apply (Logic.consequence thm) pf, but
 an active goal is filled with the proof of thm.
 New active goal is first from the right of the one that was 
 filled with thm.  *)
val apply_thm : theorem -> proof -> proof

(** Calling apply_assm name pf
  works in a similar way to apply (Logic.by_assumption f) pf,
  where f is an assumption with name equal to name *)
val apply_assm : string -> proof -> proof

(* Switches to the next active goal (from left to right, cyclically) *)
val next : proof -> proof

(*  Calling introA v pf corresponds to introduction of universal
  quantifier. That is, if ∀x.φ is an active goal and v is not a free
  variable in Γ nor in φ, then 

      (new active goal)  
        Γ ⊢ φ{x -> v}  
        -------------(∀I)
        Γ ⊢ ∀x. φ *) 
val introA : var -> proof -> proof

(*  Calling elimA x pf corresponds to elimination of universal
  quantifier. That is, if φ is an active goal, then 

    (new active goal)  
        Γ ⊢ ∀x.φ
        ---------(∀E)
        Γ ⊢ φ *) 
val elimA : var -> proof  -> proof