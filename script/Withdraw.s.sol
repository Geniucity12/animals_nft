// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract Withdraw is Script {
    address constant NFT_CONTRACT = 0x1234567890123456789012345678901234567890;
    
    function setUp() public {}
    
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Check contract balance
        uint256 balance = address(nft).balance;
        console.log("Contract balance:", balance, "wei");
        console.log("Contract balance:", balance / 1 ether, "ETH");
        
        if (balance > 0) {
            // Withdraw all funds
            nft.withdrawAll();
            console.log("Funds withdrawn successfully!");
        } else {
            console.log("No funds to withdraw");
        }

        vm.stopBroadcast();
    }
}