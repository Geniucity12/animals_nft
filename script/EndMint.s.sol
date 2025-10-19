// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract EndMint is Script {
    address constant NFT_CONTRACT = 0x55D92aC78510433C42fBE464b36C7b75ae03e9ED;
    
    function setUp() public {}
    
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        console.log("=== ENDING MINT PERIOD ===");
        console.log("Contract:", address(nft));
        
        // End the sale (flip from true to false)
        if (nft.isSaleActive()) {
            nft.flipSaleState();
            console.log("Sale deactivated");
        }
        
        // Disable whitelist (flip from true to false)  
        if (nft.isWhitelistActive()) {
            nft.toggleWhitelist();
            console.log("Whitelist deactivated");
        }
        
        console.log("Note: Mint window will close automatically after 8 hours");
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== FINAL STATUS ===");
        console.log("Sale Active:", nft.isSaleActive());
        console.log("Whitelist Active:", nft.isWhitelistActive());
        console.log("Mint Window Open:", nft.isMintWindowOpen());
        console.log("Total Supply:", nft.totalSupply());
        console.log("Max Supply:", nft.MAX_SUPPLY());
        
        console.log("");
        console.log("Mint period successfully ended!");
    }
}