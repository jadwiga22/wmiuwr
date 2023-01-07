#lang racket

(require rackunit)

(provide (struct-out column-info)
         (struct-out table)
         (struct-out and-f)
         (struct-out or-f)
         (struct-out not-f)
         (struct-out eq-f)
         (struct-out eq2-f)
         (struct-out lt-f)
         table-insert
         table-project
         table-sort
         table-select
         table-rename
         table-cross-join
         table-natural-join)

(define-struct column-info (name type) #:transparent)
(define-struct table (schema rows) #:transparent)  

(define cities
  (table
   (list (column-info 'city    'string)
         (column-info 'country 'string)
         (column-info 'area    'number)
         (column-info 'capital 'boolean))
   (list (list "Wrocław" "Poland"  293 #f)
         (list "Warsaw"  "Poland"  517 #t)
         (list "Poznań"  "Poland"  262 #f)
         (list "Berlin"  "Germany" 892 #t)
         (list "Munich"  "Germany" 310 #f)
         (list "Paris"   "France"  105 #t)
         (list "Rennes"  "France"   50 #f))))

(define countries
  (table
   (list (column-info 'country 'string)
         (column-info 'population 'number))
   (list (list "Poland" 38)
         (list "Germany" 83)
         (list "France" 67)
         (list "Spain" 47))))

(define example-row-cities
  (list "Rzeszow" "Poland" 129 #f))
(define example-row-cities-2
  (list "Rzeszow" "Poland" "sdjs" #f))
(define example-row-cities-3
  (list "Paris" "France" 0 #f))
(define example-row-cities-4
  (list "Munich" "Germany" 0 #f))

(define (empty-table columns) (table columns '()))
(define example-empty
  (empty-table (list (column-info 'c 'string)
                     (column-info 'g 'number)
                     (column-info 'b 'boolean)
                     (column-info 'a 'symbol)
                     (column-info 'd 'string))))
               
                 

; Wstawianie

(define (type? col)
  (lambda (x)
    (cond [(equal? (column-info-type col) 'string) (string? x)]
          [(equal? (column-info-type col) 'number) (number? x)]
          [(equal? (column-info-type col) 'boolean) (boolean? x)]
          [else (symbol? x)])))

(check-equal? ((type? (caddr (table-schema cities))) "sdsd") #f)
(check-equal? ((type? (caddr (table-schema cities))) 7) #t)

(define (fold-table f x xs cols)
  (if (null? xs)
      x
      (f (car xs) (car cols) (fold-table f x (cdr xs) (cdr cols)))))

(define (correct? row tab)
  (if (and (list? row) (= (length (table-schema tab)) (length row)))
      (fold-table
       (lambda (r c fo)
         (and
          fo
          ((type? c) r)))
       #t
       row
       (table-schema tab))
      #f))

(check-equal? (correct? example-row-cities cities) #t)
(check-equal? (correct? example-row-cities-2 cities) #f)

(define (table-insert row tab)
  (if (correct? row tab)
      (table (table-schema tab) (cons row (table-rows tab)))
      (error 'error)))

(check-equal? (car (table-rows (table-insert example-row-cities cities)))
              example-row-cities)

; Projekcja

(define (pos a f xs)
  (define (it a ys acc)
    (cond [(null? ys) #f]
          [(equal? a (f (car ys)))  acc]
          [else  (it a (cdr ys) (+ acc 1))]))
  (it a xs 0))

(check-equal? (pos 2 (lambda (x) x) '(1 2 3)) 1)
(check-equal? (pos 2 column-info-name (list (column-info 'example-col 'string)
                                            (column-info 'example-col-2 'number)))
              #f)

(define (row-elem row col-name tab)
  (fold-table
   (lambda (r c fo)
     (if (equal? (column-info-name c) col-name)
         r
         fo))
   null
   row
   (table-schema tab)))

(check-equal? (row-elem example-row-cities 'city cities) "Rzeszow")
(check-equal? (row-elem example-row-cities 'area cities) 129)
                        
(define (normalize row xs tab)
  (map
   (lambda (x)
     (row-elem row x tab))
   xs))

(check-equal? (normalize example-row-cities '(country area) cities)
              '("Poland" 129))
     
(define (table-project cols tab)
  (let ([cols2 (filter (lambda (x) (number? (pos x column-info-name (table-schema tab)))) cols)])
    (table
     (normalize (table-schema tab) cols2 tab)
     (map
      (lambda (x) (normalize x cols2 tab))
      (table-rows tab)))))

(check-equal? (table-project '(city country area capital) cities) cities)
  

; Sortowanie

(define (relation x y)
  (cond [(string? x) (string<? x y)]
        [(number? x) (< x y)]
        [(symbol? x) (symbol<? x y)]
        [else (and (equal? x #f) (equal? y #t))]))

; zwracamy prawdę tylko jak jest ostro mniejsze-> żeby zapewnić stabliność sort

(define (cmp a b tab xs)
  (cond [(null? xs) #f]
        [else (let ([x (row-elem a (car xs) tab)]
                    [y (row-elem b (car xs) tab)])
                (cond [(relation x y) #t]
                      [(relation y x) #f]
                      [else (cmp a b tab (cdr xs))]))]))

(define (table-sort cols tab)
  (let ([cols2 (filter (lambda (x) (number? (pos x column-info-name (table-schema tab)))) cols)])
    (table
     (table-schema tab)
     (sort (table-rows tab) (lambda (x y) (cmp x y tab cols2))))))

(check-equal? (car (car (table-rows (table-sort '(area) cities))))
              "Rennes")
(check-equal? (car (car (table-rows (table-sort '(country) cities))))
              "Paris")
                 
      

; Selekcja

(define-struct and-f (l r))
(define-struct or-f (l r))
(define-struct not-f (e))
(define-struct eq-f (name val))
(define-struct eq2-f (name name2))
(define-struct lt-f (name val))

(define (satisfies? formula row tab)
  (cond [(and-f? formula)
         (and (satisfies? (and-f-l formula) row tab)
              (satisfies? (and-f-r formula) row tab))]
        [(or-f? formula)
         (or (satisfies? (or-f-l formula) row tab)
             (satisfies? (or-f-r formula) row tab))]
        [(not-f? formula)
         (not (satisfies? (not-f-e formula) row tab))]
        [(eq-f? formula)
         (equal? (eq-f-val formula)
                 (row-elem row (eq-f-name formula) tab))]
        [(eq2-f? formula)
         (equal? (row-elem row (eq2-f-name formula) tab)
                 (row-elem row (eq2-f-name2 formula) tab))]
        [else (relation (row-elem row (lt-f-name formula) tab) (lt-f-val formula))]))

(check-equal?
 (and (satisfies? (or-f (lt-f 'city "zzz") (eq2-f 'city 'capital))
                  example-row-cities
                  cities)
      (satisfies? (eq-f 'area 129)
                  example-row-cities
                  cities))
 #t)
          
(define (table-select form tab)
  (table
   (table-schema tab)
   (filter (lambda (x) (satisfies? form x tab)) (table-rows tab))))

(check-equal?  (table-rows (table-select (and-f (eq-f 'capital #t)
                                                (not-f (lt-f 'area 300)))
                                         cities))
               (list (list "Warsaw" "Poland" 517 #t)
                     (list "Berlin" "Germany" 892 #t)))


; Zmiana nazwy

(define (table-rename col ncol tab)
  (table
   (map
    (lambda (x)
      (if (equal? (column-info-name x) col)
          (column-info ncol (column-info-type x))
          x))
    (table-schema tab))
   (table-rows tab)))

(check-equal?
 (pos 'name column-info-name (table-schema (table-rename 'city 'name cities)))
 (pos 'city column-info-name (table-schema cities)))
              

; Złączenie kartezjańskie

(define (part-of-cross-join row tab)
  (foldr
   (lambda (x y)
     (cons (append row x) y))
   null
   (table-rows tab)))

(check-equal? (part-of-cross-join example-row-cities countries)
              '(("Rzeszow" "Poland" 129 #f "Poland" 38)
                ("Rzeszow" "Poland" 129 #f "Germany" 83)
                ("Rzeszow" "Poland" 129 #f "France" 67)
                ("Rzeszow" "Poland" 129 #f "Spain" 47)))

(define (table-cross-join tab1 tab2)
  (table
   (append (table-schema tab1) (table-schema tab2))
   (foldr
    (lambda (x y)
      (append (part-of-cross-join x tab2) y))
    null
    (table-rows tab1))))

(check-equal?
 (length (table-rows (table-cross-join cities countries)))
 (* (length (table-rows cities)) (length (table-rows countries))))

; Złączenie

(define (list-to-rename tab1 tab2)
  (foldr
   (lambda (x y)
     (if (number? (pos (column-info-name x) column-info-name (table-schema tab2)))
         (cons (cons (column-info-name x) (gensym "loremipsum")) y)
         y))
   null
   (table-schema tab1)))

(check-equal? (caar (list-to-rename cities countries)) 'country)

(define (list-of-unchanged tab ls)
  (map
   column-info-name
   (filter
    (lambda (x)
      (equal? (pos (column-info-name x) cdr ls) #f))
    (table-schema tab))))

(define example-rename (list-to-rename cities countries))
(check-equal? (list-of-unchanged  cities '((cokolwiek . country) (cokolwiek2 . city)))
              '(area capital))

(define (collective-rename tab ls)
  (foldr
   (lambda (x y)
     (table-rename (car x) (cdr x) y))
   tab
   ls))

(check-equal? (list-of-unchanged (collective-rename cities example-rename) example-rename)
              '(city area capital))
(check-equal? (list-of-unchanged (collective-rename countries example-rename) example-rename)
              '(population))

(define (make-formula ls)
  (let ([cur (eq2-f (car (car ls)) (cdr (car ls)))])
    (if (null? (cdr ls))
        cur
        (and-f cur (make-formula (cdr ls))))))

(check-equal? (eq2-f-name (make-formula example-rename)) (caar example-rename))
(check-equal? (eq2-f-name2 (make-formula example-rename)) (cdar example-rename))

(define (table-natural-join tab1 tab2)
  (let ([ls (list-to-rename tab1 tab2)])
    (let ([tab (table-cross-join tab1 (collective-rename tab2 ls))])
      (if (null? ls)
          (empty-table (table-schema tab))
          (table-project
           (list-of-unchanged tab ls)
           (table-select (make-formula ls) tab))))))

(check-equal?
 (table-natural-join cities countries)
 (table
  (list
   (column-info 'city 'string)
   (column-info 'country 'string)
   (column-info 'area 'number)
   (column-info 'capital 'boolean)
   (column-info 'population 'number))
  '(("Wrocław" "Poland" 293 #f 38)
    ("Warsaw" "Poland" 517 #t 38)
    ("Poznań" "Poland" 262 #f 38)
    ("Berlin" "Germany" 892 #t 83)
    ("Munich" "Germany" 310 #f 83)
    ("Paris" "France" 105 #t 67)
    ("Rennes" "France" 50 #f 67))))