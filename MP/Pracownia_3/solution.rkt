#lang plait

(require (typed-in racket
                   (fifth : ((Listof 'a) -> 'a))
                   (sixth : ((Listof 'a) -> 'a))))

(module+ test
  (print-only-errors #t))

; abstract syntax -----------------------------------

(define-type Exp
  (numE [n : Number])
  (varE [s : Symbol])
  (defE [fs : (Listof Exp)] [e : Exp])
  (funE [f : Symbol] [args : (Listof Symbol)] [e : Exp])
  (appE [f : Symbol] [xs : (Listof Exp)])
  (opE [op : Symbol] [e1 : Exp] [e2 : Exp])
  (ifE [b : Exp] [e1 : Exp] [e2 : Exp])
  (letE [x : Symbol] [e1 : Exp] [e2 : Exp]))

; parser --------------------------------------------

(define (parse [s : S-Exp]) : Exp
  (cond
    [(s-exp-match? `{define {ANY ...} for ANY} s)
     (let ([fs (foldr
                (lambda (f res) (cons (fun-parse f) res))
                empty
                (s-exp->list (second (s-exp->list s))))])
       (if (unique-list? (map (lambda (f) (funE-f f)) fs))
           (defE fs
             (exp-parse (fourth (s-exp->list s))))
           (error 'parse "duplicate function names")))]
    [else (error 'parse "wrong structure of a program")]))

(define (fun-parse [s : S-Exp]) : Exp
  (cond
    [(s-exp-match? `[fun SYMBOL (ANY ...) = ANY] s)
     (let ([args (parse-args (s-exp->list (third (s-exp->list s))))])
       (if (unique-list? args)
           (funE (s-exp->symbol (second (s-exp->list s)))
                 args
                 (exp-parse (fifth (s-exp->list s))))
           (error 'parse "duplicate function arguments")))]
    [else (error 'parse "function syntax error")]))  

(define (exp-parse [s : S-Exp]) : Exp
  (cond
    [(s-exp-match? `NUMBER s)
     (numE (s-exp->number s))]
    [(s-exp-match? `SYMBOL s)
     (varE (s-exp->symbol s))]
    [(s-exp-match? `{ifz ANY then ANY else ANY} s)
     (ifE (exp-parse (second (s-exp->list s)))
          (exp-parse (fourth (s-exp->list s)))
          (exp-parse (sixth (s-exp->list s))))]
    [(s-exp-match? `{let SYMBOL be ANY in ANY} s)
     (letE (s-exp->symbol (second (s-exp->list s)))
           (exp-parse (fourth (s-exp->list s)))
           (exp-parse (sixth (s-exp->list s))))]
    [(s-exp-match? `{SYMBOL {ANY ...}} s)
     (appE (s-exp->symbol (first (s-exp->list s)))
           (parse-list (s-exp->list (second (s-exp->list s)))))]
    [(s-exp-match? `{ANY SYMBOL ANY} s)
     (opE (parse-op (s-exp->symbol (second (s-exp->list s))))
            (exp-parse (first (s-exp->list s)))
            (exp-parse (third (s-exp->list s))))]                    
    [else (error 'parse "invalid input")]))

(define (parse-args [xs : (Listof S-Exp)]) : (Listof Symbol)
  (type-case (Listof S-Exp) xs
    [empty empty]
    [(cons x xs)
     (if (s-exp-symbol? x)
         (cons (s-exp->symbol x) (parse-args xs))
         (error 'parse "function arguments: expected a symbol"))]))

(define (parse-list [xs : (Listof S-Exp)]) : (Listof Exp)
  (type-case (Listof S-Exp) xs
    [empty empty]
    [(cons x xs) (cons (exp-parse x) (parse-list xs))]))

(define (parse-op [op : Symbol])
  (if (on-list? op prim-ops)
      op
      (error 'parse "unknown operator")))

(define (on-list? [a : Symbol] [xs : (Listof Symbol)]) : Boolean
  (type-case (Listof Symbol) xs
    [empty #f]
    [(cons x xs) (or (equal? a x) (on-list? a xs))]))

(define (unique-list? [xs : (Listof Symbol)]) : Boolean
  (type-case (Listof Symbol) xs
    [empty #t]
    [(cons x xs) (and (not (on-list? x xs)) (unique-list? xs))]))

(define prim-ops '(+ - * <=))

; eval ----------------------------------------------

(define-type Answer
  (numA [n : Number])
  (funA [e : Exp] [args : (Listof Symbol)])
  (primopA [f : (Answer Answer -> Answer)]))

(define-type Binding
  (bind [name : Symbol] [val : Answer]))

(define-type-alias Env (Listof Binding))

(define (op-num-num->answer [f : (Number Number -> Number)]) : Answer
  (primopA
   (lambda (v1 v2)
     (type-case Answer v1
       [(numA n1)
        (type-case Answer v2
          [(numA n2)
           (numA (f n1 n2))]
          [else
           (error 'eval "expected a number")])]
       [else
        (error 'eval "expected a number")]))))

(define (op-num-bool->answer [f : (Number Number -> Boolean)]) : Answer
  (primopA
   (lambda (v1 v2)
     (type-case Answer v1
       [(numA n1)
        (type-case Answer v2
          [(numA n2)
           (if (f n1 n2)
               (numA 0)
               (numA 1))]
          [else
           (error 'eval "expected a number")])]
       [else
        (error 'eval "expected a number")]))))

(define init-env empty)
(define prim-op-env
  (list
   (bind '+ (op-num-num->answer +))
   (bind '- (op-num-num->answer -))
   (bind '* (op-num-num->answer *))
   (bind '<= (op-num-bool->answer <=))))   

(define (lookup-env [x : Symbol] [env : Env]) : Answer
  (type-case Env env
    [empty (error 'lookup-env "undefined object")]
    [(cons e env) (if (equal? x (bind-name e))
                      (bind-val e)
                      (lookup-env x env))]))

(define (extend-env [x : Symbol] [val : Answer] [env : Env]) : Env
  (cons (bind x val) env))

(define (true? [a : Answer]) : Boolean
  (type-case Answer a
    [(numA n) (equal? n 0)]
    [else (error 'eval "expected a number")]))

(define (eval [e : Exp] [env : Env] [fun-env : Env]) : Answer
  ; env contains variables and functions
  ; fun-env contains only functions
  (type-case Exp e
    [(defE fs e)
     (let ([new-env (foldr
                     (lambda (f res)
                       (extend-env (funE-f f) (funA (funE-e f) (funE-args f)) res))
                     env
                     fs)])
       (eval e new-env new-env))]
    [(numE n) (numA n)]
    [(varE x) (lookup-env x env)]
    [(letE x e1 e2)
     (eval e2 (extend-env x (eval e1 env fun-env) env) fun-env)]
    [(ifE b e1 e2)
     (if (true? (eval b env fun-env))
         (eval e1 env fun-env)
         (eval e2 env fun-env))]
    [(appE f xs)
     (apply f xs env fun-env)]
    [(opE op e1 e2)
     (prim-op-apply
      (lookup-env op prim-op-env)
      (eval e1 env fun-env)
      (eval e2 env fun-env))]
    [else (error 'eval "something went really wrong")]))

(define (zip [xs : (Listof Symbol)] [ys : (Listof Exp)]) : (Listof (Symbol * Exp))
  (type-case (Listof Symbol) xs
    [empty empty]
    [(cons x xs) (cons (pair x (first ys)) (zip xs (rest ys)))]))

(define (prim-op-apply [op : Answer] [v1 : Answer] [v2 : Answer]) : Answer
  (type-case Answer op
    [(primopA f) (f v1 v2)]
    [else (error 'eval "prim-op-apply: expected a prim-op")]))

(define (apply [f : Symbol] [xs : (Listof Exp)] [env : Env] [fun-env : Env]) : Answer
  (type-case Answer (lookup-env f env)
    [(funA e args)
     (if (= (length args) (length xs))
         (eval e
               (foldr
                (lambda (s*e res) (extend-env (fst s*e) (eval (snd s*e) env fun-env) res))
                fun-env
                (zip args xs))
               fun-env)
         (error 'eval "apply: wrong number of arguments"))]
    [else (error 'eval "apply: expected a function")]))

; run -----------------------------------------------

(define-type-alias Value Number)
         
(define (run [s : S-Exp]) : Value
  (type-case Answer  (eval (parse s) init-env init-env)
    [(numA n) n]
    [else (error 'run "expected a number")]))




; ------------------- TESTS -------------------------

; parsing tests -------------------------------------

(module+ test
  (test (parse `{define {} for 5})
        (defE empty (numE 5)))
  (test (parse `{define {[fun f () = 3]} for
                  {let x be 2 in {f {}}}})
        (defE
          (list (funE 'f empty (numE 3)))
          (letE 'x (numE 2) (appE 'f empty))))
  (test (parse `{define {} for {5 - 6}})
        (defE empty (opE '- (numE 5) (numE 6))))
  (test (parse `{define
                  {[fun f (x) = {ifz {x <= 1} then 2 else 3}]}
                  for {f (x)}})
        (defE
          (list (funE 'f (list 'x)
                      (ifE (opE '<= (varE 'x) (numE 1)) (numE 2) (numE 3))))
          (appE 'f (list (varE 'x)))))
  (test (parse `{define {} for
                  {2 + {5 <= 6}}})
        (defE empty (opE '+ (numE 2) (opE '<= (numE 5) (numE 6)))))
  (test (parse `{define
                  {[fun + (x y) = {x + y}]}
                  for
                  {+ (1 2)}})
        (defE (list (funE '+ (list 'x 'y) (opE '+ (varE 'x) (varE 'y))))
          (appE '+ (list (numE 1) (numE 2))))))

(module+ test
  (test/exn (parse `5)
            "parse: wrong structure of a program")
  (test/exn (parse `{define {[fun f (x) = x]} for})
            "parse: wrong structure of a program")
  (test/exn (parse `{define {} for
                      {2 + {3 - {+ 7 7}}}})
            "parse: invalid input")
  (test/exn (parse `{define {[fun f (x y z x) = {x + x}]} for
                      2})
            "parse: duplicate function arguments")
  (test/exn (parse `{define {} for
                      {2 ^ 2}})
            "parse: unknown operator")
  (test/exn (parse `{define {[fun f (x) = x]
                             [fun g (x) = x]
                             [fun h (x) = x]
                             [fun f (y) = y]} for
                      {f ({g ({h ({f (5)})})})}})
            "parse: duplicate function names")
  (test/exn (parse `{define {[fun f x = x]} for 5})
            "parse: function syntax error")
  (test/exn (parse `{define {[fun f (x y 5 z h) = x]} for
                      {f (x)}})
            "parse: function arguments: expected a symbol")
  (test/exn (parse `{define {} for
                      [fun f (x y) = x]})
            "parse: invalid input")
  (test/exn (run `{define {} for
                    {2 + 2 + 2}})
            "parse: invalid input")
  (test/exn  (run `{define
                     {[fun f (x y) = {x + y}]}
                     for
                     {5 f 3}})
             "parse: unknown operator"))
  

; run & eval tests ----------------------------------

(module+ test
  (test (run `{define {} for {2 + 2}})
        4)
  (test (run `{define {} for
                {2 - {3 + {7 * {1 <= 0}}}}})
        -8)
  (test (run `{define {} for
                {let x be 7 in
                  {{let x be 8 in
                     {let y be 9 in
                      {x + y}}}
                   + x}}})
        24)
  (test (run `{define
                {[fun fact (n) = {ifz n then 1 else {n * {fact ({n - 1})}}}]}
                for
                {fact (5)}})
        120)
  (test (run `{define
                {[fun even (n) = {ifz n then 0 else {odd ({n - 1})}}]
                 [fun odd (n) = {ifz n then 42 else {even ({n - 1})}}]}
                for
                {even (1024)}})
        0)
  (test (run `{define
                {[fun gcd (m n) = {ifz n
                                       then m
                                       else {ifz {m <= n}
                                                 then {gcd (m {n - m})}
                                                 else {gcd ({m - n} n)}}}]}
                for
                {gcd (81 63)}})
        9)
  (test (run `{define
                {[fun fib (n) = {ifz {n <= 1}
                                        then n
                                        else {{fib ({n - 1})} + {fib {(n - 2)}}}}]}
                for
                {fib (10)}})
        55)
  (test  (run `{define
                 {[fun f (x y) = {ifz x then y else x}]
                  [fun g (x) = x]}
                 for
                 (let x be 1 in {f (x g)})})
         1)
  (test (run `{define
                {[fun f () = {g (3)}]
                 [fun g (x) = x]}
                for
                {f ()}})
        3)
  (test (run `{define
                {[fun f () = {g (3 3)}]
                 [fun g (x) = x]}
                for
                {g (3)}})
        3)
  (test (run `{define {}
                for
                {ifz 0 then 3 else {f (x)}}})
        3)
  (test (run `{define
                {[fun + (x y) = 3]
                 [fun - (x y) = 7]}
                for
                {1 + {+ (2 2)}}})
        4)
  (test (run `{define
                {[fun f (x) = {x + 1}]}
                for
                (let x be 1 in
                  {let y be x in
                    {let x be {f (x)} in
                      y}})})
        1)
  (test (run `{define {[fun + () = 3]}
                for
                {{+ ()} + {+ ()}}})
        6)
  (test (run `{define {[fun + () = 3]}
                for
                {let + be 1 in
                  {+ + +}}})
        2))

(module+ test
  (test/exn (run `{define {} for
                    {let x be y in 1}})
            "lookup-env: undefined object")
  (test/exn (run `{define {} for
                    {f (5)}})
            "lookup-env: undefined object")
  (test/exn (run `{define
                    {[fun f (x y) = {x + y}]}
                    for
                    {f (5)}})
            "eval: apply: wrong number of arguments")
  (test/exn (run `{define
                    {[fun f (x y z) = 3]}
                    for
                    {f (1 2 3 4)}})
            "eval: apply: wrong number of arguments")
  (test/exn (run `{define
                    {[fun f (x y) = {ifz x then y else x}]
                     [fun g (x) = x]}
                    for
                    (let x be 1 in {x (5)})})
            "eval: apply: expected a function")
  (test/exn (run `{define
                    {[fun f (x y) = {ifz x then y else x}]
                     [fun g (x) = x]}
                    for
                    (let x be 1 in {f (g x)})})
            "eval: expected a number")
  (test/exn (run `{define
                    {[fun f (x y) = {x + y}]
                     [fun g (z) = {x + z}]}
                    for
                    {g (5)}})
            "lookup-env: undefined object")
  (test/exn (run `{define {[fun f (x) = x]} for
                    f})
            "run: expected a number")
  (test/exn (run `{define {} for {+ (2 3 4)}})
            "lookup-env: undefined object")
  (test/exn (run `{define {[fun g (x) = {x + 1}]
                           [fun h (x) = {x - 1}]}
                    for
                    {3 + g}})
            "eval: expected a number")
  (test/exn (run `{define {[fun g (x) = {x + 1}]
                           [fun h (x) = {x - 1}]}
                    for
                    {g + 3}})
            "eval: expected a number")
  (test/exn (run `{define {[fun g (x) = {x + 1}]
                           [fun h (x) = {x - 1}]}
                    for
                    {3 <= g}})
            "eval: expected a number")
  (test/exn (run `{define {[fun g (x) = {x + 1}]
                           [fun h (x) = {x - 1}]}
                    for
                    {g <= 3}})
            "eval: expected a number")
  (test/exn (run `{define {[fun + () = 3]}
                    for
                    {let + be 1 in
                      {+ + {+ ()}}}})
            "eval: apply: expected a function")
  (test/exn (run `{define {[fun f (x) = {x + y}]}
                    for
                    {let y be 1 in
                      {f (3)}}})
            "lookup-env: undefined object")
  (test/exn (run `{define {[fun f (x) = {g (x)}]}
                    for
                    {let y be 1 in
                      {f (3)}}})
            "lookup-env: undefined object")
  (test/exn (run `{define {[fun f (x) = {x + y}]
                           [fun g (y) = {5 + y}]}
                    for
                    {f ({g (6)})}})
            "lookup-env: undefined object")
  (test/exn (run `{define {[fun f (x) = {x + y}]
                           [fun g (y) = {5 + y}]}
                    for
                    {g ({f (6)})}})
            "lookup-env: undefined object"))