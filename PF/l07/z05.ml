type 'a regexp =
| Eps
| Lit of ('a -> bool)
| Or of 'a regexp * 'a regexp
| Cat of 'a regexp * 'a regexp
| Star of 'a regexp

let ( +% ) r1 r2 = Or(r1, r2)
let ( *% ) r1 r2 = Cat(r1, r2)

(** Obliczenia z nawrotami *)
module BT : sig
  type 'a t

  val return : 'a -> 'a t
  val bind   : 'a t -> ('a -> 'b t) -> 'b t

  (** Brak wyniku *)
  val fail : 'a t
  (** Niedeterministyczny wybór -- zwraca true, a potem false *)
  val flip : bool t

  val run : 'a t -> 'a Seq.t
end = struct
  (* Obliczenie typu 'a to leniwa lista wszystkich możliwych wyników *)
  type 'a t = 'a Seq.t

  let return x = List.to_seq [ x ]
  let rec bind m f = Seq.flat_map f m

  let fail = Seq.empty
  let flip = List.to_seq [ true; false ]

  let run m = m
end

let (let* ) = BT.bind

let select_prefix (xs : 'a list) : ('a list * 'a list) BT.t = 
  let rec aux cur xs = 
    match xs with
    | [] -> BT.return ((List.rev cur), [])
    | x :: xs as xxs ->
      let* c = BT.flip in
      if c then BT.return ((List.rev cur), xxs)
      else aux (x :: cur) xs
  in aux [] xs

let rec chop (xs : 'a list) : (('a list) list BT.t) =
  match xs with
  | [] -> BT.return []
  | x :: xs -> 
    let* (p, s) = select_prefix xs in
    let* res = chop s in
    BT.return ((x :: p) :: res)

let rec star_match (r : 'a regexp) (xs : ('a list) list) : bool BT.t = 
  match xs with
  | [] -> BT.return true
  | x :: xs -> 
    let* res = full_match r x in
    if res then star_match r xs 
    else BT.return false
and full_match (r : 'a regexp) (xs : 'a list) : bool BT.t = 
  match r with
  | Eps -> 
    BT.return (xs = []) 
  | Lit p -> 
    begin match xs with
    | [x] when p x -> BT.return true
    | _ -> BT.return false
    end
  | Or(r1, r2) ->
    let* c = full_match r1 xs in
    if c then BT.return true
    else full_match r2 xs
  | Cat(r1, r2) -> 
    let* (pref, suf) = select_prefix xs in
    let* res1 = full_match r1 pref in
    let* res2 = full_match r2 suf in
    BT.return (res1 && res2)
  | Star r -> 
    let* chopped = chop xs in
    star_match r chopped

let rec match_regexp (r : 'a regexp) (xs : 'a list) : 'a list option BT.t = 
  let* (pref, suf) = select_prefix xs in
  let* c = full_match r pref in
  if c then 
    if pref = [] then BT.return None
    else BT.return (Some suf)
  else BT.fail

let append xs ys = 
  let* c = BT.flip in
  if c then xs 
  else ys

let rec match_regexp (r : 'a regexp) (xs : 'a list) : 'a list option BT.t = 
  match r with
  | Eps -> 
    begin match xs with
    | [] -> BT.return None
    | _ -> BT.fail
    end
  | Lit p -> 
    begin match xs with
    | x :: xs when p x -> BT.return (Some xs)
    | _ -> BT.fail
    end
  | Or(r1, r2) ->
    append (match_regexp r1 xs) (match_regexp r2 xs)
  | Cat(r1, r2) -> 
    let* suf = match_regexp r1 xs in
    begin match suf with
    | None -> match_regexp r2 xs 
    | Some s -> 
      let* suf2 = match_regexp r2 s in
      begin match suf2 with
      | None -> BT.return suf2
      | Some s -> BT.return (Some s)
      end
    end    
  | Star r -> 
    let* suf = match_regexp (Or (r, Eps)) xs in
    begin match suf with
    | None -> BT.return None
    | Some s -> append (match_regexp (Star r) s) (BT.return (Some s))
    end
    

let reg = (Star (Star (Lit ((<>) 'b')) +% (Lit ((=) 'b') *% Lit ((=) 'a'))))
let reg1 = ((Lit ((=) 'b')) +% (Eps)) *% (Lit ((=) 'a'))


;; match_regexp reg ['b'; 'a'; 'a'; 'c'; 'b'; 'a'; 'b'; 'd'] |> BT.run |> List.of_seq
;; match_regexp reg1 ['b'; 'a'; 'a'] |> BT.run |> List.of_seq

let t1 = BT.run (match_regexp Eps []) |> List.of_seq
let _ = assert(t1 = [None])
let t2 = BT.run (match_regexp (Lit((=) 'a')) ['a'; 'a']) |> List.of_seq
let _ = assert(t2 = [Some ['a']])
let t3 = BT.run (match_regexp (Lit((=) 'a') +% (Lit((=) 'b'))) ['a'; 'a']) |> List.of_seq
let _ = assert(t3 = [Some ['a']])
let t3II = BT.run (match_regexp (Lit((=) 'b') +% (Lit((=) 'a'))) ['a'; 'a']) |> List.of_seq
let _ = assert(t3II = [Some ['a']])
let t4 = BT.run (match_regexp (Lit((=) 'a') *% (Lit((=) 'b'))) ['a'; 'a']) |> List.of_seq
let _ = assert(t4 = [])
let t5 = BT.run (match_regexp (Lit((=) 'a') *% (Lit((=) 'b'))) ['a'; 'b']) |> List.of_seq
let _ = assert(t5 = [Some []])
let t6 = BT.run (match_regexp (Lit((=) 'a') *% (Lit((=) 'b'))) ['c'; 'a'; 'b']) |> List.of_seq
let _ = assert(t6 = [])

let explode s = List.init (String.length s) (String.get s)
let w = Star (Star (Lit ((<>) 'b')) +% (Lit ((=) 'b') *% Lit ((=) 'a')))
let t7 = BT.run (match_regexp w (explode ("ba"))) |> List.of_seq
let _ = assert(t7 = [None; None; Some []])
let t8 = BT.run (match_regexp w (explode ("cbac"))) |> List.of_seq