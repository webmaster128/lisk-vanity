inline u32 read_four_bytes(const uchar *start) {
	return 0
        | (((u32) start[0]) << 3*8)
        | (((u32) start[1]) << 2*8)
        | (((u32) start[2]) << 1*8)
        | (((u32) start[3]) << 0*8);
}

inline void to_32bytes_sha2_input(u32 *out, const uchar *in) {
	out[0] = read_four_bytes(in +  0);
	out[1] = read_four_bytes(in +  4);
	out[2] = read_four_bytes(in +  8);
	out[3] = read_four_bytes(in + 12);
	out[4] = read_four_bytes(in + 16);
	out[5] = read_four_bytes(in + 20);
	out[6] = read_four_bytes(in + 24);
	out[7] = read_four_bytes(in + 28);
}

inline void to_16bytes_sha2_input(u32 *out, const uchar *in) {
	out[0] = read_four_bytes(in +  0);
	out[1] = read_four_bytes(in +  4);
	out[2] = read_four_bytes(in +  8);
	out[3] = read_four_bytes(in + 12);
}

inline void to_bytes_sha2_input(u32 *out, const uchar *in, size_t len) {
	for (size_t i = 0; i < len; ++i) {
		size_t word = i / 4;
		size_t index_in_word = i % 4;
		out[word] |= in[i] << ((3 - index_in_word) * 8);
	}
}

inline void to_bytes_sha2_input_c(u32 *out, const __constant uchar *in, size_t len) {
	for (size_t i = 0; i < len; ++i) {
		size_t word = i / 4;
		size_t index_in_word = i % 4;
		out[word] |= in[i] << ((3 - index_in_word) * 8);
	}
}

inline void from_sha256_result(uchar *out, const u32 *in) {
	out[ 0] = (in[0] >> (3*8)) & 0xff;
	out[ 1] = (in[0] >> (2*8)) & 0xff;
	out[ 2] = (in[0] >> (1*8)) & 0xff;
	out[ 3] = (in[0] >> (0*8)) & 0xff;
	out[ 4] = (in[1] >> (3*8)) & 0xff;
	out[ 5] = (in[1] >> (2*8)) & 0xff;
	out[ 6] = (in[1] >> (1*8)) & 0xff;
	out[ 7] = (in[1] >> (0*8)) & 0xff;
	out[ 8] = (in[2] >> (3*8)) & 0xff;
	out[ 9] = (in[2] >> (2*8)) & 0xff;
	out[10] = (in[2] >> (1*8)) & 0xff;
	out[11] = (in[2] >> (0*8)) & 0xff;
	out[12] = (in[3] >> (3*8)) & 0xff;
	out[13] = (in[3] >> (2*8)) & 0xff;
	out[14] = (in[3] >> (1*8)) & 0xff;
	out[15] = (in[3] >> (0*8)) & 0xff;
	out[16] = (in[4] >> (3*8)) & 0xff;
	out[17] = (in[4] >> (2*8)) & 0xff;
	out[18] = (in[4] >> (1*8)) & 0xff;
	out[19] = (in[4] >> (0*8)) & 0xff;
	out[20] = (in[5] >> (3*8)) & 0xff;
	out[21] = (in[5] >> (2*8)) & 0xff;
	out[22] = (in[5] >> (1*8)) & 0xff;
	out[23] = (in[5] >> (0*8)) & 0xff;
	out[24] = (in[6] >> (3*8)) & 0xff;
	out[25] = (in[6] >> (2*8)) & 0xff;
	out[26] = (in[6] >> (1*8)) & 0xff;
	out[27] = (in[6] >> (0*8)) & 0xff;
	out[28] = (in[7] >> (3*8)) & 0xff;
	out[29] = (in[7] >> (2*8)) & 0xff;
	out[30] = (in[7] >> (1*8)) & 0xff;
	out[31] = (in[7] >> (0*8)) & 0xff;
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
