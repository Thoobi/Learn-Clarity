;; clarity-basic-iv
;; reviewing clarity contract
;; written by setzeus /stratalabs

;; day 26.5 - Let
(define-data-var counter uint u0)
(define-map counter-history uint { user: principal, count: uint })

(define-private (increase-count-begin (increase-by uint)) 
  (begin 
    ;; asserts that tx-sender is not previous counter-history
    (asserts! (not (is-eq (some tx-sender) (get user (map-get? counter-history (var-get counter))))) (err u0))
    ;; Var set counter hsitory
    (map-set counter-history (var-get counter) {
      user: tx-sender,
      count: (+ increase-by (get count (unwrap! (map-get? counter-history (var-get counter)) (err u1))))
    })
    ;; var set increase counter
    (ok (var-set counter (+ (var-get counter) u1)))
  )
  
)

(define-public (increase-count-let (increase-by uint))
  (let
    (
      ;; local variables
      (current-counter (var-get counter))
      (current-counter-history (default-to {user: tx-sender, count: u0} (map-get? counter-history current-counter)))
      (previous-counter-user (get user current-counter-history))
      (previous-count-amount (get count current-counter-history))
    )
      ;; asserts that tx-sender is not previous counter-history
      (asserts! (not (is-eq tx-sender previous-counter-user)) (err u0))

      ;; var set counter history
      (map-set counter-history current-counter {
        user: tx-sender,
        count: (+ increase-by previous-count-amount)
      })
      ;; var-set increase counter 
      (ok (var-set counter (+ u1 current-counter)))
  )
)

;; Day 32 - Syntax
;; There are 2 different forms of syntax namely:
;; Trailing (heavy parenthensis that trail)
;; Encapsulate (highlights internal function)

(define-public (increase-count-trailing (increase-by uint)) 

  (begin 
    ;; Assert tx-sender is not previous counter-history user
    (asserts! 
      (not (is-eq 
        (some tx-sender) (get user (map-get? counter-history (var-get counter))))) (err u0))

    (ok 
      (var-set counter 
        (+ (var-get counter) u1)))

  )

)

(define-public (increase-count-encapsulation (increase-by uint)) 

  (begin 
    ;; Assert tx-sender is not previous counter-history user
    (asserts! 
      (not 
        (is-eq 
          (some tx-sender) 
          (get user (map-get? counter-history (var-get counter)))
        )) 
      (err u0))

    (ok 
      (var-set counter 
        (+ 
          (var-get counter) 
          u1
        )
      )
    )
  )

)

;; Day 33 - Stx-transfer?
;; Sending stacks to one address
(define-public (send-stx-single (amount uint) (reciever principal))
  (stx-transfer? amount tx-sender reciever)
)

(define-public (send-stx-double (amount1 uint) (amount2 uint) (reciever1 principal) (reciever2 principal)) 
  (begin
    (unwrap! (stx-transfer? amount1 tx-sender reciever1) (err u0))
    (stx-transfer? (/ amount2 u10) tx-sender reciever2)
  )
)

;; Day 34 - stx-get-balance & stx-burn
;; stx-get-balance

(define-read-only (balance-of)
  (stx-get-balance tx-sender)
)
(define-public (send-stx-balance (reciever principal))
  (stx-transfer? (stx-get-balance tx-sender) tx-sender reciever)
)

;; stx-burn?
(define-public (burn-some (amount uint)) 
  (stx-burn? amount tx-sender)
)

(define-public (burn-half-of-balance) 
  (stx-burn? (/ (stx-get-balance tx-sender) u2 ) tx-sender)
)

;; Day 35 - Block-height
(define-read-only (read-current-height) 
  block-height
)

;; day-in-block
(define-constant day-in-block u144)

(define-read-only (has-a-day-passed) 
  (if (> block-height day-in-block) 
    true
    false 
  )
)

(define-read-only (has-a-week-passed) 
  (if (> block-height (* day-in-block u7)) 
    true
    false
  )
)

;; Day 36 - As-contract

;; Principal -> contract
(define-public (send-to-contract-literal) 
  (stx-transfer? u1000000 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.clarity-basic-iv)
)

(define-public (send-to-contract-context) 
  (stx-transfer? u1000000 tx-sender (as-contract tx-sender))
)

;; Contract -> Principal
(define-public (send-as-contract) 
  (as-contract (stx-transfer? u1000000 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM))
)

(define-public (send-as-contract-ii) 
  (stx-transfer? u1000000 (as-contract tx-sender) tx-sender)
)