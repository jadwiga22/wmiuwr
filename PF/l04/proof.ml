open Logic

type semiproof = 
| Goal of (string * formula) list * formula
| Eimp of (string * formula) list * formula * semiproof * semiproof 
| Iimp of (string * formula) list * formula * semiproof
| Ebot of (string * formula) list * formula * semiproof
| Qed  of theorem

type context = 
| Root 
| CEimpLeft  of context * (string * formula) list * formula * semiproof
| CEimpRight of context * (string * formula) list * formula * semiproof
| CIimp      of context * (string * formula) list * formula
| CEbot      of context * (string * formula) list * formula

(* semiproof here is an active goal *)
type zipper = context * semiproof 

type proof = 
| Compl   of theorem
| Incompl of zipper

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

(* trying to find active goal in a subtree (from left to right) *)
let rec down ((ctx, t) : (context * semiproof)) : (context * semiproof) option = 
  match t with
  | Qed _                 -> None
  | Goal _                -> Some(ctx, t)
  | Iimp(assm, f, s)      -> down (CIimp(ctx, assm, f), s)
  | Ebot(assm, f, s)      -> down (CEbot(ctx, assm, f), s)
  | Eimp(assm, f, s1, s2) ->
    match down (CEimpLeft(ctx, assm, f, s2), s1) with
    | None         -> down (CEimpRight(ctx, assm, f, s1), s2)
    | Some(ctx, t) -> Some(ctx, t)

(* returns first formula in implication *)
let get_prev (f : formula) : formula = 
  match f with
  | Imp(f1, f2) -> f1
  | _           -> failwith "get_prev"

(* going upwards and fixing a tree 
   (changing semiproofs with no goals to qed
   and changing proofs to completed) *)
let up ((ctx, t) : (context * semiproof)) : proof =
  match t with
  | Qed(th1) -> 
    begin match ctx with
    | Root ->  Compl(th1)
    | CEimpLeft(ctx, assm, f, sp) -> 
      begin match sp with
      | Qed(th2) -> Incompl(ctx, Qed(imp_e th1 th2))
      | _        -> Incompl(ctx, Eimp(assm, f, t, sp))
      end      
    | CEimpRight(ctx, assm, f, sp) -> 
      begin match sp with
      | Qed(th2) -> Incompl(ctx, Qed(imp_e th2 th1))
      | _        -> Incompl(ctx, Eimp(assm, f, sp, t))
      end
    | CIimp(ctx, assm, f) -> Incompl(ctx, Qed(imp_i (get_prev f) th1))
    | CEbot(ctx, assm, f) -> Incompl(ctx, Qed(bot_e f th1))
    end
  | _ ->
    match ctx with
    | Root                         -> Incompl(ctx, t)
    | CEimpLeft(ctx, assm, f, sp)  -> Incompl(ctx, Eimp(assm, f, t, sp))
    | CEimpRight(ctx, assm, f, sp) -> Incompl(ctx, Eimp(assm, f, sp, t))
    | CIimp(ctx, assm, f)          -> Incompl(ctx, Iimp(assm, f, t))
    | CEbot(ctx, assm, f)          -> Incompl(ctx, Ebot(assm, f, t))  


(* returns next active goal 
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
    

(* introduction of implication *)
let intro name pf =
  match pf with
  | Compl _         -> failwith "complete proof"
  | Incompl(ctx, t) ->
    match goal pf with
    | None                     -> failwith "complete proof"
    | Some(assm, Imp(psi, fi)) ->
      Incompl(CIimp(ctx, assm, Imp(psi, fi)), Goal((name, psi) :: assm, fi))
    | _                        -> failwith "intro: no implication to prove"

(* returns list of available assumptions *)
let get_assm (pf : proof) : (string * formula) list = 
  match pf with
  | Incompl(ctx, t) -> 
    begin match t with
    | Goal(assm, _)       -> assm
    | Eimp(assm, _, _, _) -> assm
    | Iimp(assm, _, _)    -> assm
    | Ebot(assm, _, _)    -> assm
    | _                   -> failwith "get_assm"
    end
  | Compl(th) -> failwith "get_assm"

(* elimination of false *)
let elimF (pf : proof) : proof = 
  match pf with
  | Compl _         -> failwith "elimF"
  | Incompl(ctx, t) -> 
    match goal pf with
    | None          -> failwith "elimF"
    | Some(assm, f) -> Incompl(CEbot(ctx, assm, f), Goal(assm, False))

(* elimination of implication *)
let elim (pf : proof) (fi : formula) : proof = 
  match goal pf with
  | None          -> failwith "elim"
  | Some(assm, f) ->
    match pf with
    | Compl _         -> failwith "elim"
    | Incompl(ctx, t) -> 
      Incompl(CEimpLeft(ctx, assm, f, Goal(assm, fi)), Goal(assm, Imp(fi, f)))

(* fold for long implications ending with stop or false *)
let rec fold (f : formula) (stop : formula) (acc : proof) : proof = 
  if f = False then elimF acc
  else if f = stop then acc
  else match f with
  | Imp(f0, f1) -> elim (fold f1 stop acc) f0
  | _           -> failwith "fold"

let apply f pf =
  match goal pf with
  | None           -> failwith "apply"
  | Some(assm, f0) -> fold f f0 pf

(* fills active goal with theorem thm and takes next active goal *)
let fill_with_theorem (thm : theorem) (pf : proof) : proof = 
  match pf with
  | Compl _         -> failwith "fill_with_theorem"
  | Incompl(ctx, t) -> next (Incompl(ctx, Qed(thm)))

let apply_thm thm pf =
  fill_with_theorem thm (apply (consequence thm) pf)

let apply_assm name pf =
  apply_thm (by_assumption (List.assoc name (get_assm pf))) pf

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

