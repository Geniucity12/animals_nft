// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract MintControl is Script {
    address constant NFT_CONTRACT = 0x55D92aC78510433C42fBE464b36C7b75ae03e9ED;
    
    function setUp() public {}
    
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Start new mint window (restarts 8-hour timer)
        nft.startMintWindow();
        console.log("New 8-hour mint window started!");
        
        // Change price (if needed)
        // uint256 newPrice = 0.01 ether; // Example: change from free to paid
        // nft.setPrice(newPrice);
        // console.log("Price updated to:", newPrice);
        
        // Toggle sale state
        // nft.flipSaleState();
        // console.log("Sale state toggled");
        
        // Check status
        console.log("Sale Active:", nft.isSaleActive());
        console.log("Mint Window Open:", nft.isMintWindowOpen());
        console.log("Time Remaining:", nft.getTimeRemainingInMintWindow(), "seconds");
        console.log("Current Price:", nft.price());

        vm.stopBroadcast();
    }
}