type formula =
  | False
  | Var of string 
  | Imp of formula * formula

let rec string_of_formula f =
  match f with
  | False -> "⊥"
  | Var(p) -> p
  | Imp(l, r) ->
    let ls = string_of_formula l and rs = string_of_formula r in
    match l with
    | Imp _ -> "(" ^ ls ^ ") → " ^ rs 
    | _ -> ls ^ " → " ^ rs

let pp_print_formula fmtr f =
  Format.pp_print_string fmtr (string_of_formula f)

type theorem = formula list * formula

let assumptions = fst 

let consequence = snd

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

let by_assumption f =
  ([f], f)

let imp_i f thm =
  let assm = assumptions thm and con = consequence thm in
  (List.filter (fun x -> not (x = f)) assm, Imp(f, con))

let imp_e th1 th2 =
  let assm = List.append (assumptions th1) (assumptions th2) in
  match consequence th1 with
  | Imp(l,r) -> (assm, r)
  | x -> (assm, x)

let bot_e f thm =
  let assm = assumptions thm in
  (assm, f)