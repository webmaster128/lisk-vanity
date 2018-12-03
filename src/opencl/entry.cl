/*
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
*/

inline void print_bytes(const uchar *data, size_t len) {
	for (size_t i = 0; i < len; ++i) {
		printf("%.2x", data[i]);
	}
	printf("\n");
}

inline void print_words(const u32 *data, size_t len) {
	for (size_t i = 0; i < len; ++i) {
		printf("%.8x ", data[i]);
	}
	printf("\n");
}

inline u32 read_four_bytes(const uchar *start) {
	return 0
        | (((u32) start[0]) << 3*8)
        | (((u32) start[1]) << 2*8)
        | (((u32) start[2]) << 1*8)
        | (((u32) start[3]) << 0*8);
}

inline void to_32bytes_sha512_input(u32 *out, const uchar *in) {
	out[0] = read_four_bytes(in +  0);
	out[1] = read_four_bytes(in +  4);
	out[2] = read_four_bytes(in +  8);
	out[3] = read_four_bytes(in + 12);
	out[4] = read_four_bytes(in + 16);
	out[5] = read_four_bytes(in + 20);
	out[6] = read_four_bytes(in + 24);
	out[7] = read_four_bytes(in + 28);
}

inline void from_sha512_result(uchar *out, const u64 *in) {
	out[ 0] = (h32_from_64_S (in[0]) >> (3*8)) & 0xff;
	out[ 1] = (h32_from_64_S (in[0]) >> (2*8)) & 0xff;
	out[ 2] = (h32_from_64_S (in[0]) >> (1*8)) & 0xff;
	out[ 3] = (h32_from_64_S (in[0]) >> (0*8)) & 0xff;
	out[ 4] = (l32_from_64_S (in[0]) >> (3*8)) & 0xff;
	out[ 5] = (l32_from_64_S (in[0]) >> (2*8)) & 0xff;
	out[ 6] = (l32_from_64_S (in[0]) >> (1*8)) & 0xff;
	out[ 7] = (l32_from_64_S (in[0]) >> (0*8)) & 0xff;

	out[ 8] = (h32_from_64_S (in[1]) >> (3*8)) & 0xff;
	out[ 9] = (h32_from_64_S (in[1]) >> (2*8)) & 0xff;
	out[10] = (h32_from_64_S (in[1]) >> (1*8)) & 0xff;
	out[11] = (h32_from_64_S (in[1]) >> (0*8)) & 0xff;
	out[12] = (l32_from_64_S (in[1]) >> (3*8)) & 0xff;
	out[13] = (l32_from_64_S (in[1]) >> (2*8)) & 0xff;
	out[14] = (l32_from_64_S (in[1]) >> (1*8)) & 0xff;
	out[15] = (l32_from_64_S (in[1]) >> (0*8)) & 0xff;

	out[16] = (h32_from_64_S (in[2]) >> (3*8)) & 0xff;
	out[17] = (h32_from_64_S (in[2]) >> (2*8)) & 0xff;
	out[18] = (h32_from_64_S (in[2]) >> (1*8)) & 0xff;
	out[19] = (h32_from_64_S (in[2]) >> (0*8)) & 0xff;
	out[20] = (l32_from_64_S (in[2]) >> (3*8)) & 0xff;
	out[21] = (l32_from_64_S (in[2]) >> (2*8)) & 0xff;
	out[22] = (l32_from_64_S (in[2]) >> (1*8)) & 0xff;
	out[23] = (l32_from_64_S (in[2]) >> (0*8)) & 0xff;

	out[24] = (h32_from_64_S (in[3]) >> (3*8)) & 0xff;
	out[25] = (h32_from_64_S (in[3]) >> (2*8)) & 0xff;
	out[26] = (h32_from_64_S (in[3]) >> (1*8)) & 0xff;
	out[27] = (h32_from_64_S (in[3]) >> (0*8)) & 0xff;
	out[28] = (l32_from_64_S (in[3]) >> (3*8)) & 0xff;
	out[29] = (l32_from_64_S (in[3]) >> (2*8)) & 0xff;
	out[30] = (l32_from_64_S (in[3]) >> (1*8)) & 0xff;
	out[31] = (l32_from_64_S (in[3]) >> (0*8)) & 0xff;

	out[32] = (h32_from_64_S (in[4]) >> (3*8)) & 0xff;
	out[33] = (h32_from_64_S (in[4]) >> (2*8)) & 0xff;
	out[34] = (h32_from_64_S (in[4]) >> (1*8)) & 0xff;
	out[35] = (h32_from_64_S (in[4]) >> (0*8)) & 0xff;
	out[36] = (l32_from_64_S (in[4]) >> (3*8)) & 0xff;
	out[37] = (l32_from_64_S (in[4]) >> (2*8)) & 0xff;
	out[38] = (l32_from_64_S (in[4]) >> (1*8)) & 0xff;
	out[39] = (l32_from_64_S (in[4]) >> (0*8)) & 0xff;

	out[40] = (h32_from_64_S (in[5]) >> (3*8)) & 0xff;
	out[41] = (h32_from_64_S (in[5]) >> (2*8)) & 0xff;
	out[42] = (h32_from_64_S (in[5]) >> (1*8)) & 0xff;
	out[43] = (h32_from_64_S (in[5]) >> (0*8)) & 0xff;
	out[44] = (l32_from_64_S (in[5]) >> (3*8)) & 0xff;
	out[45] = (l32_from_64_S (in[5]) >> (2*8)) & 0xff;
	out[46] = (l32_from_64_S (in[5]) >> (1*8)) & 0xff;
	out[47] = (l32_from_64_S (in[5]) >> (0*8)) & 0xff;

	out[48] = (h32_from_64_S (in[6]) >> (3*8)) & 0xff;
	out[49] = (h32_from_64_S (in[6]) >> (2*8)) & 0xff;
	out[50] = (h32_from_64_S (in[6]) >> (1*8)) & 0xff;
	out[51] = (h32_from_64_S (in[6]) >> (0*8)) & 0xff;
	out[52] = (l32_from_64_S (in[6]) >> (3*8)) & 0xff;
	out[53] = (l32_from_64_S (in[6]) >> (2*8)) & 0xff;
	out[54] = (l32_from_64_S (in[6]) >> (1*8)) & 0xff;
	out[55] = (l32_from_64_S (in[6]) >> (0*8)) & 0xff;

	out[56] = (h32_from_64_S (in[7]) >> (3*8)) & 0xff;
	out[57] = (h32_from_64_S (in[7]) >> (2*8)) & 0xff;
	out[58] = (h32_from_64_S (in[7]) >> (1*8)) & 0xff;
	out[59] = (h32_from_64_S (in[7]) >> (0*8)) & 0xff;
	out[60] = (l32_from_64_S (in[7]) >> (3*8)) & 0xff;
	out[61] = (l32_from_64_S (in[7]) >> (2*8)) & 0xff;
	out[62] = (l32_from_64_S (in[7]) >> (1*8)) & 0xff;
	out[63] = (l32_from_64_S (in[7]) >> (0*8)) & 0xff;
}

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

	uchar menomic_hash[32];
	uchar *key;
	if (generate_key_type == 0) {
		// lisk passphrase
		// bip39_entropy_to_mnemonic(key_material+16, menomic_hash);
		key = menomic_hash;
	} else {
		// privkey or extended privkey
		key = key_material;
	}
	bignum256modm a;
	ge25519 ALIGN(16) A;
	if (generate_key_type != 2) {
		uchar in_data[32] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		u32 in[8];
		uchar hash[64];

		sha512_ctx_t hasher;
		sha512_init (&hasher);

		to_32bytes_sha512_input(in, in_data);
		// print_bytes(in_data, 32);
		print_words(in, 8);
		sha512_update (&hasher, in, 32);

		sha512_final (&hasher);
		from_sha512_result(hash, hasher.h);

		print_bytes(hash, 64);

		// hash[0] &= 248;
		// hash[31] &= 127;
		// hash[31] |= 64;
		expand256_modm(a, hash, 32);
	} else {
		expand256_modm(a, key, 32);
	}
	ge25519_scalarmult_base_niels(&A, a);

	uchar pubkey[32];
	ge25519_pack(pubkey, &A);

	uint64_t address = 0xfffffffffffffffful; //pubkey_to_address(pubkey);

	if (address <= max_address_value) {
		for (uchar i = 0; i < 32; i++) {
			result[i] = key_material[i];
		}
	}
}
