;; clarity-basic-v
;; reviewing clarity contract
;; written by Daniel

;; Day 45 - Private-functions
(define-read-only (say-hello-read) 
  (say-hello-world)
)
(define-public (say-hello-public) 
  (ok (say-hello-world))
)
(define-private (say-hello-world) 
  "Hello world"
)

;; Day 46 - filter
(define-constant test-list (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))
(define-read-only (test-filter-remove-smaller-than-five)
  (filter filter-less-than-five test-list)
)

(define-read-only (test-even-numbers)
  (filter filter-even-numbers test-list)
)

(define-read-only (test-odd-numbers)
  (filter filter-odd-numbers test-list)
)

(define-private (filter-less-than-five (item uint)) 
  (< item u5)
)

(define-private (filter-odd-numbers (item uint)) 
  (is-eq (mod item u2) u0) 
)

(define-private (filter-even-numbers (item uint)) 
  (not (is-eq (mod item u2) u0))
)


;; Day 47 - Map
(define-constant test-list-string (list "alice" "bob" "grace" "carl"))

(define-read-only (test-map-increase-by-one) 
  (map add-by-one test-list)
)

(define-read-only (test-map-double) 
  (map double test-list)
)

(define-private (add-by-one (item uint)) 
  (+ item u1)
)

(define-private (double (item uint)) 
  (* item u2)
)

(define-read-only (test-map-names) 
  (map hello-name test-list-string)
)

(define-private (hello-name (item (string-ascii 24))) 
  u0
)

;; Day 48 - map revisited
(define-constant test-list-principals (list 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC))

(define-constant test-list-tuple (list {user: "Alice", balance: u10} {user: "Bob", balance: u12} {user: "Carl", balance: u15}))

(define-public (test-send-stx-multiple) 
  (ok (map send-stx-principals test-list-principals))
)

(define-read-only (test-get-user) 
  (map test-user test-list-tuple)
)

(define-read-only (test-get-balance) 
  (map test-balance test-list-tuple)
)

(define-private (send-stx-principals (item principal)) 
  (stx-transfer? u100000000 tx-sender item)
)

(define-private (test-user (item {user: (string-ascii 24), balance: uint})) 
  (get user item)
)

(define-private (test-balance (item {user: (string-ascii 24), balance: uint})) 
  (get balance item)
)


;; Day 49 - fold
(define-constant test-list-ones (list u1 u1 u1 u1 u1 u1))
(define-constant test-list-two (list u1 u2 u3 u4 u5 u6))
(define-constant test-alphabet (list "a" "n" "i" "e" "l"))
(define-read-only (fold-add-start-zero) 
  (fold + test-list-ones u0)
)
(define-read-only (fold-add-start-ten) 
  (fold + test-list-ones u10)
)
(define-read-only (fold-add-start-one) 
  (fold * test-list-two u1)
)
(define-read-only (fold-add-start-two) 
  (fold * test-list-two u2)
)

(define-read-only (fold-characters) 
  (fold concat-string test-alphabet "D")
)

(define-private (concat-string (a (string-ascii 10)) (b (string-ascii 10))) 
  (unwrap-panic (as-max-len? (concat b a) u10))
)

;; Day 50 - contract-call?
(define-read-only (call-basics-i-multiply) 
  (contract-call? .clarity-basics-i multiply)
)

(define-read-only (call-basics-i-hello-world) 
  (contract-call? .clarity-basics-i say-hello-world-name )
)

(define-public (call-basics-ii-hello-world (name (string-ascii 24))) 
  (contract-call? .clarity-basics-ii say-and-update-name name)
)

(define-public (call-basic-iii-set-second-map (new-username (string-ascii 24)) (new-balance uint)) 
  (begin 
    (try! (contract-call? .clarity-basics-ii say-and-update-name new-username))
    (contract-call? .clarity-basics-iii set-second-map new-username new-balance none)
  )
)

;; Day 52 - Native NFT functions
;; (impl-trait .sip-09.nft-trait)
(define-non-fungible-token nft-test uint)
(define-public (test-mint) 
    (nft-mint? nft-test u0 tx-sender)
)
(define-read-only (test-get-owner (id uint)) 
  (nft-get-owner? nft-test id)
)

(define-public (test-burn (id uint) (sender principal)) 
  (nft-burn? nft-test id sender)
)

(define-public (test-tranfer (new-owner principal) (id uint) (sender principal)) 
  (nft-transfer? nft-test id sender new-owner)
)

;; Day 53 - Basic Minting Logic
(define-non-fungible-token nft-test-2 uint)
(define-data-var nft-index uint u1)
(define-constant nft-limit u6)
(define-constant nft-fee u100000000)
(define-constant nft-admin tx-sender)

(define-public (limited-mint (metadata-url (string-ascii 256))) 
  (let 
    (
      ;; local var
      (current-index (var-get nft-index))
      (next-index (+ current-index u1))
    )
      ;; Assert that the current index is lower than nft limit
      (asserts! (< current-index nft-limit) (err "err-exceeded-mint-limit"))

      ;; charge 10stx before mint
      (unwrap! (stx-transfer? nft-fee tx-sender nft-admin) (err "err-transfer-failed"))

      ;; mint nft to tx-sender
      (unwrap! (nft-mint? nft-test-2 current-index tx-sender) (err "err-minting-nft"))

      ;; Update and store metadata url
      (map-set nft-metadata current-index metadata-url)

      ;; var-set nft-index by increasing it by one
      (ok (var-set nft-index next-index))
  )
)

;; Day 54 - Nft Metadata Logic
(define-constant static-url "https://example.com/")
(define-map nft-metadata uint (string-ascii 256))
(define-public (get-token-uri-test (id uint)) 
  (ok static-url)
)
(define-public (get-token-uri-2 (id uint)) 
  (ok (concat 
        static-url
        (concat (int-to-ascii (to-int id)) ".json")
      )
  )
)
(define-public (get-token-uri (id uint)) 
  (ok (map-get? nft-metadata id))
)
