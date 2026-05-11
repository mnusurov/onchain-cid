// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ExampleNFT.sol";

contract ExampleNFTTest is Test {
    ExampleNFT nft;

    // Known pair: this tokenId decodes to this CIDv0
    uint256 constant TOKEN_ID =
        28760159193833769374168478339871128602539698906402636337341955465066608654847;

    function setUp() public {
        nft = new ExampleNFT();
    }

    function test_uriReturnsIPFSUrl() public view {
        assertEq(
            nft.uri(TOKEN_ID),
            "ipfs://QmScrmPzjdqYvm6NZHXmqXse3A2G44ZCCVoNREhm2ucC5t/metadata.json"
        );
    }
}
