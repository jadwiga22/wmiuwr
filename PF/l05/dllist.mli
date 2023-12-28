type 'a dllist
type 'a dllist_data

(* returns list shifted by -1 *)
val prev : 'a dllist -> 'a dllist

(* returns current element *)
val elem : 'a dllist -> 'a

(* returns list shifted by 1 *)
val next : 'a dllist -> 'a dllist

(* returns dllist - cyclic list made from list *)
val of_list : 'a list -> 'a dllist

(* val one_el : 'a -> 'a dllist *)

val dummy : 'a -> 'a dllist_data