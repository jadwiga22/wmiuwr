#lang racket
(require rackunit)
(require "circuitsim.rkt")

; --------------------OGÓLNE---------------------

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

; --------------------PRZEWODY--------------------

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


;--------------------BRAMKI--------------------

;; AND

(define test-w4 (make-wire test-sim))
(gate-and test-w4 test-w1 test-w2)
(check-equal? (sim-time test-sim) 5)
(check-equal? (wire-value test-w4) #f)
(check-equal? (wire-value test-w1) #t)
(check-equal? (wire-value test-w2) #t)
(sim-wait! test-sim 1)
(check-equal? (wire-value test-w4) #t)
(check-equal? (wire-value test-w1) #t)
(check-equal? (wire-value test-w2) #t)
(wire-set! test-w1 #f)
(check-equal? (wire-value test-w4) #t)
(check-equal? (wire-value test-w1) #f)
(check-equal? (wire-value test-w2) #t)
(sim-wait! test-sim 1)
(check-equal? (wire-value test-w4) #f)
(check-equal? (wire-value test-w1) #f)
(check-equal? (wire-value test-w2) #t)

(check-equal? (sim-time test-sim-2) 0)

;; NOT, NOR, XOR

(define test-not-wire  (make-wire test-sim))
(define test-and-wire  (make-wire test-sim))
(define test-nand-wire (make-wire test-sim-2))
(define test-or-wire   (make-wire test-sim-2))
(define test-nor-wire  (make-wire test-sim))
(define test-xor-wire  (make-wire test-sim))

(define test-2-w1 (make-wire test-sim-2))
(define test-2-w2 (make-wire test-sim-2))
(define test-2-w3 (make-wire test-sim-2))

(gate-not test-not-wire test-w1)
(gate-xor test-xor-wire test-w1 test-w2)

(check-equal? (wire-value test-w1) #f)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #t)
(check-equal? (wire-value test-not-wire) #f)

(sim-wait! test-sim 1)

(check-equal? (wire-value test-w1) #f)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #t)
(check-equal? (wire-value test-not-wire) #t)
(check-equal? (wire-value test-xor-wire) #f)

(sim-wait! test-sim 1)

(check-equal? (wire-value test-w1) #f)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #t)
(check-equal? (wire-value test-not-wire) #t)
(check-equal? (wire-value test-xor-wire) #t)
(check-equal? (sim-time test-sim) 9)
(check-equal? (sim-time test-sim-2) 0)

(gate-nor test-nor-wire test-xor-wire test-not-wire)
(check-equal? (wire-value test-nor-wire) #f)
(sim-wait! test-sim 1)
(check-equal? (wire-value test-nor-wire) #f)
(wire-set! test-w1 #t)
(check-equal? (wire-value test-w1) #t)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #f)
(check-equal? (wire-value test-not-wire) #t)
(check-equal? (wire-value test-xor-wire) #t)

(sim-wait! test-sim 1)

(check-equal? (wire-value test-w1) #t)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #f)
(check-equal? (wire-value test-not-wire) #f)
(check-equal? (wire-value test-xor-wire) #t)
(check-equal? (wire-value test-nor-wire) #f)

(sim-wait! test-sim 1)

(check-equal? (wire-value test-w1) #t)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #f)
(check-equal? (wire-value test-not-wire) #f)
(check-equal? (wire-value test-xor-wire) #f)
(check-equal? (wire-value test-nor-wire) #f)

(sim-wait! test-sim 1)

(check-equal? (wire-value test-w1) #t)
(check-equal? (wire-value test-w2) #t)
(check-equal? (wire-value test-w3) #f)
(check-equal? (wire-value test-not-wire) #f)
(check-equal? (wire-value test-xor-wire) #f)
(check-equal? (wire-value test-nor-wire) #t)

;; NAND, OR

(define test-2-and-wire (make-wire test-sim-2))
(gate-and test-2-and-wire test-nand-wire test-or-wire)

(check-equal? (wire-value test-2-w1) #f)
(check-equal? (wire-value test-2-w2) #f)
(check-equal? (wire-value test-2-w3) #f)
(check-equal? (wire-value test-nand-wire) #f)
(check-equal? (wire-value test-or-wire) #f)
(check-equal? (wire-value test-2-and-wire) #f)

(gate-nand test-nand-wire test-2-w1 test-2-w2)
(gate-or test-or-wire test-2-w1 test-2-w3)

(check-equal? (wire-value test-2-w1) #f)
(check-equal? (wire-value test-2-w2) #f)
(check-equal? (wire-value test-2-w3) #f)
(check-equal? (wire-value test-nand-wire) #f)
(check-equal? (wire-value test-or-wire) #f)
(check-equal? (wire-value test-2-and-wire) #f)

(sim-wait! test-sim-2 1)

(check-equal? (wire-value test-2-w1) #f)
(check-equal? (wire-value test-2-w2) #f)
(check-equal? (wire-value test-2-w3) #f)
(check-equal? (wire-value test-nand-wire) #t)
(check-equal? (wire-value test-or-wire) #f)
(check-equal? (wire-value test-2-and-wire) #f)

(wire-set! test-2-w3 #t)
(check-equal? (wire-value test-2-w1) #f)
(check-equal? (wire-value test-2-w2) #f)
(check-equal? (wire-value test-2-w3) #t)
(check-equal? (wire-value test-nand-wire) #t)
(check-equal? (wire-value test-or-wire) #f)
(check-equal? (wire-value test-2-and-wire) #f)

(sim-wait! test-sim-2 1)
(check-equal? (wire-value test-2-w1) #f)
(check-equal? (wire-value test-2-w2) #f)
(check-equal? (wire-value test-2-w3) #t)
(check-equal? (wire-value test-nand-wire) #t)
(check-equal? (wire-value test-or-wire) #t)
(check-equal? (wire-value test-2-and-wire) #t)
