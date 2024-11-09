;; title: clarity-basics-iii
(define-read-only (list-bool) 
  (list true false true)
)
(define-read-only (list-uint) 
  (list u10 u11 u12)
)
(define-read-only (list-string) 
  (list "Hello" "this" "jones")
)
(define-read-only (list-principal) 
  (list 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND)
)

(define-data-var num-list (list 10 uint) (list u1 u2 u3 u4))
(define-data-var principal-list (list 5 principal) (list tx-sender 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND))

(define-read-only (show-num-list) 
  (var-get num-list)
)

;; Element-At (index => value) is a clarity in-built function to find an element in a list by passing -in the index.
(define-read-only (element-at-num-list (index uint)) 
  (element-at (var-get num-list) index)
)

(define-read-only (element-at-principal-list (index uint)) 
  (element-at (var-get principal-list) index)
)

;; index-of (value => index) is a clarity in-built function that takes the value of a specific element and then returns it index.
(define-read-only (index-of-num-list (value uint)) 
  (index-of (var-get num-list) value)
)

(define-read-only (index-of-principal-list (value principal)) 
  (index-of (var-get principal-list) value)
)

;; Day 21 - list continued and introduction to unwrapping
(define-data-var list-day-21 (list 6 uint) 
  (list u1 u2 u3 u4 u5)
)

(define-data-var list-day-int (list 7 int) 
  (list 1 2 3 4 5)
)
;; using the len method - to check the length of a list
(define-read-only (length-of-list) 
  (len (var-get list-day-21))
)

(define-read-only (show-list-int) 
  (var-get list-day-int)
)

;; using append, unwrap and as-max-len to append a value to a list and make sure it doesn't add after it hits it max-length.
(define-public (add-to-list (new-num uint))
  (ok (var-set list-day-21 
      (unwrap! (as-max-len? (append (var-get list-day-21) new-num) u6) (err u0))
  )) 
)


;; Day 22 - Introduction to unwrapping ii
;; Unwrap! => accepts optionals & response
;; Unwrap-err => accepts only a response
;; Unwrap-panic => accepts optional & response
;; unwrap-err-panic => accepts 
;; Try! => accepts optionals & response
(define-public (unwrap-example (new-num uint))
  (ok (var-set list-day-21 
      (unwrap! (as-max-len? (append (var-get list-day-21) new-num) u6) (err "error list at max length"))
  )) 
)

(define-public (unwrap-example-ii (num int)) 
  (ok (var-set list-day-int 
        (unwrap!
          (as-max-len? 
            (append (var-get list-day-int) num) 
            u7)
          (err "list not found or over limit")
        )
      )
  )
)

(define-public (unwrap-panic-example (new-num uint))
  (ok (var-set list-day-21 
      (unwrap-panic (as-max-len? (append (var-get list-day-21) new-num) u6))
  )) 
)


(define-public (unwrap-err-example (input (response uint uint))) 
  (ok (unwrap-err! input (err u10)))
)

(define-public (try-example (input (response uint uint))) 
  (ok (try! input))
)

;; Day 23 - Default-to  / get
(define-constant example-tuple (some {
  example-bool: true,
  example-num: none,
  example-string: none,
  example-principal: tx-sender
  })
)

(define-read-only (read-example-tuple) 
  (default-to {example-bool: false, example-num: (some u2), example-string: (some "hello"), example-principal: tx-sender} example-tuple)
)

(define-read-only (read-principal) 
  (get example-principal example-tuple)
)

(define-read-only (read-bool) 
  (get example-bool example-tuple)
)

(define-read-only (read-default) 
  (get example-num example-tuple)
)

(define-read-only (read-string) 
  (get example-string example-tuple)
)

;; Day 24 - conditionals continued
;; Match & if
;; if
(define-read-only (if-example (test-bool bool)) 
  (if test-bool 
    ;; evaluates to true
    "evaluated to true" 
    ;; evaluates to false
    "evaluate to false"
    )
)

(define-read-only (if-example-num (num uint)) 
  (if (and (> num u0) (< num u10))
    ;; evaluates to true
    num
    ;; evaluates to false
    u10
  )
)

;; Match
(define-read-only (match-example-option) 
  (match (some u1) 
    ;; some value / there was an optional
    match-value (+ u5 match-value) 
    ;; no value / there was no optional
    u0
  )
)

;; match with optionals
(define-read-only (match-optional (test-value (optional uint))) 
  (match test-value 
    match-value (+ u2 match-value)
    u0  
  )
)
;; match with response
(define-read-only (match-response (test-value (response uint uint))) 
  (match test-value
    ok-value (+ u5 ok-value)
    err-value u0
  )
)

;; day 25 -  Maps
(define-map first-map principal (string-ascii 24))

(define-public (set-first-map (username (string-ascii 24 ))) 
  (ok (map-set first-map tx-sender username))
)

(define-read-only (get-first-map (key  principal)) 
  (map-get? first-map key)
)

(define-map second-map principal { 
  username: (string-ascii 24),
  balance: uint,
  refferal: (optional principal)
})

(define-public (set-second-map (new-username (string-ascii 24)) (new-balance uint) (new-refferal (optional principal))) 
  (ok (map-set second-map tx-sender {
      username: new-username,
      balance: new-balance,
      refferal: new-refferal
    })
  )
)

(define-read-only (get-second-map (key principal)) 
  (map-get? second-map key)
)

;; day 26 - Introduction to maps continued
;; map-insert
(define-public (insert-first-map (username (string-ascii 24 ))) 
  (ok (map-insert first-map tx-sender username))
)

(define-map third-map {user: principal, cohort: uint} { 
  username: (string-ascii 24),
  balance: uint,
  refferal: (optional principal)
})

(define-public (set-third-map (new-username (string-ascii 24)) (new-balance uint) (new-refferal (optional principal))) 
  (ok (map-set third-map {user: tx-sender, cohort: u1 } {
      username: new-username,
      balance: new-balance,
      refferal: new-refferal
    })
  )
)

(define-public (delete-third-map) 
  (ok (map-delete third-map {user: tx-sender, cohort: u1 }))
)

(define-read-only (read-third-map) 
  (map-get? third-map {user: tx-sender, cohort: u1 })
)