open Logic.Make(Peano)
open Formulas ;;

(* Representation of a proof tree *)
type semiproof = 
  | Goal of (string * formula) list * formula
  | Eimp of (string * formula) list * formula * semiproof * semiproof 
  | Iimp of (string * formula) list * formula * semiproof
  | Ebot of (string * formula) list * formula * semiproof
  | Iall of (string * formula) list * formula * var * semiproof
  | Eall of (string * formula) list * formula * term * semiproof 
  | Qed  of theorem

(* Representation of the context - part of the proof tree
   "above" the active goal *)
type context = 
  | Root 
  | CEimpLeft  of context * (string * formula) list * formula * semiproof
  | CEimpRight of context * (string * formula) list * formula * semiproof
  | CIimp      of context * (string * formula) list * formula
  | CEbot      of context * (string * formula) list * formula
  | CIall      of context * (string * formula) list * formula * var
  | CEall      of context * (string * formula) list * formula * term

(* semiproof here is an active goal *)
type zipper = context * semiproof 

(* Representation of proof *)
type proof = 
  | Compl   of theorem
  | Incompl of zipper

(* Creating proof tree with given assumptions and goal *)
let proof g f =
  Incompl(Root, Goal(g, f))

let qed pf =
  match pf with
  | Compl(t)  -> t
  | Incompl _ -> failwith "incomplete proof"

let goal pf =
  match pf with
  | Compl _                     -> None
  | Incompl(ctx, Goal(assm, f)) -> Some(assm, f)
  | _                           -> failwith "wrong constructor of semiproof"

let pp_print_proof fmtr pf =
  match goal pf with
  | None -> Format.pp_print_string fmtr "No more subgoals"
  | Some(g, f) ->
    Format.pp_open_vbox fmtr (-100);
    g |> List.iter (fun (name, f) ->
      Format.pp_print_cut fmtr ();
      Format.pp_open_hbox fmtr ();
      Format.pp_print_string fmtr name;
      Format.pp_print_string fmtr ":";
      Format.pp_print_space fmtr ();
      pp_print_formula fmtr f;
      Format.pp_close_box fmtr ());
    Format.pp_print_cut fmtr ();
    Format.pp_print_string fmtr (String.make 40 '=');
    Format.pp_print_cut fmtr ();
    pp_print_formula fmtr f;
    Format.pp_close_box fmtr ()

(* Trying to find active goal in a subtree (from left to right) *)
let rec down ((ctx, t) : (context * semiproof)) : (context * semiproof) option = 
  match t with
  | Qed _                 -> None
  | Goal _                -> Some(ctx, t)
  | Iimp(assm, f, s)      -> down (CIimp(ctx, assm, f), s)
  | Ebot(assm, f, s)      -> down (CEbot(ctx, assm, f), s)
  | Eimp(assm, f, s1, s2) ->
    begin match down (CEimpLeft(ctx, assm, f, s2), s1) with
    | None         -> down (CEimpRight(ctx, assm, f, s1), s2)
    | Some(ctx, t) -> Some(ctx, t)
    end
  | Iall(assm, f, v, s) -> down (CIall(ctx, assm, f, v), s)
  | Eall(assm, f, t, s) -> down (CEall(ctx, assm, f, t), s)

(* Returns first formula in implication *)
let get_prev (f : formula) : formula = 
  match f with
  | Imp(f1, f2) -> f1
  | _           -> failwith "get_prev"

(* Smart constructors *)
let smart_incompl ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | Root, Qed th -> Compl(th)
  | _ -> Incompl(ctx, t)

let smart_eimp_left ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | CEimpLeft(ctx, assm, f, Qed th2), Qed th1 ->
    smart_incompl (ctx, Qed(imp_e th1 th2))
  | CEimpLeft(ctx, assm, f, f2), f1 ->
    smart_incompl (ctx, Eimp(assm, f, f1, f2))
  | _ -> failwith "smart_eimp_left : incorrect contructors!"

let smart_eimp_right ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | CEimpRight(ctx, assm, f, Qed th2), Qed th1 ->
    smart_incompl (ctx, Qed(imp_e th2 th1))
  | CEimpRight(ctx, assm, f, f2), f1 ->
    smart_incompl (ctx, Eimp(assm, f, f2, f1))
  | _ -> failwith "smart_eimp_right : incorrect contructors!"
  
let smart_iimp ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | CIimp(ctx, assm, f), Qed th ->
    smart_incompl (ctx, Qed(imp_i (get_prev f) th))
  | CIimp(ctx, assm, f), _ -> 
    smart_incompl (ctx, Iimp(assm, f, t))
  | _ -> failwith "smart_iimp : incorrect constructors!"

let smart_ebot ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | CEbot(ctx, assm, f), Qed th -> 
    smart_incompl (ctx, Qed(bot_e f th))
  | CEbot(ctx, assm, f), _ -> 
    smart_incompl (ctx, Ebot(assm, f, t))
  | _ -> failwith "smart_ebot : incorrect constructors!"

let smart_iall ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | CIall(ctx, assm, f, v), Qed th ->
    smart_incompl (ctx, Qed(all_i th v))
  | CIall(ctx, assm, f, v), _ ->
    smart_incompl (ctx, Iall(assm, f, v, t))
  | _ -> failwith "smart_iall : incorrect constructors!"

let smart_eall ((ctx, t) : (context * semiproof)) : proof = 
  match ctx, t with
  | CEall(ctx, assm, f, tm), Qed th ->
    smart_incompl (ctx, Qed(all_e th tm))
  | CEall(ctx, assm, f, tm), _ ->
    smart_incompl (ctx, Eall(assm, f, tm, t))
  | _ -> failwith "smart_eall : incorrect constructors!"

(* Going upwards and fixing a tree 
   (changing semiproofs with no goals to qed
   and changing proofs to completed) *)
let up ((ctx, t) : (context * semiproof)) : proof =
  match ctx with
  | Root         -> smart_incompl (ctx, t)
  | CEimpLeft  _ -> smart_eimp_left (ctx, t)
  | CEimpRight _ -> smart_eimp_right (ctx, t)
  | CIimp _      -> smart_iimp (ctx, t)
  | CEbot _      -> smart_ebot (ctx, t)
  | CIall _      -> smart_iall (ctx, t)
  | CEall _      -> smart_eall (ctx, t)
     

(* Returns next active goal 
   or complete proof *)
let rec next pf = 
  match pf with
  | Compl _         -> pf
  | Incompl(ctx, t) -> 
    match ctx with
    | Root ->
      begin match down (ctx, t) with
      | None -> up (ctx, t)
      | Some(ctx, t) -> Incompl(ctx, t)
      end      
    | CEimpLeft(ctx, assm, f, sp) -> 
      begin match down (CEimpRight(ctx, assm, f, t), sp) with
      | None -> next (up (ctx, t))
      | Some(ctx, t) -> Incompl(ctx, t)
      end
    | _ -> next (up (ctx, t))
    

(* Introduction of implication *)
let intro name pf =
  match pf with
  | Compl _         -> failwith "complete proof"
  | Incompl(ctx, t) ->
    match goal pf with
    | None                     -> failwith "complete proof"
    | Some(assm, Imp(psi, fi)) ->
      Incompl(CIimp(ctx, assm, Imp(psi, fi)), Goal((name, psi) :: assm, fi))
    | _                        -> failwith "intro: no implication to prove"

(* Returns list of available assumptions *)
let get_assm (pf : proof) : (string * formula) list = 
  match pf with
  | Incompl(ctx, t) -> 
    begin match t with
    | Goal(assm, _)       -> assm
    | Eimp(assm, _, _, _) -> assm
    | Iimp(assm, _, _)    -> assm
    | Ebot(assm, _, _)    -> assm
    | Iall(assm, _, _, _) -> assm
    | Eall(assm, _, _, _) -> assm
    | _                   -> failwith "get_assm"
    end
  | Compl(th) -> failwith "get_assm"

(* Elimination of false *)
let elimF (pf : proof) : proof = 
  match pf with
  | Compl _         -> failwith "elimF"
  | Incompl(ctx, t) -> 
    match goal pf with
    | None          -> failwith "elimF"
    | Some(assm, f) -> Incompl(CEbot(ctx, assm, f), Goal(assm, False))

(* Elimination of implication *)
let elim (pf : proof) (fi : formula) : proof = 
  match goal pf with
  | None          -> failwith "elim"
  | Some(assm, f) ->
    match pf with
    | Compl _         -> failwith "elim"
    | Incompl(ctx, t) -> 
      Incompl(CEimpLeft(ctx, assm, f, Goal(assm, fi)), Goal(assm, Imp(fi, f)))

(* Checks if variable is not free in a list of assumptions *)
let not_free_in_assm (v : var) (assm : (string * formula) list) : bool = 
  List.for_all (fun x -> not (free_in_formula v (snd x))) assm

(* Introduction of for_all *)
let introA (x : var) (pf : proof) : proof = 
  match goal pf with
  | Some(assm, ForAll(v, f)) when not_free_in_assm x assm && (not (free_in_formula x (ForAll(v, f)))) -> 
    begin match pf with 
    | Compl _ -> failwith "introA"
    | Incompl(ctx, t) ->
      let new_f = subst_in_formula v (Var x) f in 
      Incompl(CIall(ctx, assm, ForAll(x, new_f), x), Goal(assm, new_f))
    end
  | _ -> failwith "introA"

(* Elimination of for_all *)
let elimA (v : var) (pf : proof) : proof = 
  match goal pf with
  | Some(assm, f) ->
    begin match pf with
    | Compl _ -> failwith "elimA"
    | Incompl(ctx, t) ->
      Incompl(CEall(ctx, assm, f, (Var v)), Goal(assm, ForAll(v, f)))
    end
  | _ -> failwith "elimA"

(* Fold for long implications ending with stop or false *)
let rec fold (f : formula) (stop : formula) (acc : proof) : proof = 
  if (eq_formula f False) then elimF acc
  else if (eq_formula f stop) then acc
  else match f with
  | Imp(f0, f1) -> elim (fold f1 stop acc) f0
  | _           -> failwith "fold"

let apply f pf =
  match goal pf with
  | None           -> failwith "apply"
  | Some(assm, f0) -> fold f f0 pf

(* Fills active goal with theorem thm and takes next active goal *)
let fill_with_theorem (thm : theorem) (pf : proof) : proof = 
  match pf with
  | Compl _         -> failwith "fill_with_theorem"
  | Incompl(ctx, t) -> next (Incompl(ctx, Qed(thm)))

let apply_thm thm pf =
  fill_with_theorem thm (apply (consequence thm) pf)

let apply_assm name pf =
  apply_thm (by_assumption (List.assoc name (get_assm pf))) pf

