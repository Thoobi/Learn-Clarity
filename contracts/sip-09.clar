;; SIP-09
;; Implementing SIP-09 locally so we can workwith NFTS correctly
;; written by Daniel /stratalab
;; Day 51

(define-trait nft-trait
  (
    ;; Last Token ID
    (get-last-token-id () (response uint uint))
    ;; URI metadata
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
    ;; Get token owner
    (get-owner (uint) (response (optional principal) uint))
    ;; Transfer
    (transfer (uint principal principal) (response bool uint))
  )
)