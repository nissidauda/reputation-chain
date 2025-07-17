;; ReputationChain - On-chain Trust Scoring

;; Contract owner
(define-constant contract-owner tx-sender)

(define-map reputation
  { user: principal }
  { score: int })

(define-map moderators
  { mod: principal }
  { approved: bool })

(define-public (add-moderator (new-mod principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (map-set moderators { mod: new-mod } { approved: true })
    (ok "Moderator added")
  ))

;; Moderator updates a user's reputation
(define-public (update-reputation (user principal) (delta int))
  (begin
    (asserts! (is-some (map-get? moderators { mod: tx-sender })) (err u101))
    (let ((current (default-to { score: 0 } (map-get? reputation { user: user }))))
      (map-set reputation { user: user }
        { score: (+ (get score current) delta) })
      (ok { user: user, new-score: (+ (get score current) delta) })
    )))

;; Read-only: Get a user's score
(define-read-only (get-score (user principal))
  (ok (get score (default-to { score: 0 } (map-get? reputation { user: user })))))
