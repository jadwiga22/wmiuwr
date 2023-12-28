type ('a, 'b) format = 
  (string -> 'b) -> string -> 'a

(* type of f:
   (string -> string) -> string -> 'a *)
let sprintf (f : ('a, string) format) : 'a = 
  f (fun s -> s) ""

(* (string -> 'a) -> string -> 'a  *)
let lit (s : string) :  ('a, 'a) format = 
  fun (f : string -> 'a) ->
    fun (ss : string) -> f (ss ^ s)

(* (string -> 'a) -> string -> int -> 'a *)
let int : (int -> 'a, 'a) format = 
  fun (f : (string -> 'a)) ->
    fun (s : string) (n : int) ->
      f (s ^ (string_of_int n))

(* (string -> 'a) -> string -> string -> 'a *)
let str : (string -> 'a, 'a) format = 
  fun (f : (string -> 'a)) ->
    fun (s1 : string) (s2 : string) ->
      f (s1 ^ s2)

(* type of the result:
   (string -> 'b) -> string -> 'c *)
let (^^) (d2 : ('c, 'a) format) (d1 : ('a, 'b) format) : ('c, 'b) format = 
    fun (f : string -> 'b) : (string -> 'c) -> d2 (d1 f)

let example = sprintf (lit "Ala ma " ^^ int ^^ lit " kot" ^^ str ^^ lit ".")

let aux (n : int) (s : string) = 
  (if n = 1 then "a" else if 1 < n && n < 5 then "y" else "ów")

let my_print =  fun n -> example n
    (if n = 1 then "a" else if 1 < n && n < 5 then "y" else "ów")

;; my_print 1
;; my_print 3 
;; my_print 10
