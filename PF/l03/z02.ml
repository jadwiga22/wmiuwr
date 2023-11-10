module PInt = Perm.Make(Int)
module PStr = Perm.Make(String)

module MInt = Gen.Make(PInt)
module MStr = Gen.Make(PStr)

let id = PInt.id
let a12 = PInt.swap 1 2
let a23 = PInt.swap 2 3
let a = PInt.compose a12 a12
let b = PInt.compose a12 a23
let c = PInt.compose b (PInt.swap 3 4)
let cid1 = PInt.compose c (PInt.invert c)
let cid2 = PInt.compose (PInt.invert c) c

let s1 = PStr.swap "a" "b"
let sid1 = PStr.compose s1 (PStr.invert s1)
let sid2 = PStr.compose (PStr.invert s1) s1

;; assert (MInt.is_generated a [a12; a12] = true)
;; assert (MInt.is_generated a [] = true)
;; assert (MInt.is_generated a12 [] = false)
;; assert (MInt.is_generated c [a12; a23] = false)
;; assert (MInt.is_generated c [a12; a23; PInt.swap 3 4] = true)
(* ;; assert (MInt.is_generated sid1 [id] = true) *)

;; assert (MStr.is_generated sid1 [] = true)
;; assert (MStr.is_generated sid2 [] = true)
;; assert (MStr.is_generated PStr.id [] = true)
;; assert (MStr.is_generated s1 [PStr.swap "b" "c"; PStr.swap "a" "c"] = true)
;; assert (MStr.is_generated s1 [PStr.swap "b" "c"; PStr.swap "c" "d"; PStr.swap "x" "y"; PStr.id] = false)

