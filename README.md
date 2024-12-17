# StackScholar 🎓🌐

## Overview
StackScholar is a decentralized scholarship management platform built on the Stacks blockchain. It provides a transparent, secure way to create, manage, and distribute scholarships using blockchain technology.

## Features
- Scholarship Creation
- Transparent Scholarship Tracking
- Secure Scholarship Claims
- Immutable Scholarship Records

## Smart Contract Functions

### `create-scholarship`
- Creates a new scholarship
- Only callable by contract owner
- Parameters:
  - `recipient`: Wallet address of scholarship recipient
  - `amount`: Scholarship amount

### `claim-scholarship`
- Allows recipient to claim their scholarship
- Checks for valid recipient and unclaimed status
- Marks scholarship as claimed upon successful verification

### `get-scholarship-details`
- Read-only function to retrieve scholarship information

## Prerequisites
- Stacks Wallet
- Clarinet (Stacks development environment)
- Basic understanding of Clarity smart contracts

## Local Development
1. Install Clarinet
```bash
yarn global add @stacks/cli
# or
npm install -g @stacks/cli
```

2. Clone the repository
```bash
git clone https://github.com/yourusername/stackscholar.git
cd stackscholar
```

3. Test the contract
```bash
clarinet test
```

## Deployment
Deploy using Stacks Web Wallet or Hiro Wallet:
1. Connect wallet
2. Deploy contract
3. Initialize scholarship programs

## Security Considerations
- Only contract owner can create scholarships
- Recipients can only claim their designated scholarships
- Immutable record-keeping prevents tampering

## Future Roadmap
- Multi-signature scholarship creation
- Dynamic scholarship amount allocation
- Integration with educational institutions


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss proposed changes.

