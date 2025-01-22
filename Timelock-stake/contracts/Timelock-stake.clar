;; Time-Based Staking Contract
;; Rewards increase based on how long tokens are staked

;; Constants
(define-constant contract-owner tx-sender)
(define-constant min-stake-amount u1000)
(define-constant reward-rate u5) ;; 0.5% base rate
(define-constant time-multiplier u10) ;; 1% extra per month locked
(define-constant max-lock-periods u12) ;; Maximum 12 months

;; Error codes
(define-constant err-owner-only (err u1))
(define-constant err-insufficient-amount (err u2))
(define-constant err-no-stake-found (err u3))
(define-constant err-stake-still-locked (err u4))
(define-constant err-invalid-period (err u5))

;; Stake structure
(define-map stakes
    principal
    {
        amount: uint,
        start-block: uint,
        lock-periods: uint,
        claimed: bool
    }
)

;; Track total staked amount
(define-data-var total-staked uint u0)

;; Read-only functions
(define-read-only (get-stake (staker principal))
    (map-get? stakes staker)
)

(define-read-only (get-total-staked)
    (var-get total-staked)
)

;; Calculate rewards based on time staked
(define-read-only (calculate-rewards (stake-amount uint) (periods uint))
    (let
        (
            (base-reward (* stake-amount (/ reward-rate u1000)))
            (time-bonus (* stake-amount (/ (* periods time-multiplier) u1000)))
        )
        (+ base-reward time-bonus)
    )
)

;; Check if stake is mature
(define-read-only (is-stake-mature (staker principal))
    (let
        (
            (stake (unwrap! (get-stake staker) false))
            (lock-end-block (+ (get start-block stake) 
                (* (get lock-periods stake) u144))) ;; ~144 blocks per day
        )
        (<= lock-end-block block-height)
    )
)

;; Stake tokens
(define-public (stake-tokens (amount uint) (lock-periods uint))
    (begin
        ;; Basic checks
        (asserts! (>= amount min-stake-amount) err-insufficient-amount)
        (asserts! (<= lock-periods max-lock-periods) err-invalid-period)
        
        ;; Transfer tokens to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Record stake
        (map-set stakes
            tx-sender
            {
                amount: amount,
                start-block: block-height,
                lock-periods: lock-periods,
                claimed: false
            }
        )
        
        ;; Update total staked
        (var-set total-staked (+ (var-get total-staked) amount))
        
        (ok true)
    )
)

;; Claim rewards and unstake
(define-public (claim-stake)
    (let
        (
            (stake (unwrap! (get-stake tx-sender) err-no-stake-found))
            (amount (get amount stake))
            (periods (get lock-periods stake))
        )
        ;; Check if stake is mature
        (asserts! (is-stake-mature tx-sender) err-stake-still-locked)
        ;; Check if not already claimed
        (asserts! (not (get claimed stake)) err-no-stake-found)
        
        ;; Calculate rewards
        (let
            (
                (reward-amount (calculate-rewards amount periods))
                (total-return (+ amount reward-amount))
            )
            ;; Transfer original stake + rewards
            (try! (as-contract (stx-transfer? total-return tx-sender tx-sender)))
            
            ;; Update stake to claimed
            (map-set stakes
                tx-sender
                (merge stake { claimed: true })
            )
            
            ;; Update total staked
            (var-set total-staked (- (var-get total-staked) amount))
            
            (ok total-return)
        )
    )
)

;; Early unstake (forfeit rewards)
(define-public (emergency-unstake)
    (let
        (
            (stake (unwrap! (get-stake tx-sender) err-no-stake-found))
            (amount (get amount stake))
        )
        ;; Check if not already claimed
        (asserts! (not (get claimed stake)) err-no-stake-found)
        
        ;; Return only original stake amount
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        
        ;; Update stake to claimed
        (map-set stakes
            tx-sender
            (merge stake { claimed: true })
        )
        
        ;; Update total staked
        (var-set total-staked (- (var-get total-staked) amount))
        
        (ok amount)
    )
)
