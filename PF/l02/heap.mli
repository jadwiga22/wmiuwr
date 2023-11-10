type 'a t

val empty : 'a t

(* val create : 'a t -> 'a t -> 'a -> 'a t *)

val merge : 'a t -> 'a t -> 'a t

val insert : 'a t -> 'a -> 'a t

val erasemin : 'a t -> 'a t

val minheap : int t -> int