// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract CheckStatus is Script {
    address constant NFT_CONTRACT = 0x55D92aC78510433C42fBE464b36C7b75ae03e9ED;
    
    function setUp() public {}
    
    function run() public view {
        Animals nft = Animals(NFT_CONTRACT);
        
        console.log("=== ANIMALS NFT CONTRACT STATUS ===");
        console.log("Contract Address:", address(nft));
        console.log("Owner:", nft.owner());
        console.log("");
        
        console.log("=== SUPPLY INFO ===");
        console.log("Current Supply:", nft.totalSupply());
        console.log("Max Supply:", nft.MAX_SUPPLY());
        console.log("Remaining:", nft.MAX_SUPPLY() - nft.totalSupply());
        console.log("");
        
        console.log("=== SALE STATUS ===");
        console.log("Sale Active:", nft.isSaleActive());
        console.log("Whitelist Active:", nft.isWhitelistActive());
        console.log("Mint Window Open:", nft.isMintWindowOpen());
        console.log("Price:", nft.price(), "wei");
        console.log("");
        
        console.log("=== MINT WINDOW ===");
        if (nft.mintStartTime() > 0) {
            console.log("Start Time:", nft.mintStartTime());
            console.log("End Time:", nft.getMintWindowEndTime());
            console.log("Time Remaining:", nft.getTimeRemainingInMintWindow(), "seconds");
        } else {
            console.log("Mint window not started yet");
        }
        console.log("");
        
        console.log("=== METADATA ===");
        console.log("Baby Animals URI:", nft.firstBaseURI());
        console.log("Adult Animals URI:", nft.secondBaseURI());
        console.log("");
        
        console.log("=== CONTRACT BALANCE ===");
        console.log("Balance:", address(nft).balance, "wei");
        console.log("Balance:", address(nft).balance / 1 ether, "ETH");
    }
}