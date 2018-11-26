inline uint64_t pubkey_to_address(const uchar *pubkey) {
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

inline uint64_t* eight_bytes_from(const uchar *data, uint offset) {
	return (uint64_t*) (data + offset);
}

__kernel void generate_pubkey(
	__global uchar *result,
	__global uchar *key_root,
	ulong max_address_value,
	uchar generate_key_type
) {
	uint64_t const thread_id = get_global_id(0);
	uchar key_material[32];
	for (size_t i = 0; i < 32; i++) {
		key_material[i] = key_root[i];
	}
	// manipulate the first 8 bytes in the right half of the data
	*eight_bytes_from(key_material, 16) ^= thread_id;

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

	uchar pubkey[32];
	ge25519_pack(pubkey, &A);

	uint64_t address = pubkey_to_address(pubkey);

	if (address <= max_address_value) {
		for (uchar i = 0; i < 32; i++) {
			result[i] = key_material[i];
		}
	}
}
