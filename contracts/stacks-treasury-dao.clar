(define-trait proposal-trait
  (
    (execute () (response bool uint))
  )
)

;; -------------------------------
;; Constants & State Variables
;; -------------------------------

(define-constant ADMIN tx-sender) ;; Contract admin (for setup)
(define-data-var total-staked uint u0) ;; Total STX in treasury
(define-data-var treasury-balance uint u0) ;; Treasury balance
(define-data-var proposal-counter uint u0) ;; Count of proposals

(define-map user-stakes { user: principal } uint) ;; User stakes
(define-map proposals { id: uint } 
  (tuple (creator principal) (amount uint) (yes-votes uint) (no-votes uint) (executed bool))) ;; Proposal storage

;; -------------------------------
;; Stake STX into Treasury
;; -------------------------------

(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) (err u100)) ;; Ensure positive stake amount
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success
        (let ((current-stake (default-to u0 (map-get? user-stakes { user: tx-sender }))))
          (map-set user-stakes { user: tx-sender } (+ current-stake amount))
          (var-set total-staked (+ (var-get total-staked) amount))
          (var-set treasury-balance (+ (var-get treasury-balance) amount))
          (ok true))
      error (err u101) ;; Transfer failed
    )
  )
)

;; -------------------------------
;; Withdraw STX from Treasury
;; -------------------------------

(define-public (withdraw (amount uint))
  (let ((current-stake (default-to u0 (map-get? user-stakes { user: tx-sender }))))
    (begin
      (asserts! (>= current-stake amount) (err u102)) ;; Ensure sufficient balance
      (match (stx-transfer? amount (as-contract tx-sender) tx-sender)
        success
          (begin
            (map-set user-stakes { user: tx-sender } (- current-stake amount))
            (var-set total-staked (- (var-get total-staked) amount))
            (var-set treasury-balance (- (var-get treasury-balance) amount))
            (ok true))
        error (err u101) ;; Transfer failed
      )
    )
  )
)

;; -------------------------------
;; Create Funding Proposal
;; -------------------------------

(define-public (create-proposal (amount uint))
  (begin
    (asserts! (> amount u0) (err u103)) ;; Proposal amount must be > 0
    (asserts! (<= amount (var-get treasury-balance)) (err u104)) ;; Check treasury funds
    (let ((proposal-id (+ (var-get proposal-counter) u1)))
      (var-set proposal-counter proposal-id)
      (map-set proposals { id: proposal-id }
        { creator: tx-sender, amount: amount, yes-votes: u0, no-votes: u0, executed: false })
      (ok proposal-id)
    )
  )
)

;; -------------------------------
;; Vote on Proposals
;; -------------------------------

(define-public (vote (proposal-id uint) (approve bool))
  (match (map-get? proposals { id: proposal-id })
    prop
      (begin
        (asserts! (not (get executed prop)) (err u105)) ;; Ensure proposal isn't executed
        (map-set proposals { id: proposal-id }
          (merge prop { 
            yes-votes: (if approve (+ (get yes-votes prop) u1) (get yes-votes prop)),
            no-votes: (if (not approve) (+ (get no-votes prop) u1) (get no-votes prop))
          }))
        (ok true))
    (err u106) ;; Proposal not found
  )
)

;; -------------------------------
;; Execute Proposal (Fund a Project)
;; -------------------------------

(define-public (execute-proposal (proposal-id uint))
  (match (map-get? proposals { id: proposal-id })
    prop
      (begin
        (asserts! (not (get executed prop)) (err u109)) ;; Ensure not already executed
        (asserts! (>= (get yes-votes prop) (get no-votes prop)) (err u107)) ;; Ensure majority approval
        (asserts! (<= (get amount prop) (var-get treasury-balance)) (err u108)) ;; Check treasury funds
        (match (stx-transfer? (get amount prop) (as-contract tx-sender) (get creator prop))
          success
            (begin
              (map-set proposals { id: proposal-id } (merge prop { executed: true }))
              (var-set treasury-balance (- (var-get treasury-balance) (get amount prop)))
              (ok true))
          error (err u101) ;; Transfer failed
        ))
    (err u106) ;; Proposal not found
  )
)

;; -------------------------------
;; Implement Trait Function
;; -------------------------------

(define-public (execute)
  (ok (var-get proposal-counter))
)

;; -------------------------------
;; Read-Only Functions
;; -------------------------------

(define-read-only (get-user-stake (user principal))
  (ok (default-to u0 (map-get? user-stakes { user: user })))
)

(define-read-only (get-total-staked)
  (ok (var-get total-staked))
)

(define-read-only (get-treasury-balance)
  (ok (var-get treasury-balance))
)

(define-read-only (get-proposal (proposal-id uint))
  (ok (map-get? proposals { id: proposal-id }))
)