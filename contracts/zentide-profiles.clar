;; ZenTide User Profiles Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))

;; Data structures
(define-map user-profiles
  principal
  {
    name: (string-utf8 64),
    join-date: uint,
    meditation-minutes: uint,
    yoga-sessions: uint,
    streak-days: uint
  }
)

;; Public functions
(define-public (create-profile (name (string-utf8 64)))
  (begin
    (asserts! (is-none (get-profile tx-sender)) (err u100))
    (ok (map-set user-profiles tx-sender {
      name: name,
      join-date: block-height,
      meditation-minutes: u0,
      yoga-sessions: u0,
      streak-days: u0
    }))
  )
)

(define-public (log-activity (activity-type (string-utf8 10)) (duration uint))
  (let (
    (current-profile (unwrap! (get-profile tx-sender) err-not-found))
  )
    (match activity-type
      "meditation" (ok (map-set user-profiles tx-sender
        (merge current-profile { meditation-minutes: (+ duration (get meditation-minutes current-profile)) })))
      "yoga" (ok (map-set user-profiles tx-sender
        (merge current-profile { yoga-sessions: (+ u1 (get yoga-sessions current-profile)) })))
      (err u404)
    )
  )
)

;; Read only functions
(define-read-only (get-profile (user principal))
  (map-get? user-profiles user)
)
