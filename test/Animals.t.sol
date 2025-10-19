// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/Animals.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract AnimalsTest is Test, IERC721Receiver {
    Animals public nft;
    address public owner;
    address public user1;
    address public user2;
    address public notWhitelisted;
    
    string constant BABY_URI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeid7ejvkeez4qfhfuxigsem6p5g3jdigqjnyxrym55rnrth3lm646y/";
    string constant ADULT_URI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeidqp2gfcttkoowvhj2s54gqovh2tizuqpvhgdspyjsgiiqhlspijy/";
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        // Set up addresses
        owner = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        notWhitelisted = vm.addr(3);
        
        // Deploy contract
        nft = new Animals();
        
        // Set up base URIs
        nft.setFirstBaseUri(BABY_URI);
        nft.setSecondBaseUri(ADULT_URI);
        
        // Add users to whitelist
        address[] memory whitelistAddresses = new address[](2);
        whitelistAddresses[0] = user1;
        whitelistAddresses[1] = user2;
        nft.addToWhitelist(whitelistAddresses);
        
        // Give users some ETH for gas
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(notWhitelisted, 10 ether);
    }
    
    // ===== DEPLOYMENT TESTS =====
    
    function testInitialState() public {
        assertEq(nft.name(), "Animals");
        assertEq(nft.symbol(), "ANML");
        assertEq(nft.MAX_SUPPLY(), 10);
        assertEq(nft.TOKENS_RESERVED(), 4);
        assertEq(nft.totalSupply(), 4); // Owner gets 4 reserved tokens
        assertEq(nft.price(), 0);
        assertEq(nft.owner(), owner);
        assertTrue(nft.isWhitelistActive());
        assertFalse(nft.isSaleActive());
    }
    
    function testOwnerGetsReservedTokens() public {
        assertEq(nft.balanceOf(owner), 4);
        assertEq(nft.ownerOf(1), owner);
        assertEq(nft.ownerOf(2), owner);
        assertEq(nft.ownerOf(3), owner);
        assertEq(nft.ownerOf(4), owner);
    }
    
    // ===== WHITELIST TESTS =====
    
    function testWhitelistManagement() public {
        assertTrue(nft.isWhitelisted(user1));
        assertTrue(nft.isWhitelisted(user2));
        assertFalse(nft.isWhitelisted(notWhitelisted));
        
        // Add new address
        address[] memory newAddresses = new address[](1);
        newAddresses[0] = notWhitelisted;
        nft.addToWhitelist(newAddresses);
        assertTrue(nft.isWhitelisted(notWhitelisted));
        
        // Remove address
        nft.removeFromWhitelist(newAddresses);
        assertFalse(nft.isWhitelisted(notWhitelisted));
    }
    
    function testToggleWhitelist() public {
        assertTrue(nft.isWhitelistActive());
        nft.toggleWhitelist();
        assertFalse(nft.isWhitelistActive());
        nft.toggleWhitelist();
        assertTrue(nft.isWhitelistActive());
    }
    
    // ===== MINT WINDOW TESTS =====
    
    function testMintWindow() public {
        assertFalse(nft.isMintWindowOpen());
        assertEq(nft.mintStartTime(), 0);
        
        // Start mint window
        nft.startMintWindow();
        assertTrue(nft.isMintWindowOpen());
        assertTrue(nft.isSaleActive());
        assertEq(nft.mintStartTime(), block.timestamp);
        
        // Fast forward 24 hours - should still be open
        vm.warp(block.timestamp + 24 hours);
        assertTrue(nft.isMintWindowOpen());
        
        // Fast forward past 48 hours - should be closed
        vm.warp(block.timestamp + 25 hours); // Total 49 hours
        assertFalse(nft.isMintWindowOpen());
    }
    
    function testGetMintWindowTimes() public {
        nft.startMintWindow();
        uint256 startTime = block.timestamp;
        
        assertEq(nft.getMintWindowEndTime(), startTime + 48 hours);
        assertEq(nft.getTimeRemainingInMintWindow(), 48 hours);
        
        // Fast forward 3 hours
        vm.warp(block.timestamp + 3 hours);
        assertEq(nft.getTimeRemainingInMintWindow(), 45 hours);
        
        // Fast forward past end
        vm.warp(block.timestamp + 46 hours); // Total 49 hours
        assertEq(nft.getTimeRemainingInMintWindow(), 0);
    }
    
    // ===== MINTING TESTS =====
    
    function testMintSuccess() public {
        // Start mint window
        nft.startMintWindow();
        
        // User1 mints 1 token
        vm.prank(user1);
        nft.mint(1);
        
        assertEq(nft.totalSupply(), 5); // 4 reserved + 1 minted
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(5), user1);
        assertEq(nft.mintedPerWallet(user1), 1);
    }
    
    function testMintFailures() public {
        // Try to mint without sale active
        vm.prank(user1);
        vm.expectRevert("Sale must be active to mint");
        nft.mint(1);
        
        // Start sale but no mint window
        nft.flipSaleState();
        vm.prank(user1);
        vm.expectRevert("Mint window is closed");
        nft.mint(1);
        
        // Start mint window
        nft.startMintWindow();
        
        // Non-whitelisted user tries to mint
        vm.prank(notWhitelisted);
        vm.expectRevert("You are not whitelisted");
        nft.mint(1);
        
        // Try to mint too many at once
        vm.prank(user1);
        vm.expectRevert("Exceeds max mint per wallet");
        nft.mint(3);
        
        // Mint max amount, then try to mint more
        vm.prank(user1);
        nft.mint(2);
        vm.prank(user1);
        vm.expectRevert("Exceeds max mint per wallet");
        nft.mint(1);
    }
    
    function testMintExceedsSupply() public {
        nft.startMintWindow();
        
        // Mint remaining 6 tokens (10 max - 4 reserved = 6 available)
        vm.prank(user1);
        nft.mint(2);
        vm.prank(user2);
        nft.mint(2);
        
        // Add more users and mint remaining
        address[] memory newUsers = new address[](2);
        newUsers[0] = vm.addr(10);
        newUsers[1] = vm.addr(11);
        nft.addToWhitelist(newUsers);
        
        vm.deal(newUsers[0], 1 ether);
        vm.deal(newUsers[1], 1 ether);
        
        vm.prank(newUsers[0]);
        nft.mint(1);
        vm.prank(newUsers[1]);
        nft.mint(1);
        
        // Now supply is full, should fail
        address extraUser = vm.addr(12);
        address[] memory extraUserArray = new address[](1);
        extraUserArray[0] = extraUser;
        nft.addToWhitelist(extraUserArray);
        vm.deal(extraUser, 1 ether);
        
        vm.prank(extraUser);
        vm.expectRevert("Exceeds max supply");
        nft.mint(1);
    }
    
    // ===== UPGRADE TESTS =====
    
    function testUpgradeAnimal() public {
        nft.startMintWindow();
        
        // User1 mints token
        vm.prank(user1);
        nft.mint(1);
        uint256 tokenId = 5; // First minted token
        
        // Try to upgrade immediately - should fail (need 12 hours)
        vm.prank(user1);
        vm.expectRevert("Must wait 12 hours after mint");
        nft.upgradeAnimal(tokenId);
        
        // Fast forward 12 hours
        vm.warp(block.timestamp + 12 hours);
        
        // Now upgrade should work
        assertFalse(nft.isUpgraded(tokenId));
        assertTrue(nft.canUpgrade(tokenId)); // Now true because cooldown is over
        assertEq(nft.timeUntilUpgrade(tokenId), 0);
        
        vm.prank(user1);
        nft.upgradeAnimal(tokenId);
        
        assertTrue(nft.isUpgraded(tokenId));
        assertFalse(nft.canUpgrade(tokenId)); // Already upgraded
    }
    
    function testUpgradeFailures() public {
        nft.startMintWindow();
        
        vm.prank(user1);
        nft.mint(1);
        uint256 tokenId = 5;
        
        // Fast forward 12 hours
        vm.warp(block.timestamp + 12 hours);
        
        // Try to upgrade someone else's token
        vm.prank(user2);
        vm.expectRevert("You don't own this token");
        nft.upgradeAnimal(tokenId);
        
        // Upgrade successfully
        vm.prank(user1);
        nft.upgradeAnimal(tokenId);
        
        // Try to upgrade again
        vm.prank(user1);
        vm.expectRevert("Animal already upgraded");
        nft.upgradeAnimal(tokenId);
    }
    
    // ===== METADATA TESTS =====
    
    function testTokenURI() public {
        nft.startMintWindow();
        
        vm.prank(user1);
        nft.mint(1);
        uint256 tokenId = 5;
        
        // Initially shows baby URI with animal name
        string memory babyURI = nft.tokenURI(tokenId);
        string memory expectedBabyURI = string(abi.encodePacked(BABY_URI, "baby_goat.json"));
        assertEq(babyURI, expectedBabyURI);
        
        // Fast forward and upgrade
        vm.warp(block.timestamp + 12 hours);
        vm.prank(user1);
        nft.upgradeAnimal(tokenId);
        
        // Now shows adult URI with animal name
        string memory adultURI = nft.tokenURI(tokenId);
        string memory expectedAdultURI = string(abi.encodePacked(ADULT_URI, "adult_goat.json"));
        assertEq(adultURI, expectedAdultURI);
    }
    
    function testUpdateBaseURIs() public {
        string memory newBabyURI = "https://new-baby.com/";
        string memory newAdultURI = "https://new-adult.com/";
        
        nft.setFirstBaseUri(newBabyURI);
        nft.setSecondBaseUri(newAdultURI);
        
        assertEq(nft.firstBaseURI(), newBabyURI);
        assertEq(nft.secondBaseURI(), newAdultURI);
    }
    
    // ===== OWNER FUNCTIONS TESTS =====
    
    function testOnlyOwnerFunctions() public {
        // Non-owner tries to call owner functions
        vm.prank(user1);
        vm.expectRevert();
        nft.flipSaleState();
        
        vm.prank(user1);
        vm.expectRevert();
        nft.startMintWindow();
        
        vm.prank(user1);
        vm.expectRevert();
        nft.toggleWhitelist();
        
        vm.prank(user1);
        vm.expectRevert();
        nft.setPrice(0.01 ether);
        
        address[] memory addresses = new address[](1);
        addresses[0] = user1;
        
        vm.prank(user1);
        vm.expectRevert();
        nft.addToWhitelist(addresses);
    }
    
    function testPriceUpdate() public {
        assertEq(nft.price(), 0);
        
        nft.setPrice(0.01 ether);
        assertEq(nft.price(), 0.01 ether);
    }
    
    function testWithdraw() public {
        // Contract should have no balance initially
        assertEq(address(nft).balance, 0);
        
        // Send some ETH to contract
        vm.deal(address(nft), 1 ether);
        assertEq(address(nft).balance, 1 ether);
        
        // Withdraw
        nft.withdrawAll();
        assertEq(address(nft).balance, 0);
    }
    
    // Required for ERC721 receiver
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}