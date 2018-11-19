inline uint64_t pubkey_to_address(const uchar pubkey[32]) {
	uchar hash[32];
	SHA256_CTX hasher;
	SHA256_Init(&hasher);
	SHA256_Update(&hasher, pubkey, 32);
	SHA256_Final(hash, &hasher);
	// First eight bytes little endian
	uint64_t out = 0
        | ((uint64_t) hash[7] << 7*8)
        | ((uint64_t) hash[6] << 6*8)
        | ((uint64_t) hash[5] << 5*8)
        | ((uint64_t) hash[4] << 4*8)
        | ((uint64_t) hash[3] << 3*8)
        | ((uint64_t) hash[2] << 2*8)
        | ((uint64_t) hash[1] << 1*8)
        | ((uint64_t) hash[0] << 0*8);
	return out;
}

__kernel void generate_pubkey(
	__global uchar *result,
	__global uchar *key_root,
	uchar prefix_len,
	uchar generate_key_type,
	__global uchar *public_offset
) {
	size_t const thread_id = get_global_id(0);
	uchar key_material[32];
	for (size_t i = 0; i < 32; i++) {
		key_material[i] = key_root[i];
	}
	*((size_t *) key_material) += thread_id;
	uchar *key;
	if (generate_key_type == 1) {
		// seed
		uchar genkey[32];
		key = genkey;
	} else {
		// privkey or extended privkey
		key = key_material;
	}
	bignum256modm a;
	ge25519 ALIGN(16) A;
	if (generate_key_type != 2) {
		uchar hash[64];

		SHA512_CTX hasher;
		SHA512_Init(&hasher);
		SHA512_Update(&hasher, key, 32);
		SHA512_Final(hash, &hasher);

		hash[0] &= 248;
		hash[31] &= 127;
		hash[31] |= 64;
		expand256_modm(a, hash, 32);
	} else {
		expand256_modm(a, key, 32);
	}
	ge25519_scalarmult_base_niels(&A, a);
	if (generate_key_type == 2) {
		uchar public_offset_copy[32];
		for (size_t i = 0; i < 32; i++) {
			public_offset_copy[i] = public_offset[i];
		}
		ge25519 ALIGN(16) public_offset_curvepoint;
		ge25519_unpack_vartime(&public_offset_curvepoint, public_offset_copy);
		ge25519_add(&A, &A, &public_offset_curvepoint);
	}
	uchar pubkey[32];
	ge25519_pack(pubkey, &A);

	uint64_t address = pubkey_to_address(pubkey);

	if (address <= 999999999999999ul) {
		for (uchar i = 0; i < 32; i++) {
			result[i] = key_material[i];
		}
	}
}
