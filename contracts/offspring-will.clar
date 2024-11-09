;; Offspring-Will
;; description: Smart contract that allows parents to create and fund wallets, unlockable only by assigned offspring
;; written by daniel

;; Offspring wallet
;; this is our main map that is created and funded by a parent, & only unlockable by an assigned offspring (principal)
;; principal -> {offspring-principal: principal, offspring-dob: uint, balance: uint}
;; 1. Create Wallet
;; 2. Fund Wallet
;; 3. Claim Wallet
  ;; A. Offspring
  ;; B. Parent/Admin

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; consts, vars & maps ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Deployer
(define-constant deployer tx-sender)

;; Contract
(define-constant contract (as-contract tx-sender))

;; Create offspring wallet fee
(define-constant create-wallet-fee u5000000)

;; Add offspring wallet funds fee
(define-constant add-wallet-funds-fee u2000000)

;; Minimum Add offspring wallet funds amount
(define-constant minimum-add-wallet-amount u5000000)

;; Early withdrawal fee (10%)
(define-constant early-withdraw-fee u10)

;; Normal withdraw fee (2%)
(define-constant normal-withdraw-fee u2)

;; 18 years in Block Height
(define-constant eighteen-years-in-block-height (* u18 (* u365 u144)))

;; List of admins
(define-data-var admin (list 10 principal) (list tx-sender))

;; Total Fees Earned
(define-data-var total-fees-earned uint u0)

;; Offspring Wallet
(define-map offspring-wallet principal { 
  offspring-principal: principal,
  offspring-dob: uint,
  balance: uint
})

;;;;;;;;;;;;;;;;;;;;;
;; Read Functions ;;;
;;;;;;;;;;;;;;;;;;;;;

;; Get offspring wallet
(define-read-only (get-offspring-wallet (parent principal)) 
  (map-get? offspring-wallet parent)
)

;; Get offspring wallet balance
(define-read-only (get-offspring-wallet-balance (parent principal))
  (default-to u0 (get balance (map-get? offspring-wallet parent)))
)

;; Get offspring principal
(define-read-only (get-offspring-principal (parent principal))
  (get offspring-principal (map-get? offspring-wallet parent))
)

;; Get offspring DOB
(define-read-only (get-offspring-dob (parent principal))
  (get offspring-dob (map-get? offspring-wallet parent))
)

;; Get offspring wallet Unlock Height
(define-read-only (get-offspring-wallet-unlock-height (parent principal)) 
  (let 
    (
      ;; Local variables
      (offspring-dob (unwrap! (get-offspring-dob parent) (err u1)))
    ) 
      ;; Func body
      (ok (+ offspring-dob eighteen-years-in-block-height))
      
  )
)
 
;; Get Earned Fees
(define-read-only (get-earned-fees) 
  (var-get total-fees-earned)
)

;; Get STX in contract
(define-read-only (get-contract-stx-balance) 
  (stx-get-balance contract)
)

;;;;;;;;;;;;;;;;;;;;;;;
;; private functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-parent-or-owner (parent principal))
  ;; Assert that tx-sender is either parent or tx-sender is one of the admins
      (asserts! (or (is-eq tx-sender parent) (is-none (index-of? (var-get admin) tx-sender))) false)

)

;;;;;;;;;;;;;;;;;;;;;;;
;; parent functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Create Wallet
;; @desc - creates new offspring wallet with new parent (no initial deposit)
;; @params - new-offspring-principal: principal, new-offspring-dob: uint
(define-public (create-wallet (new-offspring-principal principal) (new-offspring-dob uint)) 
  (let 
    (
      ;; local variables
      (current-total-fees (var-get total-fees-earned))
      (new-total-fee (+ current-total-fees create-wallet-fee))
    )
      ;; Assert that map-get? offspring-wallet is-none
      (asserts! (is-none (map-get? offspring-wallet tx-sender)) (err u2))

      ;; Assert that new offspring-date of birth is higher than block-height - 18 years of block
      (asserts! (> new-offspring-dob (- block-height eighteen-years-in-block-height)) (err u3))

      ;; Assert that new-offspring-principal is NOT an admin or the tx-sender
      (asserts! (or (not (is-eq new-offspring-principal tx-sender)) (is-none (index-of? (var-get admin) new-offspring-principal))) (err u4))

      ;; Pay create-wallet-fee in stx (5 stx)
      (unwrap! (stx-transfer? create-wallet-fee tx-sender deployer) (err u5))

      ;; Var-set total fees
      (var-set total-fees-earned new-total-fee)

      ;; Map-set new offspring-wallet
      (ok (map-set offspring-wallet tx-sender {
          offspring-principal: new-offspring-principal, 
          offspring-dob: new-offspring-dob, 
          balance: u0}
        ))

  )
)


;; Fund Wallet
;; @desc - Allows anyone to fund and existing wallet
;; @params -  parent: principal, amount: uint
(define-public (fund-wallet (parent principal) (amount uint)) 
  (let 
    (
      ;; local vars
      (current-offspring-wallet (unwrap! (map-get? offspring-wallet parent) (err "err-no-offspring-wallet")))
      (current-offspring-wallet-balance (get balance current-offspring-wallet))
      (new-offspring-wallet-balance (+ (- amount add-wallet-funds-fee) current-offspring-wallet-balance))
      (current-total-fees (var-get total-fees-earned))
      (new-total-fees (+ current-total-fees minimum-add-wallet-amount))
    )
      ;; Func body
      ;; Assert that amount is higher that min-add-wallet-amount (5 stx)
      (asserts! (> amount minimum-add-wallet-amount) (err "not-enough-stx"))

      ;; Send stx (amount - fee) to contract
      (unwrap! (stx-transfer? (- amount add-wallet-funds-fee) tx-sender contract) (err "err-sending-stx-to-contract"))

      ;; send stx (fee) to deployer
      (unwrap! (stx-transfer? add-wallet-funds-fee tx-sender deployer) (err "err-sending-stx-to-deployer"))

      ;; Var-set total fees
      (var-set total-fees-earned new-total-fees)

      ;; Map-set current offspring-wallet by merging with old balance + amount
      (ok (map-set offspring-wallet parent 
          (merge 
            current-offspring-wallet
            {balance: new-offspring-wallet-balance}
          )
        )
      )
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; offspring functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Claim Wallet
;; @desc - Allows offspring to claim wallet once and once only
;; @params -  parent: principal
(define-public (claim-wallet (parent principal)) 
  (let 
    (
      ;; local variables
      (current-offspring-wallet (unwrap! (map-get? offspring-wallet parent) (err "err-no-offspring-wallet")))
      (current-offspring (get offspring-principal current-offspring-wallet))
      (current-dob (get offspring-dob current-offspring-wallet))
      (current-balance (get balance current-offspring-wallet))
      (current-withdrawal-fee (/ (* current-balance u2) u100))
      (current-total-fees (var-get total-fees-earned))
      (new-total-fees (+ current-total-fees current-withdrawal-fee))
    )
      ;; Assert that tx-sender is-eq to offspring-principal
      (asserts! (is-eq current-offspring
      tx-sender) (err "err-not-offspring"))

      ;; Assert that the block-height is 18 years in block later than the offspring-dob
      (asserts! (> block-height (+ current-dob eighteen-years-in-block-height)) (err "err-not-eighteen"))

      ;; Send stx (amount - withdraw fee) to offspring
      (unwrap! (as-contract (stx-transfer? (- current-balance current-withdrawal-fee) tx-sender current-offspring)) (err "err-sending-stx-to-offspring"))

      ;; Send stx withdrawal to deployer
      (unwrap! (as-contract (stx-transfer? current-withdrawal-fee tx-sender deployer)) (err "err-sending-stx-to-deployer"))

      ;; Delete offspring-wallet map
      (map-delete offspring-wallet parent)

      ;; Update total-fees-earned
      (ok (var-set total-fees-earned new-total-fees))

  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emergency functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Emergency Claim
;; @desc - Allows either parent or an admin to withdraw all stx (minus emergency withdrawal fee), back to parent & removes wallet
;; @params -  parent: principal
(define-public (emergency-claim (parent principal)) 
  (let 
    (
      ;; local variables
      (current-offspring-wallet (unwrap! (map-get? offspring-wallet parent) (err "err-no-offspring-wallet")))
      (current-offspring-dob (get offspring-dob current-offspring-wallet))
      (current-balance (get balance current-offspring-wallet))
      (current-withdrawal-fee (/ (* current-balance u10) u100))
      (current-total-fees (var-get total-fees-earned))
      (new-total-fees (+ current-total-fees current-withdrawal-fee))
    )

      ;; Assert that block-height is less than 18 years from dob
      (asserts! (< block-height (+ current-offspring-dob eighteen-years-in-block-height)) (err "err-not-eighteen"))

      (is-parent-or-owner parent)

      ;; Send stx (amount - withdraw fee) to offspring
      (unwrap! (as-contract (stx-transfer? (- current-balance current-withdrawal-fee) tx-sender parent)) (err "err-sending-stx-to-offspring"))

      ;; Send stx withdrawal to deployer
      (unwrap! (as-contract (stx-transfer? current-withdrawal-fee tx-sender deployer)) (err "err-sending-stx-to-deployer"))

      ;; Delete offspring-wallet map
      (map-delete offspring-wallet parent)

      ;; Update total-fees-earned
      (ok (var-set total-fees-earned new-total-fees))
      
  )
)


;;;;;;;;;;;;;;;;;;;;;;
;; Admin functions ;;;
;;;;;;;;;;;;;;;;;;;;;;

;; Add admin
;; @desc - function to add an admin to existing admin-list
;; @param - new-admin: principal
(define-public (add-admin (new-admin principal)) 
  (let
    (
      (current-admins (var-get admin))
    ) 
      ;; Assert tx-sender is a current admin 
      (asserts! (is-some (index-of? current-admins tx-sender)) (err "err-not-authorised"))

      ;; Assert that new-admin does not exist in list of admins
      (asserts! (is-some (index-of? current-admins new-admin)) (err "err-duplicate-admins"))

      ;; Append new-admin to the admin list
      (ok (var-set admin 
        (unwrap! (as-max-len? (append current-admins new-admin) u10) (err "err-admin-list-overflow")
        ))
      )
  )
)