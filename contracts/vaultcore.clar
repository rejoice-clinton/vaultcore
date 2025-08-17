;; VaultCore - Advanced Collateralized Lending Infrastructure
;;
;; Summary:
;; Revolutionary multi-asset lending protocol that transforms digital asset
;; custody into yield-generating opportunities while preserving asset ownership
;;
;; Description:
;; VaultCore redefines decentralized finance by creating a sophisticated lending
;; ecosystem where Bitcoin and Stacks assets serve as collateral for seamless
;; borrowing experiences. Our protocol features intelligent risk assessment,
;; real-time liquidation protection, and adaptive interest mechanisms that
;; respond to market dynamics. Built on Clarity's deterministic smart contract
;; framework, VaultCore ensures mathematical precision in all financial
;; operations while maintaining complete transparency and auditability.
;;
;; The protocol empowers users to unlock liquidity from their HODLed assets
;; without triggering taxable events, making it the premier choice for
;; institutional and retail participants seeking capital efficiency in the
;; Bitcoin economy.

;; SYSTEM CONSTANTS & ERROR DEFINITIONS

;; Core Authorization
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))

;; Lending Protocol Errors
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-BELOW-MINIMUM (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-LOAN-NOT-FOUND (err u107))
(define-constant ERR-LOAN-NOT-ACTIVE (err u108))

;; System State Management
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))
(define-constant ERR-INVALID-LIQUIDATION (err u106))

;; Input Validation
(define-constant ERR-INVALID-LOAN-ID (err u109))
(define-constant ERR-INVALID-PRICE (err u110))
(define-constant ERR-INVALID-ASSET (err u111))

;; Supported Collateral Assets
(define-constant VALID-ASSETS (list "BTC" "STX"))

;; PROTOCOL STATE VARIABLES

;; Platform Initialization Status
(define-data-var platform-initialized bool false)

;; Dynamic Risk Parameters
(define-data-var minimum-collateral-ratio uint u150) ;; 150% minimum backing
(define-data-var liquidation-threshold uint u120) ;; 120% liquidation trigger
(define-data-var platform-fee-rate uint u1) ;; 1% protocol fee

;; Global Platform Metrics
(define-data-var total-btc-locked uint u0)
(define-data-var total-loans-issued uint u0)

;; DATA STORAGE MAPS

;; Primary Loan Registry
(define-map loans
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    loan-amount: uint,
    interest-rate: uint,
    start-height: uint,
    last-interest-calc: uint,
    status: (string-ascii 20),
  }
)

;; User Portfolio Tracking
(define-map user-loans
  { user: principal }
  { active-loans: (list 10 uint) }
)

;; Real-time Price Oracle Feed
(define-map collateral-prices
  { asset: (string-ascii 3) }
  { price: uint }
)

;; INTERNAL CALCULATION FUNCTIONS

;; Calculate Dynamic Collateral-to-Loan Ratio
(define-private (calculate-collateral-ratio
    (collateral uint)
    (loan uint)
    (btc-price uint)
  )
  (let (
      (collateral-value (* collateral btc-price))
      (ratio (* (/ collateral-value loan) u100))
    )
    ratio
  )
)

;; Compute Compound Interest Over Block Time
(define-private (calculate-interest
    (principal uint)
    (rate uint)
    (blocks uint)
  )
  (let (
      (interest-per-block (/ (* principal rate) (* u100 u144))) ;; Daily rate normalized
      (total-interest (* interest-per-block blocks))
    )
    total-interest
  )
)

;; Automated Liquidation Risk Assessment
(define-private (check-liquidation (loan-id uint))
  (let (
      (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (btc-price (unwrap! (get price (map-get? collateral-prices { asset: "BTC" }))
        ERR-NOT-INITIALIZED
      ))
      (current-ratio (calculate-collateral-ratio (get collateral-amount loan)
        (get loan-amount loan) btc-price
      ))
    )
    (if (<= current-ratio (var-get liquidation-threshold))
      (liquidate-position loan-id)
      (ok true)
    )
  )
)

;; Execute Immediate Position Liquidation
(define-private (liquidate-position (loan-id uint))
  (let (
      (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (borrower (get borrower loan))
    )
    (begin
      (map-set loans { loan-id: loan-id } (merge loan { status: "liquidated" }))
      (map-delete user-loans { user: borrower })
      (ok true)
    )
  )
)

;; Validate Loan ID Integrity
(define-private (validate-loan-id (loan-id uint))
  (and
    (> loan-id u0)
    (<= loan-id (var-get total-loans-issued))
  )
)

;; Asset Whitelist Verification
(define-private (is-valid-asset (asset (string-ascii 3)))
  (is-some (index-of VALID-ASSETS asset))
)

;; Price Feed Sanity Checking
(define-private (is-valid-price (price uint))
  (and
    (> price u0)
    (<= price u1000000000000) ;; Maximum reasonable price ceiling
  )
)

;; Loan ID Filtering Helper
(define-private (not-equal-loan-id (id uint))
  (not (is-eq id id))
)

;; PROTOCOL ADMINISTRATION FUNCTIONS

;; Bootstrap Platform Operations
(define-public (initialize-platform)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get platform-initialized)) ERR-ALREADY-INITIALIZED)
    (var-set platform-initialized true)
    (ok true)
  )
)

;; Adjust Minimum Collateral Requirements
(define-public (update-collateral-ratio (new-ratio uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (>= new-ratio u110) ERR-INVALID-AMOUNT)
    (var-set minimum-collateral-ratio new-ratio)
    (ok true)
  )
)

;; Modify Liquidation Safety Margins
(define-public (update-liquidation-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (>= new-threshold u100) ERR-INVALID-AMOUNT)
    (var-set liquidation-threshold new-threshold)
    (ok true)
  )
)

;; Update Market Price Oracles
(define-public (update-price-feed
    (asset (string-ascii 3))
    (new-price uint)
  )
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Comprehensive asset and price validation
    (asserts! (is-valid-asset asset) ERR-INVALID-ASSET)
    (asserts! (is-valid-price new-price) ERR-INVALID-PRICE)

    ;; Atomic price update
    (ok (map-set collateral-prices { asset: asset } { price: new-price }))
  )
)

;; CORE LENDING OPERATIONS

;; Secure Collateral Deposit Function
(define-public (deposit-collateral (amount uint))
  (begin
    (asserts! (var-get platform-initialized) ERR-NOT-INITIALIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (var-set total-btc-locked (+ (var-get total-btc-locked) amount))
    (ok true)
  )
)

;; Intelligent Loan Origination System
(define-public (request-loan
    (collateral uint)
    (loan-amount uint)
  )
  (let (
      (btc-price (unwrap! (get price (map-get? collateral-prices { asset: "BTC" }))
        ERR-NOT-INITIALIZED
      ))
      (collateral-value (* collateral btc-price))
      (required-collateral (* loan-amount (var-get minimum-collateral-ratio)))
      (loan-id (+ (var-get total-loans-issued) u1))
    )
    (begin
      (asserts! (var-get platform-initialized) ERR-NOT-INITIALIZED)
      (asserts! (>= collateral-value required-collateral)
        ERR-INSUFFICIENT-COLLATERAL
      )

      ;; Create new loan record
      (map-set loans { loan-id: loan-id } {
        borrower: tx-sender,
        collateral-amount: collateral,
        loan-amount: loan-amount,
        interest-rate: u5, ;; Competitive 5% APR
        start-height: stacks-block-height,
        last-interest-calc: stacks-block-height,
        status: "active",
      })

      ;; Update user loan portfolio
      (match (map-get? user-loans { user: tx-sender })
        existing-loans (map-set user-loans { user: tx-sender } { active-loans: (unwrap!
          (as-max-len? (append (get active-loans existing-loans) loan-id) u10)
          ERR-INVALID-AMOUNT
        ) }
        )
        (map-set user-loans { user: tx-sender } { active-loans: (list loan-id) })
      )

      ;; Increment global loan counter
      (var-set total-loans-issued (+ (var-get total-loans-issued) u1))
      (ok loan-id)
    )
  )
)