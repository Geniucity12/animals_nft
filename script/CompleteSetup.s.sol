// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract CompleteSetup is Script {
    address constant NFT_CONTRACT = 0x471ee89aAe38f3587805081B619496ab1Ac6970c;
    
    function setUp() public {}
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Step 1: Set correct metadata URIs
        nft.setFirstBaseUri("https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/QmX4iVNWcNBQmrtpJSPYGkB1HaYmRb7at71pJ4uT4Die26/");
        nft.setSecondBaseUri("https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/QmbdMyZxmzznhTVuYnD8NX8nZ1gk2cfNRWHqfkBNjys6SL/");
        console.log("Updated metadata URIs");
        
        // Step 2: Add all 10 animal types
        nft.addAnimalType("dog");
        nft.addAnimalType("goat");
        nft.addAnimalType("horse");
        nft.addAnimalType("lion");
        nft.addAnimalType("rabbit");
        nft.addAnimalType("tiger");
        nft.addAnimalType("zebra");
        console.log("Added all 10 animal types");
        
        // Step 3: Add whitelist addresses
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/whitelist-addresses.csv");
        string memory csv = vm.readFile(path);
        string[] memory lines = vm.split(csv, "\n");
        address[] memory whitelistAddresses = new address[](lines.length - 1);
        
        for (uint256 i = 1; i < lines.length; i++) {
            if (bytes(lines[i]).length > 0) {
                whitelistAddresses[i - 1] = vm.parseAddress(lines[i]);
            }
        }
        nft.addToWhitelist(whitelistAddresses);
        console.log("Added", lines.length - 1, "addresses to whitelist");
        
        // Step 4: Start mint window
        nft.startMintWindow();
        console.log("8-hour mint window started!");
        
        // Final status
        console.log("NEW CONTRACT READY:");
        console.log("Contract:", address(nft));
        console.log("Total Animals:", nft.getAnimalTypes().length);
        console.log("Sale Active:", nft.isSaleActive());
        console.log("Mint Window Open:", nft.isMintWindowOpen());
        console.log("Whitelist Active:", nft.isWhitelistActive());

        vm.stopBroadcast();
    }
}