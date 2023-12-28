open Proc ;;

let rec echo k =
  recv (fun v ->
  send v (fun () ->
  echo k))

(* type ('a,'z,'i,'o) proc = ('a -> ('z,'i,'o) ans) -> ('z,'i,'o) ans *)

let map  (f : ('i -> 'o)) : ('a, 'z, 'i, 'o) proc = 
  let rec map cont = 
    recv (fun v ->
    send (f v) (fun () ->
    map cont))
  in map

(* printing length of input lines *)
(* run (map String.length >|> map string_of_int) *)

let filter (p : 'i -> bool) : ('a, 'z, 'i, 'i) proc =
  let rec filter cont = 
    recv (fun v ->
      if p v then send v (fun () -> filter cont)
      else filter cont)
  in filter

(* printing only lines of length >= 5*)
(* run (filter (fun s -> String.length s >= 5)) *)

let nats_from (n : int) : ('a, 'z, 'i, int) proc = 
  let rec nats_from (n : int) cont = 
    send n (fun () ->
    nats_from (n+1) cont)
  in nats_from n

(* printing natural numbers >= 1 *)
(* run (nats_from 1 >|> map string_of_int) *)

let sieve : ('a, 'a, int, int) proc = 
  let rec sieve cont = 
    recv (fun v ->
    send v (fun () ->
    (filter (fun x -> x mod v <> 0) >|> sieve)  cont))
  in sieve

(* printing primes *)
(* run (nats_from 2 >|> sieve >|> map string_of_int)  *)