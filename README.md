# VaultCore - Advanced Collateralized Lending Infrastructure

[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-blue)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange)](https://stacks.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

VaultCore is a revolutionary multi-asset lending protocol that transforms digital asset custody into yield-generating opportunities while preserving asset ownership. Built on the Stacks blockchain using Clarity smart contracts, VaultCore creates a sophisticated lending ecosystem where Bitcoin and Stacks assets serve as collateral for seamless borrowing experiences.

## Key Features

### 🔒 **Multi-Asset Collateral Support**

- Bitcoin (BTC) and Stacks (STX) as collateral assets
- Extensible architecture for additional asset support
- Real-time price oracle integration

### 📊 **Intelligent Risk Management**

- Dynamic collateral ratio calculations (150% minimum)
- Automated liquidation protection (120% threshold)
- Real-time risk assessment algorithms

### 💰 **Competitive Lending Terms**

- 5% APR interest rates
- No prepayment penalties
- Transparent fee structure (1% protocol fee)

### 🔐 **Security & Transparency**

- Deterministic Clarity smart contract framework
- Mathematical precision in all financial operations
- Complete transparency and auditability
- Non-custodial asset management

## Architecture

### Smart Contract Structure

```
VaultCore Contract
├── System Constants & Error Definitions
├── Protocol State Variables
├── Data Storage Maps
│   ├── loans (Primary Loan Registry)
│   ├── user-loans (User Portfolio Tracking)
│   └── collateral-prices (Price Oracle Feed)
├── Internal Calculation Functions
├── Protocol Administration Functions
├── Core Lending Operations
└── Public Read-Only Interface
```

### Core Components

#### 1. **Loan Management System**

- Secure loan origination with collateral validation
- Interest calculation using compound interest mechanics
- Automated loan lifecycle management

#### 2. **Risk Assessment Engine**

- Real-time collateral ratio monitoring
- Automated liquidation triggers
- Dynamic risk parameter adjustments

#### 3. **Price Oracle Integration**

- Multi-asset price feed management
- Price validation and sanity checking
- Administrative price update controls

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Node.js](https://nodejs.org/) (v14 or higher)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/rejoice-clinton/vaultcore.git
   cd vaultcore
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify installation**

   ```bash
   clarinet check
   ```

### Development Setup

1. **Initialize development environment**

   ```bash
   clarinet console
   ```

2. **Run contract checks**

   ```bash
   clarinet check
   ```

3. **Execute tests**

   ```bash
   npm test
   ```

## Usage

### Platform Initialization

Before using the lending protocol, the platform must be initialized:

```clarity
(contract-call? .vaultcore initialize-platform)
```

### Price Feed Updates

Update asset prices through the oracle system:

```clarity
(contract-call? .vaultcore update-price-feed "BTC" u50000000000) ;; $50,000 BTC price
(contract-call? .vaultcore update-price-feed "STX" u2000000) ;; $2.00 STX price
```

### Requesting a Loan

Users can request loans by providing collateral:

```clarity
(contract-call? .vaultcore request-loan u100000000 u30000000000) ;; 1 BTC collateral, $30,000 loan
```

### Loan Repayment

Repay loans with accrued interest:

```clarity
(contract-call? .vaultcore repay-loan u1 u31500000000) ;; Repay loan ID 1 with interest
```

### Querying Platform Data

#### Get Loan Details

```clarity
(contract-call? .vaultcore get-loan-details u1)
```

#### Check User Loans

```clarity
(contract-call? .vaultcore get-user-loans 'SP1234...)
```

#### Platform Statistics

```clarity
(contract-call? .vaultcore get-platform-stats)
```

## API Reference

### Public Functions

#### Administrative Functions

- `initialize-platform()` - Bootstrap platform operations
- `update-collateral-ratio(uint)` - Adjust minimum collateral requirements
- `update-liquidation-threshold(uint)` - Modify liquidation safety margins
- `update-price-feed(string-ascii, uint)` - Update market price oracles

#### Core Lending Operations

- `deposit-collateral(uint)` - Secure collateral deposit
- `request-loan(uint, uint)` - Intelligent loan origination
- `repay-loan(uint, uint)` - Complete loan settlement with interest

#### Read-Only Functions

- `get-loan-details(uint)` - Comprehensive loan information
- `get-user-loans(principal)` - User portfolio overview
- `get-platform-stats()` - Real-time platform analytics
- `get-valid-assets()` - Supported asset registry

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-NOT-AUTHORIZED | Unauthorized access attempt |
| u101 | ERR-INSUFFICIENT-COLLATERAL | Collateral below minimum requirements |
| u102 | ERR-BELOW-MINIMUM | Amount below minimum threshold |
| u103 | ERR-INVALID-AMOUNT | Invalid amount provided |
| u104 | ERR-ALREADY-INITIALIZED | Platform already initialized |
| u105 | ERR-NOT-INITIALIZED | Platform not yet initialized |
| u106 | ERR-INVALID-LIQUIDATION | Invalid liquidation attempt |
| u107 | ERR-LOAN-NOT-FOUND | Specified loan does not exist |
| u108 | ERR-LOAN-NOT-ACTIVE | Loan is not in active state |
| u109 | ERR-INVALID-LOAN-ID | Invalid loan identifier |
| u110 | ERR-INVALID-PRICE | Invalid price value |
| u111 | ERR-INVALID-ASSET | Unsupported asset type |

## Testing

### Running Tests

Execute the comprehensive test suite:

```bash
npm test
```

### Test Coverage

The test suite covers:

- ✅ Contract initialization and setup
- ✅ Loan origination and validation
- ✅ Interest calculation accuracy
- ✅ Liquidation mechanisms
- ✅ Price feed updates
- ✅ Error handling and edge cases
- ✅ Administrative functions
- ✅ Read-only function accuracy

### Test Structure

```
tests/
└── vaultcore.test.ts     # Comprehensive test suite
```

## Configuration

### Network Settings

The project includes configuration for multiple networks:

- **Devnet**: Local development environment
- **Testnet**: Stacks testnet deployment
- **Mainnet**: Production deployment

Configuration files:

```
settings/
├── Devnet.toml
├── Testnet.toml
└── Mainnet.toml
```

### Default Parameters

- **Minimum Collateral Ratio**: 150%
- **Liquidation Threshold**: 120%
- **Platform Fee Rate**: 1%
- **Interest Rate**: 5% APR
- **Maximum User Loans**: 10 concurrent loans

## Security Considerations

### Smart Contract Security

- ✅ Input validation on all public functions
- ✅ Authorization checks for administrative functions
- ✅ Overflow protection in mathematical operations
- ✅ Reentrancy protection through function design
- ✅ Comprehensive error handling

### Risk Management

- ✅ Automated liquidation mechanisms
- ✅ Real-time collateral ratio monitoring
- ✅ Price feed validation and sanity checks
- ✅ Multi-signature administrative controls (recommended)

## Deployment

### Testnet Deployment

1. **Configure network settings**

   ```bash
   clarinet settings get
   ```

2. **Deploy to testnet**

   ```bash
   clarinet deploy --testnet
   ```

### Mainnet Deployment

1. **Audit smart contracts** (recommended)
2. **Configure mainnet settings**
3. **Deploy with proper security measures**

   ```bash
   clarinet deploy --mainnet
   ```

## Contributing

We welcome contributions to VaultCore! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Maintain comprehensive test coverage
- Document all public functions
- Include appropriate error handling
- Optimize gas usage where possible

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

### Phase 1: Core Infrastructure ✅

- [x] Basic lending and borrowing functionality
- [x] Multi-asset collateral support
- [x] Price oracle integration
- [x] Automated liquidation system

### Phase 2: Enhanced Features 🚧

- [ ] Governance token integration
- [ ] Advanced risk modeling
- [ ] Cross-chain asset support
- [ ] Yield farming mechanisms

### Phase 3: Ecosystem Expansion 📋

- [ ] Mobile application interface
- [ ] Institutional trading tools
- [ ] Analytics dashboard
- [ ] Third-party integrations

## Acknowledgments

- **Stacks Foundation** for the robust blockchain infrastructure
- **Clarity Language** team for the secure smart contract framework
- **Community Contributors** for testing and feedback
- **Security Auditors** for ensuring protocol safety
