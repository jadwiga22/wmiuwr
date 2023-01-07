#lang racket
(require data/heap)
(require rackunit)

(provide sim? wire?
         (contract-out
          [make-sim        (-> sim?)]
          [sim-wait!       (-> sim? positive? void?)]
          [sim-time        (-> sim? real?)]
          [sim-add-action! (-> sim? positive? (-> any/c) void?)]

          [make-wire       (-> sim? wire?)]
          [wire-on-change! (-> wire? (-> any/c) void?)]
          [wire-value      (-> wire? boolean?)]
          [wire-set!       (-> wire? boolean? void?)]

          [bus-value (-> (listof wire?) natural?)]
          [bus-set!  (-> (listof wire?) natural? void?)]

          [gate-not  (-> wire? wire? void?)]
          [gate-and  (-> wire? wire? wire? void?)]
          [gate-nand (-> wire? wire? wire? void?)]
          [gate-or   (-> wire? wire? wire? void?)]
          [gate-nor  (-> wire? wire? wire? void?)]
          [gate-xor  (-> wire? wire? wire? void?)]

          [wire-not  (-> wire? wire?)]
          [wire-and  (-> wire? wire? wire?)]
          [wire-nand (-> wire? wire? wire?)]
          [wire-or   (-> wire? wire? wire?)]
          [wire-nor  (-> wire? wire? wire?)]
          [wire-xor  (-> wire? wire? wire?)]

          [flip-flop (-> wire? wire? wire? void?)]))

(struct wire
  ([simulation #:mutable] [value #:mutable] [actions #:mutable]))

(struct sim
  ([time #:mutable] [agenda #:mutable]))


; --------------------SYMULACJE---------------------------

(define (sim-any-events? s)
  (< 0 (heap-count (sim-agenda s))))

(define (compare-events x y)
  (<= (car x) (car y)))

(define (make-sim)
  (sim 0 (make-heap compare-events)))

(define (make-action s t f)
  (cons (+ (sim-time s) t) f))

(define (sim-apply-first-action s)
  (let ([a (heap-min (sim-agenda s))])
    (begin
      (heap-remove-min! (sim-agenda s))
      (set-sim-time! s (car a))
      ((cdr a)))))

(define (sim-wait! s t)
  (let ([lim (+ t (sim-time s))])
    (define (aux)
      (cond
        [(sim-any-events? s)
         (let ([a (heap-min (sim-agenda s))])
           (cond
             [(<= (car a) lim)
              (begin
                (sim-apply-first-action s)
                (aux))]
             [else (void)]))]
        [else (void)]))
    (begin
      (aux)
      (set-sim-time! s lim))))

(define (sim-add-action! s t act)
  (heap-add! (sim-agenda s) (make-action s t act)))


; testy symulacji

(define test-sim (make-sim))
(define test-sim-2 (make-sim))
(check-equal? (sim-any-events? test-sim) #f)
(sim-add-action! test-sim 1 (lambda ()  "first action"))
(sim-add-action! test-sim 1 (lambda () "second action"))
(sim-add-action! test-sim 3 (lambda () "third action"))
(check-equal? (sim-wait! test-sim 1) (void))
(check-equal? (sim-time test-sim) 1)
(check-equal? (sim-any-events? test-sim) #t)
(sim-wait! test-sim 4)
(check-equal? (sim-time test-sim) 5)


; --------------------PRZEWODY-----------------------------

(define (wire-sim w)
  (wire-simulation w))

(define (make-wire s)
  (wire s #f '()))

(define (call-actions xs)
  (if (null? xs)
      (void)
      (begin
        ((car xs))
        (call-actions (cdr xs)))))

(define (wire-on-change! w f)
  (begin
    (set-wire-actions! w (cons f (wire-actions w)))
    (f)))

(define (wire-set! w b)
  (if (equal? (wire-value w) b)
      (void)
      (begin
        (set-wire-value! w b)
        (call-actions (wire-actions w)))))
    

(define (bus-set! wires value)
  (match wires
    ['() (void)]
    [(cons w wires)
     (begin
       (wire-set! w (= (modulo value 2) 1))
       (bus-set! wires (quotient value 2)))]))

(define (bus-value ws)
  (foldr (lambda (w value) (+ (if (wire-value w) 1 0) (* 2 value)))
         0
         ws))


; testy przewodów

(define test-w1 (make-wire test-sim))
(define test-w2 (make-wire test-sim))
(define test-w3 (make-wire test-sim))
(define test-ws (list test-w1 test-w2))
(define test-ts "")

(wire-on-change! test-w1 (lambda () (set! test-ts (string-append
                                         "wire-action"
                                         (number->string (sim-time test-sim))))))
(wire-on-change! test-w1 (lambda () (set-wire-value! test-w3 (not (wire-value test-w1)))))
(check-equal? test-ts "wire-action5")
(check-equal? (wire-value test-w3) #t)
(bus-set! test-ws 2)
(check-equal? (bus-value test-ws) 2)
(check-equal? (wire-value test-w1) #f)
(check-equal? (wire-value test-w2) #t)
(wire-set! test-w1 #t)
(check-equal? (wire-value test-w3) #f)
(check-equal? test-ts "wire-action5")


; ------------------------BRAMKI---------------------------------

(define (make-gate op t res w1 w2)
  (define (action)
    (wire-set! res (op (wire-value w1) (wire-value w2))))
  (begin
    (wire-on-change! w1 (lambda () (sim-add-action! (wire-simulation res) t action)))
    (wire-on-change! w2 (lambda () (sim-add-action! (wire-simulation res) t action)))))

(define (gate-not res w)
  (define (not-action)
    (wire-set! res (not (wire-value w))))
  (wire-on-change! w (lambda () (sim-add-action! (wire-simulation res) 1 not-action))))

(define (gate-and res w1 w2)
  (make-gate (lambda (x y) (and x y)) 1 res w1 w2))

(define (gate-nand res w1 w2)
  (make-gate (lambda (x y) (not (and x y))) 1 res w1 w2))

(define (gate-or res w1 w2)
  (make-gate (lambda (x y) (or x y)) 1 res w1 w2))

(define (gate-nor res w1 w2)
  (make-gate (lambda (x y) (not (or x y))) 1 res w1 w2))

(define (gate-xor res w1 w2)
  (make-gate (lambda (x y) (or (and x (not y)) (and (not x) y))) 2 res w1 w2))


; testy bramek 

(define test-not (make-wire test-sim))
(gate-not test-not test-w2)
(define test-and (make-wire test-sim))
(gate-and test-and test-w2 test-w3)
(define test-nand (make-wire test-sim))
(gate-nand test-nand test-w2 test-w3)
(define test-or (make-wire test-sim))
(gate-or test-or test-w2 test-w3)
(define test-nor (make-wire test-sim))
(gate-nor test-nor test-w2 test-w3)
(define test-xor (make-wire test-sim))
(gate-xor test-xor test-w2 test-w3)

(sim-wait! test-sim 2)

(check-equal? (wire-value test-not) #f)
(check-equal? (wire-value test-and) #f)
(check-equal? (wire-value test-nand) #t)
(check-equal? (wire-value test-or) #t)
(check-equal? (wire-value test-nor) #f)
(check-equal? (wire-value test-xor) #t)


;-------------------PRZEWODY BRAMKOWE-----------------------------

(define (make-gate-wire gate w1 w2)
  (define res (make-wire (wire-simulation w1)))
  (gate res w1 w2)
  res)

(define (wire-not w)
  (define res (make-wire (wire-simulation w)))
  (gate-not res w)
  res)

(define (wire-and w1 w2)
  (make-gate-wire gate-and w1 w2))

(define (wire-nand w1 w2)
  (make-gate-wire gate-nand w1 w2))

(define (wire-or w1 w2)
  (make-gate-wire gate-or w1 w2))

(define (wire-nor w1 w2)
  (make-gate-wire gate-nor w1 w2))

(define (wire-xor w1 w2)
  (make-gate-wire gate-xor w1 w2))


; testy przewodów bramkowych

(define test-not-w (wire-not test-w2))
(define test-and-w (wire-and test-w2 test-w3))
(define test-nand-w (wire-nand test-w2 test-w3))
(define test-or-w (wire-or test-w2 test-w3))
(define test-nor-w (wire-nor test-w2 test-w3))
(define test-xor-w (wire-xor test-w2 test-w3))

(sim-wait! test-sim 2)

(check-equal? (wire-value test-not-w) (wire-value test-not))
(check-equal? (wire-value test-and-w) (wire-value test-and))
(check-equal? (wire-value test-nand-w) (wire-value test-nand))
(check-equal? (wire-value test-or-w) (wire-value test-or))
(check-equal? (wire-value test-nor-w) (wire-value test-nor))
(check-equal? (wire-value test-xor-w) (wire-value test-xor))


; --------------------PRZERZUTNIK----------------------

(define (flip-flop out clk data)
  (define sim (wire-sim data))
  (define w1  (make-wire sim))
  (define w2  (make-wire sim))
  (define w3  (wire-nand (wire-and w1 clk) w2))
  (gate-nand w1 clk (wire-nand w2 w1))
  (gate-nand w2 w3 data)
  (gate-nand out w1 (wire-nand out w3)))
  