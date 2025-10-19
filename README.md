# 🐾 Animals NFT Collection## Foundry



A fully functional NFT collection featuring adorable baby animals that evolve into magnificent adults! Built with Foundry, deployed on Ethereum Sepolia, and featuring a beautiful mint website.**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**



## 🎯 Project OverviewFoundry consists of:



**SOLD OUT!** ✅ All 10 NFTs have been successfully minted!- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).

- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.

- **Contract Address**: `0x7cAca921010BC0dA27F0ca5a89FcCec0Ae4184A2`- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.

- **Network**: Ethereum Sepolia Testnet- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

- **Total Supply**: 10 NFTs (SOLD OUT)

- **Mint Price**: FREE (0.0 ETH)## Documentation

- **Max Per Wallet**: 2 NFTs

- **Upgrade System**: Baby → Adult (12-hour cooldown)https://book.getfoundry.sh/



## 🦄 Features## Usage



### Smart Contract Features### Build

- ✅ ERC721 compliant NFT contract

- ✅ Whitelist-based minting system```shell

- ✅ Time-limited mint window (48 hours)$ forge build

- ✅ Upgrade mechanism (baby to adult animals)```

- ✅ OpenZeppelin security standards

- ✅ Verified on Etherscan### Test



### Available Animals```shell

🐦 Bird | 🐱 Cat | 🐔 Chicken | 🐕 Dog | 🐐 Goat | 🐴 Horse | 🦁 Lion | 🐰 Rabbit | 🐅 Tiger | 🦓 Zebra$ forge test

```

### Mint Website

- ✅ MetaMask wallet integration### Format

- ✅ Real-time contract interaction

- ✅ IPFS image display```shell

- ✅ Upgrade functionality$ forge fmt

- ✅ Responsive design```

- ✅ Production-ready for Netlify

### Gas Snapshots

## 🚀 Technical Stack

```shell

- **Smart Contracts**: Solidity ^0.8.30$ forge snapshot

- **Framework**: Foundry```

- **Standards**: OpenZeppelin ERC721, Ownable, ReentrancyGuard

- **Frontend**: HTML, CSS, JavaScript with Ethers.js### Anvil

- **Storage**: IPFS via Pinata

- **Deployment**: Forge + Verification scripts```shell

$ anvil

## 📁 Project Structure```



```### Deploy

animals_project/

├── src/```shell

│   └── Animals.sol           # Main NFT contract$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>

├── script/```

│   ├── DeployAnimals.s.sol   # Deployment script

│   └── Setup.s.sol           # Setup script for mint window### Cast

├── test/

│   └── Animals.t.sol         # Contract tests```shell

├── mint_site/$ cast <subcommand>

│   ├── index.html            # Mint website```

│   ├── app.js                # Web3 integration

│   └── styles.css            # Styling### Help

├── netlify-deploy/           # Production-ready website

├── metadata/                 # IPFS metadata files```shell

└── whitelist-addresses.csv   # Whitelisted wallets$ forge --help

```$ anvil --help

$ cast --help

## 🔧 Contract Functions```


### Public Functions
- `mint(uint256 _numTokens)` - Mint baby animals (free)
- `upgradeAnimal(uint256 tokenId)` - Upgrade baby to adult
- `canUpgrade(uint256 tokenId)` - Check if upgrade available
- `timeUntilUpgrade(uint256 tokenId)` - Time remaining for upgrade

### View Functions
- `isMintWindowOpen()` - Check if minting is active
- `isUpgraded(uint256 tokenId)` - Check if animal is adult
- `tokenToAnimal(uint256 tokenId)` - Get animal type
- `getTokenInfo(uint256 tokenId)` - Complete token information

## 🌐 Deployment Information

- **Deployed**: October 2025
- **Etherscan**: [View Contract](https://sepolia.etherscan.io/address/0x7cAca921010BC0dA27F0ca5a89FcCec0Ae4184A2)
- **IPFS Baby Metadata**: `bafybeid7ejvkeez4qfhfuxigsem6p5g3jdigqjnyxrym55rnrth3lm646y`
- **IPFS Adult Metadata**: `bafybeib2vboobdtc2iiny6gagxn5ppn4u4pwth6cxneflasnldgxlgiwt4`

## 🎨 IPFS Metadata

All NFT metadata and images are stored on IPFS:
- **Baby Animals**: Cute young versions with growth potential
- **Adult Animals**: Magnificent evolved forms with enhanced artwork
- **Decentralized**: Permanent storage via Pinata gateway

## 🏗️ Development Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd animals_project

# Install Foundry dependencies
forge install

# Build contracts
forge build

# Run tests
forge test

# Deploy (requires .env setup)
forge script script/DeployAnimals.s.sol --rpc-url sepolia --broadcast --verify
```

## 🌐 Website Deployment

The mint site is ready for deployment to Netlify:

```bash
# Deploy to Netlify (drag & drop)
# Use the netlify-deploy/ folder contents

# Or use Netlify CLI
cd netlify-deploy
netlify deploy --prod
```

## 📊 Mint Statistics

- **Reserved Tokens**: 4 (auto-minted to owner)
- **Public Mints**: 6 (from whitelisted wallets)
- **Total Minted**: 10/10 (SOLD OUT)
- **Mint Window**: 48 hours (completed)
- **Success Rate**: 100% ✅

## 🎉 Project Highlights

This project demonstrates:
- ✅ Complete NFT smart contract development
- ✅ Advanced features (upgrades, time windows, whitelists)
- ✅ Professional web3 frontend integration
- ✅ IPFS metadata management
- ✅ Successful testnet deployment and verification
- ✅ Production-ready mint website
- ✅ Complete project lifecycle from concept to sold-out collection

## 📄 License

MIT License - See LICENSE file for details.

---

**Built with ❤️ by the Animals NFT Team**