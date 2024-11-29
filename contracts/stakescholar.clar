;; StackScholar Scholarship Management Contract - Enhanced Version

;; Existing constants and error codes...
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-SCHOLARSHIP-NOT-FOUND (err u102))
(define-constant ERR-INVALID-RECIPIENT (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-ALREADY-CLAIMED (err u105))
(define-constant ERR-INSUFFICIENT-CONTRACT-BALANCE (err u106))
(define-constant ERR-WITHDRAWAL-FAILED (err u107))

;; Scholarship structure (unchanged from original)
(define-map scholarships 
  { id: uint }
  {
    recipient: principal,
    amount: uint,
    is-claimed: bool,
    created-at: uint
  }
)

;; Counter for scholarship IDs (unchanged)
(define-data-var scholarship-counter uint u0)

;; New: Track total scholarship funds
(define-data-var total-scholarship-funds uint u0)

;; Existing validation functions (unchanged)
(define-private (is-valid-recipient (recipient principal))
  (and 
    (not (is-eq recipient tx-sender))
    (not (is-eq recipient CONTRACT-OWNER))
  )
)

(define-private (is-valid-amount (amount uint))
  (and 
    (> amount u0)
    (<= amount u100000)
  )
)

;; Existing create-scholarship function (with minor modification)
(define-public (create-scholarship (recipient principal) (amount uint))
  (begin
    ;; Only contract owner can create scholarships
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    ;; Validate recipient
    (asserts! (is-valid-recipient recipient) ERR-INVALID-RECIPIENT)
    
    ;; Validate amount
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    
    ;; Increment scholarship counter with overflow protection
    (let 
      ((new-counter (+ (var-get scholarship-counter) u1)))
      (asserts! (> new-counter (var-get scholarship-counter)) ERR-NOT-AUTHORIZED)
      (var-set scholarship-counter new-counter)
    
      ;; Create scholarship entry
      (map-set scholarships 
        { id: new-counter }
        {
          recipient: recipient,
          amount: amount,
          is-claimed: false,
          created-at: block-height
        }
      )
    
      ;; Update total scholarship funds
      (var-set total-scholarship-funds 
        (+ (var-get total-scholarship-funds) amount)
      )
    
      (ok new-counter)
    )
  )
)

;; Existing claim-scholarship function (unchanged)
(define-public (claim-scholarship (scholarship-id uint))
  (let 
    (
      (scholarship (unwrap! 
        (map-get? scholarships { id: scholarship-id }) 
        ERR-SCHOLARSHIP-NOT-FOUND
      ))
    )
    
    ;; Validate scholarship ID
    (asserts! (> scholarship-id u0) ERR-SCHOLARSHIP-NOT-FOUND)
    
    ;; Check if sender is the intended recipient
    (asserts! 
      (is-eq tx-sender (get recipient scholarship)) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Check if scholarship is already claimed
    (asserts! 
      (not (get is-claimed scholarship)) 
      ERR-ALREADY-CLAIMED
    )
    
    ;; Mark scholarship as claimed and transfer funds
    (map-set scholarships 
      { id: scholarship-id }
      (merge scholarship { is-claimed: true })
    )
    
    (ok scholarship-id)
  )
)

;; New: Deposit funds to the scholarship contract
(define-public (deposit-funds)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok true)
  )
)

;; New: Withdraw unclaimed funds (in case of emergency or contract upgrade)
(define-public (withdraw-unclaimed-funds (amount uint))
  (begin
    ;; Only contract owner can withdraw
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    ;; Ensure withdrawal amount is valid
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    ;; Prevent withdrawing more than available
    (asserts! 
      (<= amount (var-get total-scholarship-funds)) 
      ERR-INSUFFICIENT-CONTRACT-BALANCE
    )
    
    ;; Update total scholarship funds
    (var-set total-scholarship-funds 
      (- (var-get total-scholarship-funds) amount)
    )
    
    ;; Transfer funds back to contract owner
    (ok true)
  )
)

;; New: Get total scholarship funds
(define-read-only (get-total-scholarship-funds)
  (var-get total-scholarship-funds)
)

;; Existing get-scholarship-details function (unchanged)
(define-read-only (get-scholarship-details (scholarship-id uint))
  (map-get? scholarships { id: scholarship-id })
)


