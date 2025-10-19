// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Animals is ERC721, Ownable, ReentrancyGuard {
    using Strings for uint256;
    //  constants
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant TOKENS_RESERVED = 4;
    uint256 public price = 0.0 ether;
    uint256 public constant MAX_MINT_PER_WALLET = 2;

    bool public isSaleActive;
    bool public isWhitelistActive=true;
    uint256 public totalSupply;
    mapping(address => uint256) public mintedPerWallet;
    mapping(address => bool) public whitelist;

    // Mint window variables
    uint256 public mintStartTime;
    uint256 public constant MINT_WINDOW_DURATION = 48 hours;

    string public firstBaseURI;
    string public secondBaseURI;
    string public baseExtension = ".json";
    
    // Track which animals are upgraded
    mapping(uint256 => bool) public isUpgraded;
    
    // Track mint timestamp for each token
    mapping(uint256 => uint256) public mintTimestamp;
    
    // 12 hours cooldown period
    uint256 public constant UPGRADE_COOLDOWN = 12 hours;
    
    // Mapping from token ID to animal name
    mapping(uint256 => string) public tokenToAnimal;
    
    // Available animals (all 10 from start to prevent duplicates)
    string[] private animalNames = ["bird", "cat", "chicken", "dog", "goat", "horse", "lion", "rabbit", "tiger", "zebra"];

    constructor() ERC721("Animals", "ANML") Ownable(msg.sender){
        firstBaseURI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeid7ejvkeez4qfhfuxigsem6p5g3jdigqjnyxrym55rnrth3lm646y/";
        secondBaseURI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeib2vboobdtc2iiny6gagxn5ppn4u4pwth6cxneflasnldgxlgiwt4/";
    
    //  add owner to wl
        for (uint256 i=1; i<= TOKENS_RESERVED; i++) {
            _safeMint(msg.sender, i);
            mintTimestamp[i] = block.timestamp;
            
            // Assign animals to reserved tokens
            string memory animalName = animalNames[(i - 1) % animalNames.length];
            tokenToAnimal[i] = animalName;
        }
        totalSupply = TOKENS_RESERVED;   
    }

    function mint(uint256 _numTokens) external payable {
        require(isSaleActive, "Sale must be active to mint");
        require(isMintWindowOpen(), "Mint window is closed");

        // check if whitelist is active
        if (isWhitelistActive) {
            require(whitelist[msg.sender], "You are not whitelisted");
        }

        require(_numTokens <= MAX_MINT_PER_WALLET, "Exceeds max mint per wallet");
        require(mintedPerWallet[msg.sender] + _numTokens <= MAX_MINT_PER_WALLET, "Exceeds max mint per wallet");
        uint256 curTotalSupply = totalSupply;
        require(curTotalSupply + _numTokens <= MAX_SUPPLY, "Exceeds max supply");
        
        for (uint256 i = 1; i <= _numTokens; i++) {
            uint256 tokenId = curTotalSupply + i;
            _safeMint(msg.sender, tokenId);
            mintTimestamp[tokenId] = block.timestamp;
            
            // Assign random animal (simple pseudo-random)
            string memory animalName = animalNames[(tokenId - 1) % animalNames.length];
            tokenToAnimal[tokenId] = animalName;
        }
        totalSupply += _numTokens;
        mintedPerWallet[msg.sender] += _numTokens;
    }

    function upgradeAnimal(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You don't own this token");
        require(!isUpgraded[tokenId], "Animal already upgraded");
        require(block.timestamp >= mintTimestamp[tokenId] + UPGRADE_COOLDOWN, "Must wait 12 hours after mint");
        
        // Mark as upgraded
        isUpgraded[tokenId] = true;
    }
    
    function canUpgrade(uint256 tokenId) external view returns (bool) {
        if (isUpgraded[tokenId]) return false;
        return block.timestamp >= mintTimestamp[tokenId] + UPGRADE_COOLDOWN;
    }
    
    function timeUntilUpgrade(uint256 tokenId) external view returns (uint256) {
        if (isUpgraded[tokenId]) return 0;
        uint256 upgradeTime = mintTimestamp[tokenId] + UPGRADE_COOLDOWN;
        if (block.timestamp >= upgradeTime) return 0;
        return upgradeTime - block.timestamp;
    }
    
    function getTokenInfo(uint256 tokenId) external view returns (string memory animalType, bool upgraded, uint256 mintTime, bool canUpgradeNow) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return (
            tokenToAnimal[tokenId],
            isUpgraded[tokenId],
            mintTimestamp[tokenId],
            this.canUpgrade(tokenId)
        );
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        
        string memory animalName = tokenToAnimal[tokenId];
        string memory stage = isUpgraded[tokenId] ? "adult_" : "baby_";
        string memory baseURI = isUpgraded[tokenId] ? secondBaseURI : firstBaseURI;
        
        return bytes(baseURI).length > 0 
            ? string(abi.encodePacked(baseURI, stage, animalName, baseExtension))
            : "";
    }

    //  whitelist functions
    function addToWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }
    function removeFromWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = false;
        }
    }
    function isWhitelisted(address _address) external view returns (bool) {
        return whitelist[_address];
    }
    
    function toggleWhitelist() external onlyOwner {
        isWhitelistActive = !isWhitelistActive;
    }

    // only owner functions
    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }
    
    function startMintWindow() external onlyOwner {
        mintStartTime = block.timestamp;
        isSaleActive = true;
    }
    
    function isMintWindowOpen() public view returns (bool) {
        if (mintStartTime == 0) return false; // Not started yet
        return block.timestamp <= mintStartTime + MINT_WINDOW_DURATION;
    }
    
    function getMintWindowEndTime() external view returns (uint256) {
        if (mintStartTime == 0) return 0;
        return mintStartTime + MINT_WINDOW_DURATION;
    }
    
    function getTimeRemainingInMintWindow() external view returns (uint256) {
        if (mintStartTime == 0) return 0;
        uint256 endTime = mintStartTime + MINT_WINDOW_DURATION;
        if (block.timestamp >= endTime) return 0;
        return endTime - block.timestamp;
    }

    function setFirstBaseUri(string memory _newBaseUri) external onlyOwner {
        firstBaseURI = _newBaseUri;
    }
    
    function setSecondBaseUri(string memory _newBaseUri) external onlyOwner {
        secondBaseURI = _newBaseUri;
    }
    
    function addAnimalType(string memory _animalName) external onlyOwner {
        animalNames.push(_animalName);
    }
    
    function getAnimalTypes() external view returns (string[] memory) {
        return animalNames;
    }
    
    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function withdrawAll() external onlyOwner {
        uint256 balance = address(this).balance;
        uint256 balanceOne = balance * 50 / 100;
        uint256 balanceTwo = balance - balanceOne;
        (bool transferOne,) = payable(0x80696902EdE585e71F14D9d5719b37f85DD1FeBf).call{value: balanceOne}("");
        (bool transferTwo,) = payable(0xecD3fbb622Fab3e914A12e6B270aBc379b448437).call{value: balanceTwo}("");
        require(transferOne && transferTwo, "Transfer failed.");
    }


}
