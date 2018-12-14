inline uint64_t pubkey_to_address(const uchar *pubkey) {
	uchar hash[32];
	u32 inDataAlignedTo64Bytes[8] = { 0 };
	sha256_ctx_t hasher;
	sha256_init (&hasher);
	to_32bytes_sha2_input(inDataAlignedTo64Bytes, pubkey);
	sha256_update (&hasher, inDataAlignedTo64Bytes, 32);
	sha256_final (&hasher);
	from_sha256_result(hash, hasher.h);

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
