(* generating permutations by selecting *)

  let permutations xs = 
  (* permpref - prefix of permutation *)
  (* xs - remainig elements of list *)
  (* appendix - list that should be appended to the result *)
  (* it returns list of all permutations starting with prefix permpref 
   * and appends appendix to it*)
  let rec it permpref xs appendix = 
    match xs with
    | [] -> permpref :: appendix
    | x :: xss ->
      (* removing returns concatenated lists of results of it after removing elements and adding them to permpref *)
      (* pref - elements before the current el *)
      (* suf - elements after the current el (including it) *)
      (* res - accumulator for concatenating *)
      let rec removing pref suf res = 
        match suf with
        | [] -> res
        | s :: suf -> removing (s :: pref) suf (it (s :: permpref) (List.append pref suf) res)
      in removing [] xs appendix
    in
    it [] xs []


;; assert (permutations [1;2;3] = [[2; 1; 3]; [1; 2; 3]; [1; 3; 2]; [3; 1; 2]; [2; 3; 1]; [3; 2; 1]])
;; assert (permutations [1;2] =  [[1;2]; [2;1]])
;; assert (permutations [] = [[]])
;; assert (permutations [1] = [[1]])

(* generating permutations by inserting *)

(* returns a list of all possible outcomes of inserting x to xs
   * and appends appendix to that list *)
let insert x xs appendix = 
  (* acc - accumulator for result *)
  (* pref - prefix of xs *)
  (* suf - sufix of xs *)
  let rec it pref suf acc =
    match suf with
    | [] -> List.append pref [x] :: acc
    | s :: ssuf -> it (List.append pref [s]) ssuf ((List.append pref (x :: suf)) :: acc)
  in
  it [] xs appendix

let rec permutations2 xs = 
  match xs with
  | [] -> [[]]
  | x :: xs ->
    let rec it ls acc = 
      match ls with
      | [] -> acc
      | l :: ls -> (it ls (insert x l acc))
    in it (permutations2 xs) []

;; assert (permutations2 [1;2;3] = [[2; 3; 1]; [2; 1; 3]; [1; 2; 3]; [3; 2; 1]; [3; 1; 2]; [1; 3; 2]])
;; assert (permutations2 [] = [[]])
;; assert (permutations2 [1;2] = [[2;1]; [1;2]])
;; assert (permutations2 [1] = [[1]])

