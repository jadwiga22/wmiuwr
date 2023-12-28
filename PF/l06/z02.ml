(* from the previous task: 

  type ('a, 'b) format = 
  (string -> 'b) -> string -> 'a *)

type (_, _) format = 
  | Lit : string -> ('a, 'a) format
  | Int : (int -> 'a, 'a) format
  | Str : (string -> 'a, 'a) format
  | Cat : (('a, 'b) format) * (('b, 'c) format) -> ('a, 'c) format 

(* analysis: ksprintf for Cat

   a , c
   d1 : a, b
   d2 : b, c 
   cont : string -> c
   returning type a *)
let rec ksprintf : type a b. (a, b) format -> (string -> b) -> a =
  fun f cont -> 
    match f with
    | Cat(d1, d2) -> ksprintf d1 (fun s -> ksprintf d2 (fun res -> cont (s ^ res)))
    | Lit(s) -> cont s
    | Str -> fun s -> cont s
    | Int -> fun n -> cont (string_of_int n)


let sprintf  (f : ('a, string) format) : 'a =
  ksprintf f (fun x -> x)

let rec lazy_kprintf : type a b. (a, b) format -> (unit -> b) -> a =
  fun f lv -> 
    match f with
    | Cat(d1, d2) -> lazy_kprintf d1 (fun () -> (lazy_kprintf d2 lv))
    | Lit(s) -> print_string s; lv ()
    | Str -> fun s -> print_string s ; lv ()
    | Int -> fun n -> print_int n ; lv ()

let kprintf : type a b. (a, b) format -> b -> a =
  fun f v -> lazy_kprintf f (fun () -> v)

let printf (f : ('a, unit) format) : 'a = 
  kprintf f ()

let (^^) f1 f2 = Cat(f1, f2) 

(* tests *)

let my_print =  fun n -> sprintf (Lit "Ala ma " ^^ Int ^^ Lit " kot" ^^ Str ^^ Lit ".") n
    (if n = 1 then "a" else if 1 < n && n < 5 then "y" else "ów")

;; my_print 1
;; my_print 3 
;; my_print 10

let my_print =  fun n -> printf (Lit "Ala ma " ^^ Int ^^ Lit " kot" ^^ Str ^^ Lit ".") n
    (if n = 1 then "a" else if 1 < n && n < 5 then "y" else "ów")

;; my_print 1
;; my_print 3 
;; my_print 10


