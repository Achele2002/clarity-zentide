;; ZenTide Rewards Token Contract

;; Define the fungible token
(define-fungible-token zen-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant meditation-reward u10)
(define-constant yoga-reward u20)

;; Public functions
(define-public (mint-rewards (recipient principal) (activity-type (string-utf8 10)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match activity-type
      "meditation" (ft-mint? zen-token meditation-reward recipient)
      "yoga" (ft-mint? zen-token yoga-reward recipient)
      (err u404)
    )
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? zen-token amount tx-sender recipient)
)

;; Read only functions
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance zen-token account))
)
