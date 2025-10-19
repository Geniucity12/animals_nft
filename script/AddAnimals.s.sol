// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract AddAnimals is Script {
    address constant NFT_CONTRACT = 0xF2cAB5f9Ea22D9937205d56C0AA659f7C387f407;
    
    function setUp() public {}
    
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Add the 7 missing animal types to complete the set of 10
        nft.addAnimalType("dog");
        console.log("Added: dog");
        
        nft.addAnimalType("goat");
        console.log("Added: goat");
        
        nft.addAnimalType("horse");
        console.log("Added: horse");
        
        nft.addAnimalType("lion");
        console.log("Added: lion");
        
        nft.addAnimalType("rabbit");
        console.log("Added: rabbit");
        
        nft.addAnimalType("tiger");
        console.log("Added: tiger");
        
        nft.addAnimalType("zebra");
        console.log("Added: zebra");
        
        // Check current animal types
        string[] memory animals = nft.getAnimalTypes();
        console.log("Total animal types:", animals.length);
        
        for (uint i = 0; i < animals.length; i++) {
            console.log("Animal", i, ":", animals[i]);
        }

        vm.stopBroadcast();
    }
}