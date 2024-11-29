;; StackScholar Scholarship Management Contract
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-SCHOLARSHIP-NOT-FOUND (err u102))
(define-constant ERR-INVALID-RECIPIENT (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-ALREADY-CLAIMED (err u105))

;; Scholarship structure
(define-map scholarships 
  { id: uint }
  {
    recipient: principal,
    amount: uint,
    is-claimed: bool,
    created-at: uint
  }
)

;; Counter for scholarship IDs
(define-data-var scholarship-counter uint u0)

;; Validate recipient address
(define-private (is-valid-recipient (recipient principal))
  (and 
    (not (is-eq recipient tx-sender))  ;; Prevent self-scholarship
    (not (is-eq recipient CONTRACT-OWNER))  ;; Prevent owner self-scholarship
  )
)

;; Validate scholarship amount
(define-private (is-valid-amount (amount uint))
  (and 
    (> amount u0)  ;; Amount must be positive
    (<= amount u100000)  ;; Set a reasonable upper limit
  )
)

;; Create a new scholarship
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
    
      (ok new-counter)
    )
  )
)

;; Claim a scholarship
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

;; Get scholarship details
(define-read-only (get-scholarship-details (scholarship-id uint))
  (map-get? scholarships { id: scholarship-id })
)