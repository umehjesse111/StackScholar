;; StackScholar Scholarship Management Contract
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-SCHOLARSHIP-NOT-FOUND (err u102))

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

;; Create a new scholarship
(define-public (create-scholarship (recipient principal) (amount uint))
  (begin
    ;; Only contract owner can create scholarships
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    ;; Increment scholarship counter
    (var-set scholarship-counter (+ (var-get scholarship-counter) u1))
    
    ;; Create scholarship entry
    (map-set scholarships 
      { id: (var-get scholarship-counter) }
      {
        recipient: recipient,
        amount: amount,
        is-claimed: false,
        created-at: block-height
      }
    )
    
    (ok (var-get scholarship-counter))
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
    
    ;; Check if sender is the intended recipient
    (asserts! 
      (is-eq tx-sender (get recipient scholarship)) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Check if scholarship is already claimed
    (asserts! 
      (not (get is-claimed scholarship)) 
      (err u103)
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