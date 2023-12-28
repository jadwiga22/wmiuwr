type symbol = string
type 'v term =
| Var of 'v
| Sym of symbol * 'v term list

(* stworzenie termu *)
let return (x : 'a) : 'a term =
  Var(x)

(* podstawienie *)
let rec bind (m : 'a term) (f : 'a -> 'b term) : 'b term = 
  match m with
  | Var x -> f x
  | Sym(s, xs) -> Sym(s, List.map (fun x -> bind x f) xs)
