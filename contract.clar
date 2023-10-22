(define-map deposits 
  { depositor: principal } 
  { balance: uint })

(define-public (deposit (amount uint))
  (begin
    (let ((current-balance (get balance (map-get? deposits { depositor: tx-sender }))))
      (if (null? current-balance)
          (map-set deposits { depositor: tx-sender } { balance: amount })
          (map-set deposits { depositor: tx-sender } { balance: (+ amount (unwrap-panic current-balance)) }))
      (stx-transfer? amount tx-sender 'STCONTRACT_ADDRESS))))

(define-public (withdraw (amount uint))
  (begin
    (let ((current-balance (unwrap! (get balance (map-get? deposits { depositor: tx-sender })) (err "No funds deposited."))))
      (if (>= current-balance  amount)
          (begin
            (map-set deposits { depositor: tx-sender } { balance: (- current-balance amount) })
            (stx-transfer? amount 'STCONTRACT_ADDRESS tx-sender))
          (err "Insufficient funds.")))))
