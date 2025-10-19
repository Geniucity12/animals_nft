// Contract Configuration
const CONTRACT_ADDRESS = "0x7cAca921010BC0dA27F0ca5a89FcCec0Ae4184A2";
const SEPOLIA_CHAIN_ID = "0xaa36a7"; // 11155111 in hex
const SEPOLIA_RPC = "https://eth-sepolia.g.alchemy.com/v2/eZsj_zFzfMrdzh4Ke4hEJ";

// Debug: Check if ethers is loaded

if (typeof ethers !== 'undefined') {
    
}

// Contract ABI (essential functions only)
const CONTRACT_ABI = [
    "function mint(uint256 _numTokens) external payable",
    "function upgradeAnimal(uint256 tokenId) external",
    "function tokenURI(uint256 tokenId) external view returns (string)",
    "function ownerOf(uint256 tokenId) external view returns (address)",
    "function balanceOf(address owner) external view returns (uint256)",
    "function totalSupply() external view returns (uint256)",
    "function MAX_SUPPLY() external view returns (uint256)",
    "function MAX_MINT_PER_WALLET() external view returns (uint256)",
    "function isMintWindowOpen() external view returns (bool)",
    "function isWhitelisted(address user) external view returns (bool)",
    "function isUpgraded(uint256 tokenId) external view returns (bool)",
    "function canUpgrade(uint256 tokenId) external view returns (bool)",
    "function timeUntilUpgrade(uint256 tokenId) external view returns (uint256)",
    "function price() external view returns (uint256)",
    "function isSaleActive() external view returns (bool)",
    "function mintedCount(address user) external view returns (uint256)"
];

// Global variables
let provider;
let signer;
let contract;
let userAddress;

// Initialize the app
async function init() {
    // Check if MetaMask is installed
    if (typeof window.ethereum !== 'undefined') {
        
        
        setupEventListeners();
        await loadContractInfo();
    } else {
        showMessage('Please install MetaMask to use this app!', 'error');
    }
}

// Setup event listeners
function setupEventListeners() {
    document.getElementById('connect-wallet').addEventListener('click', connectWallet);
    document.getElementById('mint-btn').addEventListener('click', mintNFT);
    document.getElementById('increase-btn').addEventListener('click', () => changeQuantity(1));
    document.getElementById('decrease-btn').addEventListener('click', () => changeQuantity(-1));
}

// Connect wallet
async function connectWallet() {
    try {
        if (typeof window.ethereum === 'undefined') {
            throw new Error('MetaMask not installed');
        }

        // Request account access
        const accounts = await window.ethereum.request({
            method: 'eth_requestAccounts'
        });

        if (accounts.length === 0) {
            throw new Error('No accounts found');
        }

        // Setup provider and signer
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        userAddress = accounts[0];

        // Setup contract
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

        // Check network
        const network = await provider.getNetwork();
        if (network.chainId !== 11155111) {
            await switchToSepolia();
        }

        // Update UI
        updateWalletUI();
        await loadUserData();

    } catch (error) {
        console.error('Error connecting wallet:', error);
        showMessage(`Error connecting wallet: ${error.message}`, 'error');
    }
}

// Switch to Sepolia network
async function switchToSepolia() {
    try {
        await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: SEPOLIA_CHAIN_ID }],
        });
    } catch (switchError) {
        // If Sepolia is not added to MetaMask
        if (switchError.code === 4902) {
            try {
                await window.ethereum.request({
                    method: 'wallet_addEthereumChain',
                    params: [{
                        chainId: SEPOLIA_CHAIN_ID,
                        chainName: 'Sepolia Test Network',
                        nativeCurrency: {
                            name: 'SepoliaETH',
                            symbol: 'ETH',
                            decimals: 18
                        },
                        rpcUrls: [SEPOLIA_RPC],
                        blockExplorerUrls: ['https://sepolia.etherscan.io/']
                    }]
                });
            } catch (addError) {
                throw new Error('Failed to add Sepolia network');
            }
        } else {
            throw switchError;
        }
    }
}

// Update wallet UI
function updateWalletUI() {
    document.getElementById('connect-wallet').style.display = 'none';
    document.getElementById('wallet-info').classList.remove('hidden');
    document.getElementById('wallet-address').textContent = `${userAddress.slice(0, 6)}...${userAddress.slice(-4)}`;
    document.getElementById('network-name').textContent = 'Sepolia Testnet';
    
    // Enable mint button and update text
    const mintBtn = document.getElementById('mint-btn');
    mintBtn.disabled = false;
    updateMintButtonText();
}

// Change quantity function
function changeQuantity(change) {
    const mintAmountInput = document.getElementById('mint-amount');
    const increaseBtn = document.getElementById('increase-btn');
    const decreaseBtn = document.getElementById('decrease-btn');
    
    let currentAmount = parseInt(mintAmountInput.value);
    let newAmount = currentAmount + change;
    
    // Clamp between 1 and 2 (or max available)
    newAmount = Math.max(1, Math.min(2, newAmount));
    
    mintAmountInput.value = newAmount;
    
    // Update button states
    decreaseBtn.disabled = newAmount <= 1;
    increaseBtn.disabled = newAmount >= 2;
    
    // Update mint button text
    updateMintButtonText();
}

// Update mint button text
function updateMintButtonText() {
    const mintBtn = document.getElementById('mint-btn');
    const amount = document.getElementById('mint-amount').value;
    const plural = amount > 1 ? 's' : '';
    mintBtn.textContent = `Mint ${amount} Baby Animal${plural} (FREE)`;
}

// Load contract information
async function loadContractInfo() {
    try {
        // Create read-only provider for contract info
        const readProvider = new ethers.providers.JsonRpcProvider(SEPOLIA_RPC);
        const readContract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, readProvider);

        // Get mint window status
        const isMintOpen = await readContract.isMintWindowOpen();
        document.getElementById('mint-status').textContent = isMintOpen ? 'OPEN (48 hours)' : 'CLOSED';
        document.getElementById('mint-status').style.color = isMintOpen ? 'green' : 'red';

        // Get total supply
        const totalSupply = await readContract.totalSupply();
        const maxSupply = await readContract.MAX_SUPPLY();
        const available = maxSupply.sub(totalSupply);
        document.getElementById('available-count').textContent = available.toString();

    } catch (error) {
        console.error('Error loading contract info:', error);
        document.getElementById('mint-status').textContent = 'Error loading';
        document.getElementById('available-count').textContent = 'Error';
    }
}

// Load user-specific data
async function loadUserData() {
    try {
        // Check whitelist status
        const isWhitelisted = await contract.isWhitelisted(userAddress);
        document.getElementById('whitelist-status').textContent = isWhitelisted ? 'WHITELISTED ✅' : 'NOT WHITELISTED ❌';
        document.getElementById('whitelist-status').style.color = isWhitelisted ? 'green' : 'red';

        // Check how many user has already minted
        let userMintedCount = 0;
        try {
            userMintedCount = await contract.mintedCount(userAddress);
            userMintedCount = userMintedCount.toNumber();
        } catch (error) {
            
            const balance = await contract.balanceOf(userAddress);
            userMintedCount = balance.toNumber();
        }

        // Get max mint per wallet
        const maxMintPerWallet = await contract.MAX_MINT_PER_WALLET();
        const remainingMints = Math.max(0, maxMintPerWallet.toNumber() - userMintedCount);

        // Update quantity selector based on remaining mints
        updateQuantitySelector(remainingMints);

        // Load user's NFTs
        await loadUserNFTs();

    } catch (error) {
        console.error('Error loading user data:', error);
        showMessage('Error loading user data', 'error');
    }
}

// Update quantity selector based on remaining mints
function updateQuantitySelector(remainingMints) {
    const mintAmountInput = document.getElementById('mint-amount');
    const increaseBtn = document.getElementById('increase-btn');
    const decreaseBtn = document.getElementById('decrease-btn');
    const mintBtn = document.getElementById('mint-btn');
    const limitText = document.querySelector('.mint-limit');

    if (remainingMints <= 0) {
        mintAmountInput.value = 0;
        mintAmountInput.max = 0;
        increaseBtn.disabled = true;
        decreaseBtn.disabled = true;
        mintBtn.disabled = true;
        mintBtn.textContent = 'Mint Limit Reached';
        limitText.textContent = 'You have reached your mint limit';
        limitText.style.color = 'red';
    } else {
        const maxAmount = Math.min(2, remainingMints);
        mintAmountInput.max = maxAmount;
        mintAmountInput.value = Math.min(parseInt(mintAmountInput.value) || 1, maxAmount);
        
        increaseBtn.disabled = parseInt(mintAmountInput.value) >= maxAmount;
        decreaseBtn.disabled = parseInt(mintAmountInput.value) <= 1;
        
        limitText.textContent = `${remainingMints} remaining for your wallet`;
        limitText.style.color = '#6c757d';
        
        updateMintButtonText();
    }
}

// Load user's NFTs
async function loadUserNFTs() {
    try {
        const balance = await contract.balanceOf(userAddress);
        const nftGrid = document.getElementById('nft-grid');
        
        
        
        if (balance.eq(0)) {
            nftGrid.innerHTML = '<p>You don\'t own any animals yet. Mint your first one!</p>';
            return;
        }

        nftGrid.innerHTML = '';
        const upgradeSection = document.getElementById('upgrade-section');
        upgradeSection.classList.remove('hidden');

        // Instead of using tokenOfOwnerByIndex, we'll check all tokens from 1 to totalSupply
        const totalSupply = await contract.totalSupply();
        
        
        let foundTokens = 0;
        
        for (let tokenId = 1; tokenId <= totalSupply.toNumber() && foundTokens < balance.toNumber(); tokenId++) {
            try {
                const owner = await contract.ownerOf(tokenId);
                
                
                if (owner.toLowerCase() === userAddress.toLowerCase()) {
                    await createNFTCard(tokenId, nftGrid);
                    foundTokens++;
                }
            } catch (error) {
                
                // Token might not exist, continue
            }
        }
        
        if (foundTokens === 0) {
            nftGrid.innerHTML = '<p>No tokens found for your address</p>';
        }

    } catch (error) {
        console.error('Error loading NFTs:', error);
        document.getElementById('nft-grid').innerHTML = `<p>Error loading your animals: ${error.message}</p>`;
    }
}

// Create NFT card
async function createNFTCard(tokenId, container) {
    try {
        
        
        const tokenURI = await contract.tokenURI(tokenId);
        
        
        const isUpgraded = await contract.isUpgraded(tokenId);
        
        
        // Fetch the actual metadata from IPFS
        const metadataResponse = await fetch(tokenURI);
        const metadata = await metadataResponse.json();
        
        
        const card = document.createElement('div');
        card.className = `nft-card ${!isUpgraded ? 'upgradeable' : ''}`;
        
        card.innerHTML = `
            <div class="nft-image">
                <img src="${metadata.image}" alt="${metadata.name}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 8px;" onload=">Image Error</text></svg>'">
            </div>
            <div class="nft-title">${metadata.name}</div>
            <div class="nft-id">Token #${tokenId}</div>
            <div class="nft-description">${metadata.description}</div>
            ${!isUpgraded ? `<button class="btn btn-upgrade" onclick="upgradeAnimal(${tokenId})">Upgrade to Adult</button>` : '<p style="color: green; font-weight: bold;">Fully Grown!</p>'}
        `;
        
        container.appendChild(card);
        
        
    } catch (error) {
        console.error(`Error creating card for token ${tokenId}:`, error);
        
        // Create a basic error card
        const card = document.createElement('div');
        card.className = 'nft-card';
        card.innerHTML = `
            <div class="nft-image" style="background: #f8f9fa; display: flex; align-items: center; justify-content: center;">
                <span style="color: #6c757d;">Failed to load</span>
            </div>
            <div class="nft-title">Token #${tokenId}</div>
            <div class="nft-id">Loading Error</div>
            <p style="color: red; font-size: 12px;">Error: ${error.message}</p>
        `;
        container.appendChild(card);
    }
}

// Mint NFT
async function mintNFT() {
    try {
        const mintBtn = document.getElementById('mint-btn');
        mintBtn.disabled = true;
        mintBtn.textContent = 'Checking requirements...';
        
        showMessage('Checking mint requirements...', 'loading');

        // Get the number of tokens to mint
        const numTokens = parseInt(document.getElementById('mint-amount').value);

        // First, let's check all the requirements manually
        
        
        // Check if mint window is open
        const isMintOpen = await contract.isMintWindowOpen();
        
        if (!isMintOpen) {
            throw new Error('Mint window is closed');
        }

        // Check if user is whitelisted
        const isWhitelisted = await contract.isWhitelisted(userAddress);
        
        if (!isWhitelisted) {
            throw new Error('You are not whitelisted for minting');
        }

        // Check total supply vs max supply
        const totalSupply = await contract.totalSupply();
        const maxSupply = await contract.MAX_SUPPLY();
        
        if (totalSupply.gte(maxSupply)) {
            throw new Error('All NFTs have been minted');
        }

        // Check user's current balance (to see if they already minted)
        const userBalance = await contract.balanceOf(userAddress);
        

        // Check if sale is active (additional check)
        try {
            const isSaleActive = await contract.isSaleActive();
            
            if (!isSaleActive) {
                throw new Error('Sale is not active');
            }
        } catch (e) {
            
        }

        mintBtn.textContent = 'Minting...';
        showMessage('All checks passed! Preparing to mint...', 'loading');

        // Try to estimate gas first for better error reporting
        try {
            const gasEstimate = await contract.estimateGas.mint(numTokens);
            
        } catch (gasError) {
            console.error('Gas estimation failed:', gasError);
            // Try to get the revert reason
            if (gasError.reason) {
                throw new Error(`Contract error: ${gasError.reason}`);
            } else if (gasError.message.includes('execution reverted')) {
                throw new Error('Transaction would fail - possible reasons: mint limit reached, not whitelisted, or mint window closed');
            } else {
                throw gasError;
            }
        }

        // If gas estimation succeeded, proceed with the mint
        const tx = await contract.mint(numTokens, {
            gasLimit: 300000 // Set a manual gas limit
        });
        
        showMessage('Transaction sent! Waiting for confirmation...', 'loading');
        
        
        const receipt = await tx.wait();
        
        showMessage('Mint successful! Your baby animal has been minted!', 'success');
        
        // Reload user data
        await loadUserData();
        await loadContractInfo();
        
    } catch (error) {
        console.error('Error minting:', error);
        
        // Provide more specific error messages
        let errorMessage = error.message;
        if (error.message.includes('execution reverted')) {
            errorMessage = 'Mint failed: Transaction reverted. Possible reasons:\n• Mint window may be closed\n• You may not be whitelisted\n• You may have already minted\n• Supply may be exhausted';
        } else if (error.code === 'UNPREDICTABLE_GAS_LIMIT') {
            errorMessage = 'Mint failed: Contract requirements not met. Check console for details.';
        }
        
        showMessage(`Mint failed: ${errorMessage}`, 'error');
    } finally {
        const mintBtn = document.getElementById('mint-btn');
        mintBtn.disabled = false;
        mintBtn.textContent = 'Mint Baby Animal (FREE)';
    }
}

// Upgrade animal
async function upgradeAnimal(tokenId) {
    try {
        
        
        
        
        
        showMessage('🔍 Checking if your animal is ready to grow up...', 'loading');

        // First, let's verify the token exists and user owns it
        
        const tokenOwner = await contract.ownerOf(tokenId);
        
        
        
        
        if (tokenOwner.toLowerCase() !== userAddress.toLowerCase()) {
            throw new Error('🚫 Hey! You can only upgrade your own animals, not someone else\'s pets!');
        }

        // Check if already upgraded
        
        const isAlreadyUpgraded = await contract.isUpgraded(tokenId);
        
        
        if (isAlreadyUpgraded) {
            throw new Error('🌟 This animal is already fully grown and living its best adult life!');
        }

        // Check if the animal can be upgraded using the contract's canUpgrade function
        
        const canUpgradeNow = await contract.canUpgrade(tokenId);
        
        
        if (!canUpgradeNow) {
            
            // Get time until upgrade to show helpful message
            const timeUntil = await contract.timeUntilUpgrade(tokenId);
            
            
            if (timeUntil.gt(0)) {
                const remainingSeconds = timeUntil.toNumber();
                const hours = Math.floor(remainingSeconds / 3600);
                const minutes = Math.floor((remainingSeconds % 3600) / 60);
                
                const funMessages = [
                    `🐣 Your animal is still growing! Come back in ${hours}h ${minutes}m when it's ready for its big transformation!`,
                    `🌱 Patience, young trainer! Your animal needs ${hours}h ${minutes}m more to reach its full potential!`,
                    `⏰ Your animal is taking a growth nap! Wake it up in ${hours}h ${minutes}m for its evolution!`,
                    `🍼 Still a baby for ${hours}h ${minutes}m more! Growing up takes time, you know!`,
                    `💤 Shhh... your animal is dreaming of being an adult! Check back in ${hours}h ${minutes}m!`
                ];
                
                const randomMessage = funMessages[Math.floor(Math.random() * funMessages.length)];
                throw new Error(randomMessage);
            }
        }

        
        showMessage('✨ Cooldown complete! Starting the magical transformation...', 'loading');

        // Proceed with upgrade
        
        const tx = await contract.upgradeAnimal(tokenId);
        
        showMessage('🎭 Transformation spell cast! Waiting for the magic to happen...', 'loading');
        
        const receipt = await tx.wait();
        
        
        
        const celebrationMessages = [
            `🎉 Congratulations! Token #${tokenId} has evolved into a magnificent adult!`,
            `🌟 Amazing! Your baby animal has grown up into a beautiful adult creature!`,
            `🚀 Evolution complete! Token #${tokenId} is now ready to take on the world!`,
            `🎊 Ta-da! Your little one has become a strong, proud adult animal!`,
            `✨ The transformation is complete! Your adult animal is absolutely stunning!`
        ];
        
        const randomCelebration = celebrationMessages[Math.floor(Math.random() * celebrationMessages.length)];
        showMessage(randomCelebration, 'success');
        
        // Reload user NFTs to show the updated animal
        await loadUserNFTs();
        
    } catch (error) {
        console.error('=== UPGRADE DEBUG - ERROR ===');
        console.error('Error upgrading:', error);
        console.error('Error message:', error.message);
        console.error('Error code:', error.code);
        console.error('Error data:', error.data);
        console.error('=== UPGRADE DEBUG END - ERROR ===');
        
        let errorMessage = error.message;
        
        // Handle different error types with fun messages
        if (errorMessage.includes('execution reverted')) {
            if (errorMessage.includes('cooldown')) {
                errorMessage = '⏰ Oops! Your animal is still in its growth phase. Please wait for the cooldown to finish!';
            } else if (errorMessage.includes('already upgraded')) {
                errorMessage = '🌟 This animal is already fully grown! No need for more upgrades!';
            } else if (errorMessage.includes('not owner')) {
                errorMessage = '🚫 You can only upgrade animals that belong to you!';
            } else {
                errorMessage = '❌ Something went wrong with the upgrade process. Please try again!';
            }
        }
        
        // If it's already a fun message, use it as is
        if (errorMessage.includes('🐣') || errorMessage.includes('🌱') || errorMessage.includes('⏰') || 
            errorMessage.includes('🍼') || errorMessage.includes('💤') || errorMessage.includes('🌟') || 
            errorMessage.includes('🚫')) {
            showMessage(errorMessage, 'error');
        } else {
            showMessage(`🚫 Upgrade failed: ${errorMessage}`, 'error');
        }
    }
}

// Show message
function showMessage(message, type) {
    const messageDiv = document.getElementById('mint-status-message');
    messageDiv.textContent = message;
    messageDiv.className = type;
    
    if (type === 'success') {
        setTimeout(() => {
            messageDiv.textContent = '';
            messageDiv.className = '';
        }, 5000);
    }
}

// Listen for account changes
if (typeof window.ethereum !== 'undefined') {
    window.ethereum.on('accountsChanged', function (accounts) {
        if (accounts.length === 0) {
            // User disconnected
            location.reload();
        } else {
            // User switched accounts
            location.reload();
        }
    });

    window.ethereum.on('chainChanged', function (chainId) {
        // User switched networks
        location.reload();
    });
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', init);