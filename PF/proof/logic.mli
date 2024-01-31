open Formulas ;; 

module type Theory = sig
  type axiom
  val axiom : axiom -> formula
end

module Make(T : Theory) : sig
  (** theorem representation *)
  type theorem

  (** assumptions of theorem *)
  val assumptions : theorem -> formula list

  (** consequence of theorem *)
  val consequence : theorem -> formula

  (* printing theorem *)
  val pp_print_theorem : Format.formatter -> theorem -> unit

  (** by_assumption f creates the following proof

    -------(Ax)
    {f} ⊢ f  *)
  val by_assumption : formula -> theorem

  (** imp_i f thm creates the following proof

        thm
        Γ ⊢ φ
  ---------------(→I)
  Γ \ {f} ⊢ f → φ *)
  val imp_i : formula -> theorem -> theorem

  (** imp_e thm1 thm2 creates the following proof

      thm1      thm2
  Γ ⊢ φ → ψ    Δ ⊢ φ  
  ------------------(→E)
  Γ ∪ Δ ⊢ ψ *)
  val imp_e : theorem -> theorem -> theorem

  (** bot_e f thm creates the following proof

    thm
    Γ ⊢ ⊥
    -----(⊥E)
    Γ ⊢ f *)
  val bot_e : formula -> theorem -> theorem


  (** all_i thm x creates the following proof

    thm   
    Γ ⊢ φ   x ∈/ fv(Γ)
    ------------------(∀I)
    Γ ⊢ ∀x. φ *)
  val all_i : theorem -> var -> theorem

  (** all_e thm t creates the following proof

    thm   
    Γ ⊢ ∀x. φ 
    ------------(∀I)
    Γ ⊢ φ{x -> t} *)
  val all_e : theorem -> term -> theorem

  (* changes axiom to theorem *)
  val thm_axiom : T.axiom -> theorem

end