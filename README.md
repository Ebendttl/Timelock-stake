# ⏳ TimeLockStake: Dynamic Time-Based Staking Protocol

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Clarity: 2.0](https://img.shields.io/badge/Clarity-2.0-blue)](https://clarity-lang.org/)
[![Network: Stacks](https://img.shields.io/badge/Network-Stacks-purple)](https://www.stacks.co/)
[![Type: Staking](https://img.shields.io/badge/Type-Staking-green)]()

A sophisticated staking protocol that implements dynamic reward mechanisms based on time-locked deposits. TimeLockStake incentivizes long-term holding through a unique multiplier system that increases rewards based on lock duration.

## 🎯 Core Features

- **Dynamic Reward System**: Base rate of 0.5% with additional 1% per month locked
- **Flexible Lock Periods**: Choose lock periods up to 12 months
- **Emergency Exit**: Built-in emergency withdrawal mechanism
- **Transparent Rewards**: Clear, deterministic reward calculations
- **Security-First Design**: Comprehensive checks and balances

## 📊 Technical Specifications

### Constants
```clarity
min-stake-amount: u1000
reward-rate: u5 (0.5%)
time-multiplier: u10 (1% per period)
max-lock-periods: u12 (12 months)
```

### Reward Structure
- **Base Rate**: 0.5% of staked amount
- **Time Multiplier**: 1% additional reward per month locked
- **Maximum Reward**: Up to 12.5% for 12-month lock
- **Block Duration**: ~144 blocks per day (used for lock period calculations)

## 🛠 Function Reference

### Core Staking Functions

#### `stake-tokens`
```clarity
(define-public (stake-tokens (amount uint) (lock-periods uint)))
```
Stakes tokens for specified period.
- **Parameters**:
  - `amount`: Amount to stake (minimum 1000)
  - `lock-periods`: Number of months to lock (1-12)
- **Returns**: (ok true) on success

#### `claim-stake`
```clarity
(define-public (claim-stake))
```
Claims mature stake with rewards.
- **Returns**: (ok uint) with total amount (original + rewards)
- **Requires**: Lock period completion

#### `emergency-unstake`
```clarity
(define-public (emergency-unstake))
```
Withdraws stake before maturity (forfeits rewards).
- **Returns**: (ok uint) with original stake amount

### Read-Only Functions

#### `calculate-rewards`
```clarity
(define-read-only (calculate-rewards (stake-amount uint) (periods uint)))
```
Calculates potential rewards.
- **Parameters**:
  - `stake-amount`: Amount staked
  - `periods`: Lock duration
- **Returns**: Total reward amount

## 📊 Reward Calculation Example

```
Stake Amount: 10,000 STX
Lock Period: 6 months

Base Reward = 10,000 * 0.5% = 50 STX
Time Bonus = 10,000 * (6 * 1%) = 600 STX
Total Reward = 650 STX
```

## 🔒 Security Features

1. **Minimum Stake Protection**
   - Enforces minimum stake amount
   - Prevents dust attacks

2. **Lock Period Validation**
   - Maximum 12-month lock
   - Block-based maturity checking

3. **Double-Claim Prevention**
   - Tracks claimed status
   - Prevents multiple reward claims

4. **Emergency Mechanisms**
   - Emergency unstake option
   - No lock-in during critical issues

## 🚀 Getting Started

### Prerequisites
- Stacks wallet
- Minimum 1,000 STX for staking
- Basic understanding of Stacks blockchain

### Staking Steps
1. **Prepare Stake**
   ```clarity
   (contract-call? .time-staking stake-tokens u10000 u6)
   ```

2. **Monitor Stake**
   ```clarity
   (contract-call? .time-staking get-stake tx-sender)
   ```

3. **Claim Rewards**
   ```clarity
   (contract-call? .time-staking claim-stake)
   ```

## 📈 Risk Management

### Staker Risks
- Lock period commitment
- Price fluctuation during lock
- Smart contract risk

### Mitigations
- Emergency unstake option
- Transparent reward calculation
- Audited contract code

## 🧪 Testing

```bash
# Run test suite
clarity-cli test time-staking_test.clar

# Test coverage
- Staking mechanics
- Reward calculations
- Lock period validation
- Emergency procedures
```

## 🔍 Audit Status

- Smart Contract Audit: Pending
- Security Review: Completed
- Economic Model Review: Completed

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Submit pull request

## ⚡ Performance Considerations

- Efficient reward calculation
- Optimized storage usage
- Gas-efficient operations
- Scalable design

## 📞 Support

For support, please:
1. Check existing GitHub issues
2. Create new issue with details

---

Built with ❤️ for the Stacks ecosystem
