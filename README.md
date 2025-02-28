# Stacks Treasury DAO

Stacks Treasury DAO is a decentralized treasury management smart contract built on the Stacks blockchain using Clarity. It allows users to stake STX, propose fund allocations, vote on proposals, and execute approved funding requests in a transparent and decentralized manner.

## Features

- **Stake STX**: Users can deposit STX into the treasury.
- **Withdraw STX**: Users can withdraw their staked STX.
- **Create Proposals**: Users can propose treasury fund allocations.
- **Vote on Proposals**: Users vote on proposals to approve or reject funding requests.
- **Execute Proposals**: Approved proposals are executed, transferring STX to the proposal creator.
- **Read-Only Functions**: Retrieve user stakes, total treasury balance, and proposal details.

## Smart Contract Overview

### Constants & State Variables
- `ADMIN`: Contract admin for setup.
- `total-staked`: Total STX deposited in the treasury.
- `treasury-balance`: Available STX in the treasury.
- `proposal-counter`: Tracks the number of proposals.
- `user-stakes`: A map storing users' stake amounts.
- `proposals`: A map storing proposal details.

### Public Functions

#### Staking & Withdrawal
- `stake(amount)`: Stake STX into the treasury.
- `withdraw(amount)`: Withdraw STX from the treasury.

#### Proposal Management
- `create-proposal(amount)`: Create a funding proposal.
- `vote(proposal-id, approve)`: Vote for or against a proposal.
- `execute-proposal(proposal-id)`: Execute an approved proposal.

### Read-Only Functions
- `get-user-stake(user)`: Get the STX stake of a user.
- `get-total-staked()`: Retrieve the total staked STX.
- `get-treasury-balance()`: Get the treasury's STX balance.
- `get-proposal(proposal-id)`: Fetch details of a proposal.

## Setup & Deployment

### Prerequisites
- Install [Clarinet](https://github.com/hirosystems/clarinet) for local development.
- Ensure you have a Stacks wallet for testing.

### Deploying the Contract
```sh
clarinet check  # Verify the contract
clarinet test   # Run tests
clarinet deploy --network testnet  # Deploy to Stacks testnet
```

## Usage

### Staking STX
```clar
(contract-call? .stacks-treasury-dao stake u1000)
```

### Creating a Proposal
```clar
(contract-call? .stacks-treasury-dao create-proposal u500)
```

### Voting on a Proposal
```clar
(contract-call? .stacks-treasury-dao vote u1 true)  ; Vote Yes
(contract-call? .stacks-treasury-dao vote u1 false) ; Vote No
```

### Executing a Proposal
```clar
(contract-call? .stacks-treasury-dao execute-proposal u1)
```

## Security Considerations
- Proposals can only be executed if they receive majority approval.
- Treasury funds cannot be withdrawn directly by users, ensuring decentralization.
- The contract undergoes validation using Clarinet before deployment.

## License
This project is licensed under the MIT License.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue to discuss improvements.

