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

__kernel void generate_pubkey(
	__global uchar *result,
	__constant uchar *key_root,
	ulong max_address_value,
	uchar generate_key_type
) {
	uchar key_material[32];
	for (size_t i = 0; i < 32; i++) {
		key_material[i] = key_root[i];
	}

	uint64_t const thread_id = get_global_id(0);
	key_material[16] ^= (thread_id >> (7*8)) & 0xFF;
	key_material[17] ^= (thread_id >> (6*8)) & 0xFF;
	key_material[18] ^= (thread_id >> (5*8)) & 0xFF;
	key_material[19] ^= (thread_id >> (4*8)) & 0xFF;
	key_material[20] ^= (thread_id >> (3*8)) & 0xFF;
	key_material[21] ^= (thread_id >> (2*8)) & 0xFF;
	key_material[22] ^= (thread_id >> (1*8)) & 0xFF;
	key_material[23] ^= (thread_id >> (0*8)) & 0xFF;

	//uchar menomic_hash[32];
	uchar *key;
	// if (generate_key_type == 0) {
		// lisk passphrase
		//bip39_entropy_to_mnemonic(key_material+16, menomic_hash);
		//key = menomic_hash;
	//} else {
		// privkey or extended privkey
		key = key_material;
	//}
	bignum256modm a;
	ge25519 ALIGN(16) A;
	if (generate_key_type != 2) {
		u32 in[32] = { 0 };
		uchar hash[64];

		sha512_ctx_t hasher;
		sha512_init (&hasher);

		to_32bytes_sha2_input(in, key);
		// print_bytes(in_data, 32);
		// print_words(in, 8);
		sha512_update (&hasher, in, 32);

		sha512_final (&hasher);
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
