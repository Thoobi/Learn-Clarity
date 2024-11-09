;; title: community-hello-world
;; This is a contract that provides a simple community billboard, Readable by anyone but only updateable by admin permission.

;;;;;;;;;;;;;;;;;;;;;;;; 
;; consts, vars & maps;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; constants that set deployers as admin
(define-constant admin tx-sender)
(define-constant ERR-not-next-user-approved-by-admin u10)
(define-constant ERR-tx-sender-is-NOT-admin u11)
(define-constant ERR-updated-user-is-empty u12)
(define-constant ERR-updated-user-principle-is-admin u103)
(define-constant ERR-updated-user-principle-is-next-user u104)

;; variable that keeps track of the *next* user that will introduce themselves / write to the billboard

(define-data-var next-user principal tx-sender)

;; variable
(define-data-var billboard {new-user-principal: principal, new-user-name: (string-ascii 24)} {
        new-user-principal: tx-sender,
        new-user-name: ""
})

;;;;;;;;;;;;;;;;;;
;;Read functions;;
;;;;;;;;;;;;;;;;;;

;; get community billboard
(define-read-only (get-billboard) 
    (var-get billboard)
)
(define-read-only (get-next-user) 
    (var-get next-user)
)

;;;;;;;;;;;;;;;;;;; 
;;write functions;;
;;;;;;;;;;;;;;;;;;;

;; update billboard
;; @desc - Function used by next user to update billboard
;; @params - new-users-name: (string-ascii-24)

(define-public (update-billboard (updated-user-name (string-ascii 24)))
    (begin 

        ;; assert that tx-sender is next user (approved by admin)
        (asserts! (is-eq tx-sender (var-get next-user)) (err u10))

        ;; assert that updated username is NOT empty
        (asserts! (not (is-eq "" updated-user-name)) (err u12))

        ;; var set billboard with new keys
        (ok (var-set billboard 
                {
                    new-user-principal: tx-sender,
                    new-user-name: updated-user-name
                }
            )
        )
        
    )
)

;; Admin set new-user
;; @desc - function used by admin to set / give permission to next-user
;; @params - updated-user-principle: principle  

(define-public (admin-set-new-user (updated-user-principal principal)) 
    (begin 

        ;; assert that tx-sender is admin
        (asserts! (is-eq tx-sender admin ) (err u11))
        
        ;; assert that updated-user-principal is NOT admin
        (asserts! (not (is-eq tx-sender updated-user-principal)) (err u103))

        ;; assert that updated-user-principal is NOT current next-user
        (asserts! (not (is-eq updated-user-principal (var-get next-user))) (err u104))
        ;; var-set next-user with updated-user-principal
        (ok (var-set next-user updated-user-principal))
    )
)