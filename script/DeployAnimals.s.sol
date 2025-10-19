// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract DeployAnimals is Script {
    function setUp() public {}
    function run() public {
        string memory privateKeys = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x",privateKeys));
        vm.startBroadcast(deployerPrivateKey);
        
        //  deploy to the contract
        Animals animals = new Animals();

        console.log("Contract deployed to:", address(animals));
        console.log("Owner: ", animals.owner());
        console.log("Base URI: ", animals.firstBaseURI());
        console.log("Total Supply: ", animals.totalSupply());
        console.log("Max Supply: ", animals.MAX_SUPPLY());
        console.log("Price: ", animals.price());


        vm.stopBroadcast();
    }
}