// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CIDLib.sol";

contract CIDLibTest is Test {
    uint256 constant KNOWN_TOKEN_ID =
        28760159193833769374168478339871128602539698906402636337341955465066608654847;
    string constant KNOWN_CID = "QmScrmPzjdqYvm6NZHXmqXse3A2G44ZCCVoNREhm2ucC5t";

    function test_knownVector() public pure {
        assertEq(CIDLib.toCID(KNOWN_TOKEN_ID), KNOWN_CID);
    }

    function testFuzz_structuralProps(uint256 tokenId) public pure {
        string memory cid = CIDLib.toCID(tokenId);
        bytes memory cidBytes = bytes(cid);
        assertEq(cidBytes.length, 46, "CIDv0 must be exactly 46 characters");
        assertEq(uint8(cidBytes[0]), uint8(bytes1("Q")), "CIDv0 must start with Q");
        assertEq(uint8(cidBytes[1]), uint8(bytes1("m")), "CIDv0 second char must be m");
    }

    /// forge-config: default.fuzz.runs = 50
    function testFuzz_roundTrip(uint256 tokenId) public {
        string memory cid = CIDLib.toCID(tokenId);

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "test/ffi/decode-cid.sh";
        inputs[2] = cid;

        bytes memory result = vm.ffi(inputs);
        // result is 32 raw bytes (Foundry auto-decodes the 0x-prefixed hex output)
        assertEq(result.length, 32, "FFI output must be 32 bytes");
        bytes32 recovered = abi.decode(result, (bytes32));
        assertEq(bytes32(tokenId), recovered, "Round-trip must recover the original tokenId");
    }
}
