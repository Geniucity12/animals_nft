// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract UpdateMetadata is Script {
    address constant NFT_CONTRACT = 0x55D92aC78510433C42fBE464b36C7b75ae03e9ED;
    
    function setUp() public {}
    
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Update baby animals URI to new folder with all 10 JSON files
        string memory newBabyURI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeibt3hz7xbty6xvhvxdzyfdgso26djv2qov4ktv32x6nblphfsndbu/";
        nft.setFirstBaseUri(newBabyURI);
        console.log("Baby Animals URI updated to:", newBabyURI);
        
        // Update adult animals URI to new folder with all 10 JSON files
        string memory newAdultURI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeidqp2gfcttkoowvhj2s54gqovh2tizuqpvhgdspyjsgiiqhlspijy/";
        nft.setSecondBaseUri(newAdultURI);
        console.log("Adult Animals URI updated to:", newAdultURI);
        
        // Verify updates
        console.log("Current Baby URI:", nft.firstBaseURI());
        console.log("Current Adult URI:", nft.secondBaseURI());

        vm.stopBroadcast();
    }
}