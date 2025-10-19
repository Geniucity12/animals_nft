// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Animals.sol";

contract Setup is Script {
    address constant NFT_CONTRACT = 0x7cAca921010BC0dA27F0ca5a89FcCec0Ae4184A2;
    string constant BABY_ANIMALS_URI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeibt3hz7xbty6xvhvxdzyfdgso26djv2qov4ktv32x6nblphfsndbu/";
    string constant ADULT_ANIMALS_URI = "https://coral-academic-chipmunk-90.mypinata.cloud/ipfs/bafybeidqp2gfcttkoowvhj2s54gqovh2tizuqpvhgdspyjsgiiqhlspijy/";
    
    function setUp() public {}
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEYS");
        uint256 deployerPrivateKey = vm.parseUint(string.concat("0x", privateKeyString));
        vm.startBroadcast(deployerPrivateKey);

        Animals nft = Animals(NFT_CONTRACT);
        
        // Set the base URIs for metadata
        nft.setFirstBaseUri(BABY_ANIMALS_URI);
        nft.setSecondBaseUri(ADULT_ANIMALS_URI);
        console.log("Baby Animals URI set to:", BABY_ANIMALS_URI);
        console.log("Adult Animals URI set to:", ADULT_ANIMALS_URI);
        
        // Read whitelist addresses from CSV file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/whitelist-addresses.csv");
        string memory csv = vm.readFile(path);
        
        // Split CSV by newlines and parse addresses
        string[] memory lines = vm.split(csv, "\n");
        address[] memory whitelistAddresses = new address[](lines.length - 1); // -1 for header
        
        console.log("Reading CSV file with", lines.length, "lines");
        console.log("Adding", lines.length - 1, "addresses to whitelist:");
        
        // Parse addresses (skip header line)
        for (uint256 i = 1; i < lines.length; i++) {
            if (bytes(lines[i]).length > 0) {
                whitelistAddresses[i - 1] = vm.parseAddress(lines[i]);
                console.log("  Address", i, ":", whitelistAddresses[i - 1]);
            }
        }
        
        // Add addresses to whitelist
        nft.addToWhitelist(whitelistAddresses);
        
        // Ensure whitelist is active (it should be by default)
        if (!nft.isWhitelistActive()) {
            nft.toggleWhitelist();
            console.log("Whitelist activated");
        }
        
        // Start the 48-hour mint window
        nft.startMintWindow();
        console.log("48-hour mint window started!");
        
        console.log("Setup completed!");
        console.log("Contract:", address(nft));
        console.log("Baby Animals URI:", nft.firstBaseURI());
        console.log("Adult Animals URI:", nft.secondBaseURI());
        console.log("Sale Active:", nft.isSaleActive());
        console.log("Whitelist Active:", nft.isWhitelistActive());
        console.log("Mint Window Open:", nft.isMintWindowOpen());
        console.log("Owner whitelisted:", nft.isWhitelisted(nft.owner()));

        vm.stopBroadcast();
    }
}

