# POAP Attendance System

A decentralized attendance system using Soulbound NFTs (POAPs) built on Scroll Sepolia L2 network.

## Features

- **Soulbound NFTs**: Non-transferable attendance badges
- **Role-Based Badges**: Assign different roles to attendees
- **Expiry Support**: Optional expiry dates for badges
- **Metadata Storage**: Store event details and roles on-chain
- **Student Validation**: Only validated students can receive badges

## Smart Contract

The `POAPAttendance.sol` contract implements:
- ERC721 standard with URI storage
- Soulbound functionality (non-transferable)
- Role-based badge system
- Expiry mechanism
- Student validation system

## Prerequisites

- Node.js (v16+)
- npm or yarn
- MetaMask wallet with Scroll Sepolia network configured
- Private key for deployment

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd poap-attendance-hardhat
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory:
```
SEPOLIA_SCROLL_RPC_URL=https://sepolia-rpc.scroll.io
PRIVATE_KEY=your_private_key_here
OWNER_ADDRESS=your_owner_address_here
```

## Deployment

1. Compile the contract:
```bash
npx hardhat compile
```

2. Deploy to Scroll Sepolia:
```bash
npx hardhat run scripts/deploy.js --network sepoliaScroll
```

3. Verify the contract (optional):
```bash
npx hardhat verify --network sepoliaScroll <deployed_contract_address> <owner_address>
```

## Contract Functions

### For Contract Owner
- `validateStudent(address student)`: Validates a student for badge minting
- `revokeStudent(address student)`: Revokes student validation
- `mintBadge(address student, string tokenURI, string eventTitle, string role, uint256 expiryTime)`: Mints a new badge
- `transferOwnershipTo(address newOwner)`: Transfers contract ownership

### For Everyone
- `getBadgeRole(uint256 tokenId)`: Returns badge role
- `getEventTitle(uint256 tokenId)`: Returns event title
- `isBadgeValid(uint256 tokenId)`: Checks if badge is still valid
- `getBadgeMetadata(uint256 tokenId)`: Returns complete badge metadata

## Integration

### Backend Integration
1. Use the contract ABI and address in your backend
2. Implement endpoints for:
   - Minting badges (lecturer only)
   - Validating students (admin only)
   - Fetching badge metadata

### Frontend Integration
1. Connect to the contract using ethers.js or web3.js
2. Implement:
   - Badge minting interface for lecturers
   - Badge viewing interface for students
   - Student validation interface for admins

## Security Considerations

- Private keys should never be committed to the repository
- Use environment variables for sensitive data
- Implement proper access control in your backend
- Validate all inputs before interacting with the contract

## License

MIT

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
