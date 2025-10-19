// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract ManageWhitelist is Script {
    address constant NFT_CONTRACT = 0x1234567890123456789012345678901234567890;
    
    function setUp() public {}
    
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Add single address to whitelist
        address[] memory newAddresses = new address[](1);
        newAddresses[0] = 0x1234567890123456789012345678901234567890; // Replace with actual address
        
        nft.addToWhitelist(newAddresses);
        console.log("Added address to whitelist:", newAddresses[0]);
        
        // Remove address from whitelist (uncomment if needed)
        // address[] memory removeAddresses = new address[](1);
        // removeAddresses[0] = 0x1234567890123456789012345678901234567890;
        // nft.removeFromWhitelist(removeAddresses);
        
        // Toggle whitelist on/off
        // nft.toggleWhitelist();
        // console.log("Whitelist status toggled");

        vm.stopBroadcast();
    }
}