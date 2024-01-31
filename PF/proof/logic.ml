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
    ------------(∀E)
    Γ ⊢ φ{x -> t} *)
  val all_e : theorem -> term -> theorem

  (* changing axiom into theorem *)
  val thm_axiom : T.axiom -> theorem

end = struct 
  (* ----- types ----- *)
  type theorem = formula list * formula


  (* ----- modules ----- *)
  module VarMap = Map.Make(String)


  (* ----- theorem workers ----- *)
  let assumptions = fst 

  let consequence = snd

  (* ----- printers ----- *)
  let pp_print_theorem fmtr thm =
    let open Format in
    pp_open_hvbox fmtr 2;
    begin match assumptions thm with
    | [] -> ()
    | f :: fs ->
      pp_print_formula fmtr f;
      fs |> List.iter (fun f ->
        pp_print_string fmtr ",";
        pp_print_space fmtr ();
        pp_print_formula fmtr f);
      pp_print_space fmtr ()
    end;
    pp_open_hbox fmtr ();
    pp_print_string fmtr "⊢";
    pp_print_space fmtr ();
    pp_print_formula fmtr (consequence thm);
    pp_close_box fmtr ();
    pp_close_box fmtr ()


  (* ----- theorem rules ----- *)

  let by_assumption f =
    ([f], f)

  let imp_i f thm =
    let assm = assumptions thm and con = consequence thm in
    (List.filter (fun x -> not (eq_formula f x)) assm, Imp(f, con))

  let imp_e th1 th2 =
    let assm = List.append (assumptions th1) (assumptions th2) in
    match consequence th1 with
    | Imp(l,r) when eq_formula l (consequence th2) -> (assm, r)
    | _ -> failwith "imp_e: inconsistent consequences of theorems"

  let bot_e f thm =
    let assm = assumptions thm in
    match consequence thm with
    | False -> (assm, f)
    | _ -> failwith "bot_e: wrong constructor of theorem consequence!"
    
  let all_i thm x =
    if List.exists (free_in_formula x) (assumptions thm) then
      failwith "all_i: variable is free!" 
    else
      (assumptions thm, ForAll(x, consequence thm))

  let all_e thm t = 
    match consequence thm with
    | ForAll(x, f) -> (assumptions thm, subst_in_formula x t f)
    | _ -> failwith "all_e: wrong constructor of theorem consequence!"

  
  (* ----- axiom worker ------ *)
  let thm_axiom (ax : T.axiom) : theorem = 
    ([], T.axiom ax)

end 