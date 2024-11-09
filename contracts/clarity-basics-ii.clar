;; title: clarity-basics-ii

;; Covering Optionals and parameters

(define-read-only (show-some-i)
    (some u2)
)

(define-read-only (show-none-ii)
    none
)

(define-read-only (params (num uint) (string (string-ascii 48)) (boolean bool)) 
    num
)

(define-read-only (params-optional (num (optional uint)) (string (optional (string-ascii 48))) (boolean (optional bool))) 
    num
)

;; Day9 Optionals part 2

(define-read-only (is-some-example (num (optional uint))) 
    (is-some num) ;; return true if the respones is a (some uint)
)

(define-read-only (is-none-example (num (optional uint))) 
    (is-none num) ;; return true if the respones is a none
)

(define-read-only (params-optional-and (num (optional uint)) (string (optional (string-ascii 48))) (boolean (optional bool))) 
    (and (is-some num)
        (is-some string)
        (is-some boolean)
    )
)
(define-read-only (params-optional-or (num (optional uint)) (string (optional (string-ascii 48))) (boolean (optional bool))) 
    (or (is-some num)
        (is-some string)
        (is-some boolean)
    )
)

;; Day 10 - constants  & intro to variables
(define-constant fav-num u10)
(define-constant fav-name "Hi")
(define-data-var fav-num-var uint u11)
(define-data-var my-name (string-ascii 24) " Daniel ojo")

(define-read-only (show-constant) 
    fav-num 
)

(define-read-only (show-constant-double) 
    (* fav-num u2)
)

(define-read-only (show-fav-num-var) 
    (var-get fav-num-var)
)

(define-read-only (show-var-double) 
    (var-get fav-num-var)
)

(define-read-only (say-hi) 
    (concat fav-name (var-get my-name))
)

;; Day 11 - Public functions and Responses
(define-read-only (response-example) 
    (ok u10)
)

(define-public (change-name (new-name (string-ascii 24)))
    (ok (var-set my-name new-name))
)

(define-public (change-num (new-num uint))
    (ok (var-set fav-num-var new-num))
)

;; Day 12 - Tuples and Merging
(define-read-only (read-tuple) 
    {
        user-principal: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
        user-name: "Daniel",
        user-balance: u100
    }
)



;; write a tuple - Hint use the public function
(define-public (read-tuple-i (new-user-name (string-ascii 24)) (new-user-principle principal) (new-user-balance uint)) 
    (ok {
        user-principal: new-user-principle,
        user-name: new-user-name,
        user-balance: new-user-balance,
    })
)

(define-data-var original {user-principal: principal, user-name: (string-ascii 24),user-balance: uint}
    {
        user-principal: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
        user-name: "Daniel",
        user-balance: u100
    }
)

;; get a key from a tuple variable using the (get key-name variable-name)
(define-read-only (read-tuple-ii) 
    (get user-name (var-get original))
)

(define-public (update-tuple (user-name (string-ascii 24) ))
	(ok (merge 
			(var-get original)
			{user-name: user-name}
        )
    )
)


(define-public (merge-principal (new-user-principal principal)) 
    (ok (merge 
        (var-get original)
        {user-principal: new-user-principal}
    ))
)

(define-public (merge-name (new-user-name (string-ascii 24))) 
    (ok (merge 
        (var-get original)
        {user-name: new-user-name}
    ))
)

(define-public (merge-balance (new-user-balance uint)) 
    (ok (merge 
        (var-get original)
        {user-balance: new-user-balance}
    ))
)

(define-public (merge-all (new-user-name (string-ascii 24)) (new-user-principle principal) (new-user-balance uint)) 
    (ok (merge 
        (var-get original)
        {
            user-principal: new-user-principle,
            user-name: new-user-name,
            user-balance: new-user-balance,
        }
    ))
)

;; Day 13 - Introduction to keyword (Tx-sender) & is-eq conditionals

(define-read-only (show-tx-sender) 
    tx-sender
)

(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

(define-read-only (check-tx-sender) 
    (is-eq admin tx-sender)
)

;; Day 14 - conditionals i. Asserts

(define-read-only (show-asserts (num uint)) 
    (ok (asserts! (> num u2) (err u1)))
)

(define-constant err-too-large (err u1))
(define-constant err-too-small (err u2))
(define-constant err-not-auth (err u3))
(define-constant admin-one tx-sender)

(define-read-only (assert-admin) 
    (ok (asserts! (is-eq tx-sender admin-one) err-not-auth))
)

(define-public (use-begin)
	(begin
		(is-eq u0 u2)
		(ok (asserts! (not (is-eq u4 u5)) (err "error")))
    )	
)


;; Day 15 - Use begin

(define-data-var say-name (string-ascii 48) "Daniel")

(define-public (say-and-update-name (new-name (string-ascii 48)))
    (begin 
        (asserts! (not (is-eq "" new-name)) (err u1))
        (asserts! (not (is-eq (var-get say-name) new-name)) (err u2))
        (var-set say-name new-name)
        (ok (concat "Hello " (var-get say-name)))
    )
)

(define-read-only (new-name-ii)
    (var-get say-name)
)

(define-data-var counter uint u0)

(define-public (increment-counter (new-counter uint))
    (begin 
        (asserts! (is-eq u0 (mod new-counter u2)) (err u3))
        (ok (var-set counter (+ (var-get counter) new-counter)))
    )
)
(define-read-only (read-counter) 
    (var-get counter)
)