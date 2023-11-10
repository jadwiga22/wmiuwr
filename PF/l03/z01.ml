open Perm

module M = Make(Int)
module MStr = Make(String)

let id = M.id
let a12 = M.swap 1 2
let a23 = M.swap 2 3
let a = M.compose a12 a12
let b = M.compose a12 a23
let c = M.compose b (M.swap 3 4)
let cid1 = M.compose c (M.invert c)
let cid2 = M.compose (M.invert c) c

let s1 = MStr.swap "a" "b"
let sid1 = MStr.compose s1 (MStr.invert s1)
let sid2 = MStr.compose (MStr.invert s1) s1

(* ----- TESTS ------- *)

;; assert ((M.apply id 1) = 1)
;; assert ((M.apply id 20) = 20)

;; assert ((M.apply a 1) = 1)
;; assert ((M.apply a 2) = 2)
;; assert ((M.apply a 7) = 7)

;; assert ((M.apply b 1) = 2)
;; assert ((M.apply b 2) = 3)
;; assert ((M.apply b 3) = 1)
;; assert ((M.apply b 10) = 10)

;; assert ((M.apply cid1 1) = 1)
;; assert ((M.apply cid1 2) = 2)
;; assert ((M.apply cid1 3) = 3)
;; assert ((M.apply cid1 4) = 4)
;; assert ((M.apply cid1 5) = 5)

;; assert ((M.apply cid2 1) = 1)
;; assert ((M.apply cid2 2) = 2)
;; assert ((M.apply cid2 3) = 3)
;; assert ((M.apply cid2 4) = 4)
;; assert ((M.apply cid2 5) = 5)

;; assert ((MStr.apply sid1 "a") = "a")
;; assert ((MStr.apply sid1 "b") = "b")
;; assert ((MStr.apply sid1 "c") = "c")

;; assert ((MStr.apply sid2 "a") = "a")
;; assert ((MStr.apply sid2 "b") = "b")
;; assert ((MStr.apply sid2 "c") = "c")

;; assert (M.compare a12 a23 = -1)
;; assert (M.compare a23 a12 = 1)
;; assert (M.compare a23 a23 = 0)
;; assert (M.compare id cid1 = 0)
;; assert (M.compare id cid2 = 0)
;; assert (M.compare cid1 cid2 = 0)
;; assert (M.compare a c = -1)
;; assert (M.compare c a = 1)
;; assert (M.compare a23 c = 1)
;; assert (M.compare c a23 = -1)