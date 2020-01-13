// inline void print_bytes(const uchar *data, size_t len) {
// 	for (size_t i = 0; i < len; ++i) {
// 		printf("%.2x", data[i]);
// 	}
// 	printf("\n");
// }

// inline void print_words(const u32 *data, size_t len) {
// 	for (size_t i = 0; i < len; ++i) {
// 		printf("%.8x ", data[i]);
// 	}
// 	printf("\n");
// }

/**
 * result:
 *     The 32 byte key material that is written once a matching address was found.
 *     This is all zero by default and any non-zero result indicates a match. All local
 *     threads write to the same global memory, so we can get corrupted results if
 *     multiple threads find a match. This usually does not happen for hard enough
 *     tasks but we need to double check the result in the caller code for this reason.
 * key_material_base:
 *     The root input key material. This is 32 bytes from a cryptographically secure
 *     random number generator. The thread ID is XORed into the last 8 bytes of this.
 * max_address_value:
 *     The largest address value that is considered a match, e.g. 999999999999 when
 *     looking for 12 digit addresses.
 * generate_key_type:
 *     0 means Lisk passphrase encoded as 16 bytes of BIP39 entropy
 *     1 means Ed25519 private key (seed) encoded as 32 bytes
 *     2 means The curve point of the blinding factor (currently unsupported; see https://github.com/PlasmaPower/nano-vanity for proper usage)
 */
__kernel void generate_pubkey(
	__global uchar *result,
	__constant uchar *key_material_base,
	uint64_t max_address_value,
	uchar generate_key_type
) {
	uchar key_material[32];
	for (size_t i = 0; i < 32; i++) {
		key_material[i] = key_material_base[i];
	}

	uint64_t const thread_id = get_global_id(0);
	// For passphrases in key_material, the first 16 bytes are ignored.
	// We XOR the big endian encoded thread ID into the last 8 bytes.
	key_material[31-7] ^= (thread_id >> (7*8)) & 0xFF;
	key_material[31-6] ^= (thread_id >> (6*8)) & 0xFF;
	key_material[31-5] ^= (thread_id >> (5*8)) & 0xFF;
	key_material[31-4] ^= (thread_id >> (4*8)) & 0xFF;
	key_material[31-3] ^= (thread_id >> (3*8)) & 0xFF;
	key_material[31-2] ^= (thread_id >> (2*8)) & 0xFF;
	key_material[31-1] ^= (thread_id >> (1*8)) & 0xFF;
	key_material[31-0] ^= (thread_id >> (0*8)) & 0xFF;

	uchar menomic_hash[32];
	uchar *key;
	if (generate_key_type == 0) {
		// lisk passphrase
		bip39_entropy_to_mnemonic(key_material+16, menomic_hash);
		key = menomic_hash;
	} else {
		// privkey or extended privkey
		key = key_material;
	}
	bignum256modm a;
	ge25519 ALIGN(16) A;
	if (generate_key_type != 2) {
		u32 in[32] = { 0 }; // must be 128 bytes zero-filled for sha512_update to work
		uchar hash[64];

		sha512_ctx_t hasher;
		sha512_init (&hasher);

		to_32bytes_sha2_input(in, key);
		// print_bytes(in_data, 32);
		// print_words(in, 8);
		sha512_update(&hasher, in, 32);

		sha512_final(&hasher);
		from_sha512_result(hash, hasher.h);

		// printf("(%i) ", hasher.len);
		// print_bytes(hash, 64);

		hash[0] &= 248;
		hash[31] &= 127;
		hash[31] |= 64;
		expand256_modm(a, hash, 32);
	} else {
		expand256_modm(a, key, 32);
	}
	ge25519_scalarmult_base_niels(&A, a);

	uchar pubkey[32];
	ge25519_pack(pubkey, &A);

	uint64_t address = pubkey_to_address(pubkey);

	if (address <= max_address_value) {
		for (uchar i = 0; i < 32; i++) {
			result[i] = key_material[i];
		}
	}
}
