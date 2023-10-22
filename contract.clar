(define-map deposits 
  { 
    depositor: principal
  } {
    balance: uint,
    deposit-block-height: uint
  })

(define-public (deposit (amount uint))  
  (begin    
    (let ((current-balance (default-to u0 (get balance (map-get? deposits { depositor: tx-sender })))))      
      (map-set deposits { depositor: tx-sender } 
        { balance: (+ amount current-balance), 
          deposit-block-height: block-height } )          
      (stx-transfer? amount tx-sender 'STCONTRACT_ADDRESS))))

(define-read-only (can-withdraw? (depositor principal) (amount uint))
  (let (
      (balance-info (unwrap!
        (map-get? deposits { depositor: depositor})
        (err "No funds deposited."))))
    (if (and 
        (>= (get balance balance-info) amount)
        (>= (- block-height (get deposit-block-height balance-info)) u100))
      (ok true)
      (err "Insufficient funds or not enough blocks have passed since deposit."))))

(define-public (withdraw (amount uint))  
  (begin    
    (let ((can-withdraw (unwrap-panic (can-withdraw? tx-sender amount))))      
      (if can-withdraw          
        (begin
          (let ((current-balance (unwrap-panic (get balance (map-get? deposits { depositor: tx-sender })))))          
            (map-set deposits { depositor: tx-sender } 
              { balance: (- current-balance amount), 
                deposit-block-height: block-height }))
          (stx-transfer? amount 'STCONTRACT_ADDRESS tx-sender))
        (err "Insufficient funds or not enough blocks have passed since deposit.")))))
