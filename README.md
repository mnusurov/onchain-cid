# onchain-cid

On-chain IPFS CIDv0 reconstruction for ERC-1155 / ERC-721 — zero per-token metadata storage.

## The Insight

An IPFS CIDv0 is:

```
base58( 0x12 || 0x20 || sha256_hash )
```

The SHA-256 hash is 32 bytes — a perfect fit for Solidity's `uint256`.

If you mint an NFT where `tokenId = uint256(sha256(metadata))`, the contract can reconstruct the full IPFS URL from `tokenId` alone — **without storing any string on-chain**.

## How It Works

`CIDLib.toCID(uint256 tokenId) → string` in three steps:

1. **Prepend the multihash prefix** — `abi.encodePacked(bytes1(0x12), bytes1(0x20), tokenId)` produces 34 bytes: the SHA2-256 function code (`0x12`), the digest length (`0x20` = 32), and the hash itself.
2. **Base58-encode** — a pure-Solidity implementation of the Bitcoin/IPFS Base58 alphabet runs the standard positional encoding in-place with no external calls.
3. **Return** — the result is always a 46-character string starting with `Qm` (the IPFS CIDv0 prefix for SHA-256 hashes).

## Usage

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install <your-github>/onchain-cid  # or copy src/CIDLib.sol
```

```solidity
import "./CIDLib.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyNFT is ERC1155("") {
    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked("ipfs://", CIDLib.toCID(tokenId), "/metadata.json"));
    }
}
```

The `tokenId` you pass to `mint()` must equal `uint256(bs58.decode(yourCID).slice(2))` — the IPFS CID decoded from Base58 with the `0x1220` multihash prefix stripped.

## Why No Storage?

| Approach | Per-token storage | Gas per mint |
|----------|-------------------|--------------|
| `mapping(uint256 => string)` storing IPFS URL | ~64 bytes/token | ~44 000-66 000 gas |
| `CIDLib.toCID()` — tokenId IS the hash | 0 bytes/token | 0 storage gas |

`CIDLib` trades a small amount of read-time compute (`toCID` costs ~851,051 gas) for eliminating all per-token write storage. For collections of any size, this is a strict win.

## Why CIDv0, Not CIDv1?

IPFS has two CID versions. CIDv1 is the current default, but CIDv0 is the only version that fits in a `uint256`.

CIDv0 has a fixed structure: `base58btc(0x12 || 0x20 || sha256_hash)` - exactly 34 bytes after decoding, where the last 32 bytes are the SHA-256 hash.

CIDv1 prepends a variable-length multibase prefix, version byte, and multicodec - making the total length unpredictable and incompatible with a fixed-width integer.

CIDv0 is deprecated for new IPFS content but remains fully supported. Existing content pinned under a CIDv0 hash is permanently addressable.

## Gas Analysis

```
forge test --ffi --gas-report
```

`toCID(uint256)` gas cost: ~**851,051** gas (pure view, no storage reads)

## Verifying Correctness

Three test layers:

```bash
# Unit + structural fuzz (no FFI required)
forge test --match-contract CIDLibTest

# Full suite including FFI round-trip (requires Node.js + bs58)
npm install
forge test --ffi
```

The FFI wrapper (`test/ffi/decode-cid.sh`) locates `node` for NVM, fnm, volta, and asdf users - Foundry subprocesses don't source shell profiles.

The FFI round-trip test (`testFuzz_roundTrip`) calls the Node.js `bs58` library from inside Solidity tests to verify that `CIDLib.toCID(tokenId)` produces a string that decodes back to exactly `tokenId` — for 50 random `uint256` values per run.

## Roadmap

- [ ] ERC/EIP draft — standardize `tokenId-as-CID` as an ERC extension for ERC-721 and ERC-1155

## License

MIT
