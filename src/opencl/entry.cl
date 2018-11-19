inline uint64_t pubkey_to_address (const uchar pubkey[32]) {
	// For some reason, this doesn't work when put in generate_pubkey.
	// https://github.com/prolina-foundation/snapshot-validator/blob/master/lib/lisk.cpp#L12
	uint64_t out = 0
        | ((uint64_t) pubkey[0] << 7*8)
        | ((uint64_t) pubkey[1] << 6*8)
        | ((uint64_t) pubkey[2] << 5*8)
        | ((uint64_t) pubkey[3] << 4*8)
        | ((uint64_t) pubkey[4] << 3*8)
        | ((uint64_t) pubkey[5] << 2*8)
        | ((uint64_t) pubkey[6] << 1*8)
        | ((uint64_t) pubkey[7] << 0*8);
	return out;
}

__kernel void generate_pubkey (__global uchar *result, __global uchar *key_root, __global uchar *pub_req, __global uchar *pub_mask, uchar prefix_len, uchar generate_key_type, __global uchar *public_offset) {
	int const thread = get_global_id (0);
	uchar key_material[32];
	for (size_t i = 0; i < 32; i++) {
		key_material[i] = key_root[i];
	}
	*((size_t *) key_material) += thread;
	uchar *key;
	if (generate_key_type == 1) {
		// seed
		uchar genkey[32];
		blake2b_state keystate;
		blake2b_init (&keystate, sizeof (genkey));
		blake2b_update (&keystate, key_material, sizeof (key_material));
		uint idx = 0;
		blake2b_update (&keystate, (uchar *) &idx, 4);
		blake2b_final (&keystate, genkey, sizeof (genkey));
		key = genkey;
	} else {
		// privkey or extended privkey
		key = key_material;
	}
	bignum256modm a;
	ge25519 ALIGN(16) A;
	if (generate_key_type != 2) {
		uchar hash[64];
		sha512(key, 32, hash, 0);
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
	uchar pubkey_prefix_len = prefix_len;
	if (pubkey_prefix_len > 32) {
		pubkey_prefix_len = 32;
	}
	for (uchar i = 0; i < pubkey_prefix_len; i++) {
		if ((pubkey[i] & pub_mask[i]) != pub_req[i]) {
			return;
		}
	}
	for (uchar i = 0; i < 32; i++) {
		result[i] = key_material[i];
	}
}
