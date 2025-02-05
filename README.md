# ERC1155Yul

**Overview**

ERC1155Yul is a Yul implementation of the ERC-1155 multi-token standard, which supports the management of multiple token types within a single contract. This implementation aims to provide a more gas-efficient interaction compared to traditional Solidity implementations by leveraging the lower-level capabilities of Yul.

**Features**

- Supports multiple token types (fungible, non-fungible, or a combination).
- Batch transfers for reduced gas costs.
- Atomic swaps and batched balance queries.

**Technology**

This project is implemented in Yul, an intermediate language for Ethereum. Yul allows direct manipulation of the EVM and is designed to enable efficient compilation and precise control over the execution environment.

**Getting Started**

**Prerequisites**

- Node.js and npm
- Foundry (for local deployment and testing)

**Installation**

1. Install Foundry if it's not already installed:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository:

   ```bash
   git clone https://github.com/jocoders/erc1155-yul.git
   cd erc1155-yul
   ```

3. Install dependencies:

   ```bash
   forge install
   ```

**Testing**

Run tests using Foundry:

```bash
forge test
```

**Usage**

**Deploying the Token**

Deploy the token to a local blockchain using Foundry:

```bash
forge create ERC1155Yul --rpc-url http://localhost:8545
```

**Interacting with the Token**

To transfer a single token type:

```solidity
safeTransferFrom(from, to, id, value, data)
```

To transfer multiple token types in a batch:

```solidity
safeBatchTransferFrom(from, to, ids, values, data)
```

To check the balance of a single token type for a specific owner:

```solidity
balanceOf(owner, id)
```

To check the balances of multiple token types for multiple owners:

```solidity
balanceOfBatch(owners, ids)
```

**Contributing**

Contributions are welcome! Please fork the repository and open a pull request with your features or fixes.

**License**

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/jocoders/ERC1155Yul/LICENSE.md) file for details.
