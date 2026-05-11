#!/usr/bin/env node
// FFI helper for Foundry: decodes a CIDv0 string back to its uint256 hash.
// Usage: node test/ffi/decode-cid.js <CIDv0>
// Output: 0x<64-char hex> (the 32-byte SHA-256 hash, big-endian)
// Foundry reads the 0x-prefixed output as raw bytes for assertEq comparison.

import bs58 from 'bs58';

const cid = process.argv[2];
if (!cid) {
    process.stderr.write('Usage: node decode-cid.js <CIDv0>\n');
    process.exit(1);
}

const decoded = bs58.decode(cid);   // 34 bytes: [0x12, 0x20, ...32-byte hash...]
const hash = decoded.slice(2);      // strip multihash prefix (0x12 = sha2-256, 0x20 = 32 bytes)
process.stdout.write('0x' + Buffer.from(hash).toString('hex'));
