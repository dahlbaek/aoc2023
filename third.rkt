#lang racket

(define input
  (let* ([in (open-input-file "input.txt")]
         [list-of-chars (string->list (port->string in))]
         [list-of-strings (map string list-of-chars)])
    (close-input-port in)
    list-of-strings))

(define column-length (index-of input "\n"))
(define input-filtered (filter (lambda (b) (not (equal? b "\n"))) input))
(define input-filtered-length (length input-filtered))

(define (is-number x)
  (let ([converted (string->number x)])
    (not (not converted))))

(define (try-number x)
  (let ([converted (string->number x)])
    (if( not converted) x converted)))

(define (parse-input b idx acc)
  (let* ([y (floor (/ idx column-length))]
         [x (- idx (* y column-length))])
    (cond
      [(and (is-number b) (not (empty? acc)) (number? (cdr (first acc))) (equal? (car (car (first acc))) (- x 1)) (equal? (cdr (car (first acc))) y))
       (let* ([tail (cdr acc)]
              [head (car acc)]
              [b_number (string->number b)]
              [head_number (cdr head)])
         (cons (cons (cons x y) (+(* 10 head_number) b_number)) tail))]
      [else (cons (cons (cons x y) (try-number b)) acc)])))

(define coords
  (filter (lambda (x) (not (equal? (cdr x) ".")))
          (foldl parse-input '()  input-filtered (range input-filtered-length))))

(define symbols (make-hash (filter (lambda (x) (not (number? (cdr x)))) coords)))
(define maybe_parts (filter (lambda (x) (number? (cdr x))) coords))

(define (part? maybe_part)
  (let* ([coord (car maybe_part)]
         [num (cdr maybe_part)]
         [x (car coord)]
         [y (cdr coord)]
         [first-x (- x (string-length (number->string num)))]
         [x-range (range first-x (+ x 2))]
         [y-range (range (- y 1) (+ y 2))]
         [check-range (append
                       (map (lambda (a) (cons a (- y 1))) x-range)
                       (map (lambda (a) (cons a (+ y 1))) x-range)
                       (map (lambda (a) (cons first-x a)) y-range)
                       (map (lambda (a) (cons (+ x 1) a)) y-range))])
    (findf (lambda (idx) (hash-has-key? symbols idx)) check-range)))

(define parts (filter part? maybe_parts))

(define maybe_gears (map (lambda (g) (car g)) (filter (lambda (p) (equal? (cdr p) "*")) (hash->list symbols))))

(define (collect-gear part acc)
  (let* ([coord (car part)]
         [num (cdr part)]
         [x (car coord)]
         [y (cdr coord)]
         [first-x (- x (string-length (number->string num)))]
         [x-range (range first-x (+ x 2))]
         [y-range (range (- y 1) (+ y 2))]
         [check-range (append
                       (map (lambda (a) (cons a (- y 1))) x-range)
                       (map (lambda (a) (cons a (+ y 1))) x-range)
                       (list (cons first-x y))
                       (list (cons (+ x 1) y)))])
    (foldl
     (lambda (idx acc) (hash-update acc idx (lambda (v) (append (list part) v))))
     acc
     (filter (lambda (idx) (hash-has-key? acc idx)) check-range))))

(define gears-init (make-immutable-hash (map (lambda (g) (cons g '())) maybe_gears)))
(define gears (filter (lambda (g) (equal? (length (cdr g)) 2)) (hash->list (foldl collect-gear gears-init parts))))

; Part 1
(foldl + 0 (map (lambda (part) (cdr part)) parts))


; Part 2
(foldl + 0 (map (lambda (gear) (apply * (map (lambda (part) (cdr part)) (cdr gear)))) gears))
