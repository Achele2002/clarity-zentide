;; ZenTide Rewards Token Contract

;; Implement SIP-010 trait
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Define the fungible token
(define-fungible-token zen-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u401))
(define-constant meditation-reward u10)
(define-constant yoga-reward u20)
(define-constant token-uri u"https://zentide.xyz/token-metadata.json")
(define-constant token-name "ZenToken")
(define-constant token-symbol "ZEN")
(define-constant token-decimals u6)

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

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (ft-transfer? zen-token amount sender recipient)
  )
)

;; SIP-010 required functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance zen-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply zen-token))
)

(define-read-only (get-token-uri)
  (ok (some token-uri))
)
