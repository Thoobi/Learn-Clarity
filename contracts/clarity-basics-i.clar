;; Clarity basics 1
;; Day 3- Booleans and Read-Only
;; Day 4- Uints, ints, simple operators
;; Here we want to review the the very basics of clarity
;; Parenthensis are common in clarity

;; Day 3
(define-read-only (show-true-i)
    true
)

(define-read-only (show-false-i) 
    false
)

(define-read-only (show-true-ii)
    (not false)
)

(define-read-only (show-false-ii)
    (not true)
)

;; Day 4
(define-read-only (add)
    (+ u1 u1)
)

(define-read-only (subtract)
    (- 1 2)
)

(define-read-only (multiply) 
    (* u3 u4)
)

;; division using Uint (unsigned integer)
(define-read-only (divide) 
    (/ u6 u0)
)

;; convert a Uint to int
(define-read-only (Uint-int) 
    (to-int u4)
)

;; convert int to Uint
(define-read-only (int-Uint) 
    (to-uint 5)
)

;; Day 5 - Advanced operators

(define-read-only (exponent) 
    (pow u2 u3)
)

(define-read-only (square-root) 
    (sqrti (* u6 u6))
)

(define-read-only (modulo) 
    (mod u20 u2)
)

(define-read-only (log-two) 
    (log2 (* u2 (+ u8 u8)))
)

;; Day 6 - Strings

(define-read-only (sayhello)
    "Hello"
)

(define-read-only (sayhelloworld)
    (concat "Hello" " world")
)

(define-read-only (say-hello-world-name) 
    (concat 
        (concat "Hello" " World,") 
        " Daniel"
    )
)

;; Day 7 - And/Or logical operator

;; And makes sure all is true
(define-read-only (and-i) 
    (and true true) ;; true
)

(define-read-only (and-ii) 
    (and true false) ;;false
)

(define-read-only (and-iii) 
    (and 
        (> u2 u1) 
        (not false) ;;true
    )  
)

;; Makes sure one is true
(define-read-only (or-i) 
    (or true false)
)

(define-read-only (or-ii) 
    (or (not true) false)
)

(define-read-only (or-iii) 
    (or 
        (< u2 u1)
        (not true)
        (and 
            (> u2 u1)
            true
        )
    )
)