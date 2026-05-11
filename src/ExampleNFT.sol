// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./CIDLib.sol";

contract ExampleNFT is ERC1155("") {
    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked("ipfs://", CIDLib.toCID(tokenId), "/metadata.json"));
    }
}
