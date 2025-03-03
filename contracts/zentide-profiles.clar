;; ZenTide User Profiles Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-duplicate-profile (err u100))
(define-constant err-invalid-duration (err u102))
(define-constant err-empty-name (err u103))
(define-constant max-duration u180) ;; 3 hours max
(define-constant blocks-per-day u144) ;; ~24 hours in blocks
(define-constant streak-window u12) ;; ±2 hour window for streak

;; Data structures
(define-map user-profiles
  principal
  {
    name: (string-utf8 64),
    join-date: uint,
    meditation-minutes: uint,
    yoga-sessions: uint,
    streak-days: uint,
    last-activity: uint
  }
)

;; Public functions
(define-public (create-profile (name (string-utf8 64)))
  (begin
    (asserts! (not (is-eq (len name) u0)) err-empty-name)
    (asserts! (is-none (get-profile tx-sender)) err-duplicate-profile)
    (print { type: "profile-created", user: tx-sender })
    (ok (map-set user-profiles tx-sender {
      name: name,
      join-date: block-height,
      meditation-minutes: u0,
      yoga-sessions: u0,
      streak-days: u0,
      last-activity: block-height
    }))
  )
)

(define-public (log-activity (activity-type (string-utf8 10)) (duration uint))
  (let (
    (current-profile (unwrap! (get-profile tx-sender) err-not-found))
  )
    (asserts! (<= duration max-duration) err-invalid-duration)
    (print { type: "activity-logged", activity: activity-type, user: tx-sender })
    (match activity-type
      "meditation" (ok (map-set user-profiles tx-sender
        (merge current-profile { 
          meditation-minutes: (+ duration (get meditation-minutes current-profile)),
          last-activity: block-height,
          streak-days: (update-streak current-profile)
        })))
      "yoga" (ok (map-set user-profiles tx-sender
        (merge current-profile { 
          yoga-sessions: (+ u1 (get yoga-sessions current-profile)),
          last-activity: block-height,
          streak-days: (update-streak current-profile)
        })))
      (err u404)
    )
  )
)

;; Private functions
(define-private (update-streak (profile {name: (string-utf8 64), join-date: uint, meditation-minutes: uint, yoga-sessions: uint, streak-days: uint, last-activity: uint}))
  (if (is-consecutive-day (get last-activity profile))
    (+ u1 (get streak-days profile))
    u1
  )
)

(define-private (is-consecutive-day (last-activity uint))
  (let ((blocks-since-last (- block-height last-activity)))
    (and 
      (>= blocks-since-last (- blocks-per-day streak-window))
      (<= blocks-since-last (+ blocks-per-day streak-window))
    )
  )
)

;; Read only functions
(define-read-only (get-profile (user principal))
  (map-get? user-profiles user)
)
