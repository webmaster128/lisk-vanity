/*
(
    echo "// Snippet from inc_hash_functions.cl"
    curl -sS https://raw.githubusercontent.com/hashcat/hashcat/master/OpenCL/inc_hash_functions.cl \
        | awk 'BEGIN{ good=0}  /define SHA512_S0_S/{good=2}  /ifdef IS_NV/{good-=1}  {if (good > 0) print }'

    echo "// Snippet from inc_hash_constants.h"
    curl -sS https://raw.githubusercontent.com/hashcat/hashcat/master/OpenCL/inc_hash_constants.h \
        | awk 'BEGIN{ good=0}  /typedef enum sha2_64_constants/{good=1}  /typedef enum ripemd160_constants/{good=0}  {if (good) print }'

    echo "// Snippet from inc_hash_sha512.cl"
    curl -sS https://raw.githubusercontent.com/hashcat/hashcat/master/OpenCL/inc_hash_sha512.cl \
        | awk 'BEGIN{ before_border=1} /\/\/ sha512_hmac/{before_border=0}  {if (before_border) print }'
) >> sha512.cl
*/
// Snippet from inc_hash_functions.cl
#define SHA512_S0_S(x) (rotr64_S ((x), 28) ^ rotr64_S ((x), 34) ^ rotr64_S ((x), 39))
#define SHA512_S1_S(x) (rotr64_S ((x), 14) ^ rotr64_S ((x), 18) ^ rotr64_S ((x), 41))
#define SHA512_S2_S(x) (rotr64_S ((x),  1) ^ rotr64_S ((x),  8) ^ SHIFT_RIGHT_64 ((x), 7))
#define SHA512_S3_S(x) (rotr64_S ((x), 19) ^ rotr64_S ((x), 61) ^ SHIFT_RIGHT_64 ((x), 6))

#define SHA512_S0(x) (rotr64 ((x), 28) ^ rotr64 ((x), 34) ^ rotr64 ((x), 39))
#define SHA512_S1(x) (rotr64 ((x), 14) ^ rotr64 ((x), 18) ^ rotr64 ((x), 41))
#define SHA512_S2(x) (rotr64 ((x),  1) ^ rotr64 ((x),  8) ^ SHIFT_RIGHT_64 ((x), 7))
#define SHA512_S3(x) (rotr64 ((x), 19) ^ rotr64 ((x), 61) ^ SHIFT_RIGHT_64 ((x), 6))

#define SHA512_F0(x,y,z) ((z) ^ ((x) & ((y) ^ (z))))
#define SHA512_F1(x,y,z) (((x) & (y)) | ((z) & ((x) ^ (y))))

#ifdef IS_NV
#define SHA512_F0o(x,y,z) (bitselect ((z), (y), (x)))
#define SHA512_F1o(x,y,z) (bitselect ((x), (y), ((x) ^ (z))))
#endif

#ifdef IS_AMD
#define SHA512_F0o(x,y,z) (bitselect ((z), (y), (x)))
#define SHA512_F1o(x,y,z) (bitselect ((x), (y), ((x) ^ (z))))
#endif

#ifdef IS_GENERIC
#define SHA512_F0o(x,y,z) (SHA512_F0 ((x), (y), (z)))
#define SHA512_F1o(x,y,z) (SHA512_F1 ((x), (y), (z)))
#endif

#define SHA512_STEP_S(F0,F1,a,b,c,d,e,f,g,h,x,K)  \
{                                                 \
  h += K;                                         \
  h += x;                                         \
  h += SHA512_S1_S (e);                           \
  h += F0 (e, f, g);                              \
  d += h;                                         \
  h += SHA512_S0_S (a);                           \
  h += F1 (a, b, c);                              \
}

#define SHA512_EXPAND_S(x,y,z,w) (SHA512_S3_S (x) + y + SHA512_S2_S (z) + w)

#define SHA512_STEP(F0,F1,a,b,c,d,e,f,g,h,x,K)  \
{                                               \
  h += K;                                       \
  h += x;                                       \
  h += SHA512_S1 (e);                           \
  h += F0 (e, f, g);                            \
  d += h;                                       \
  h += SHA512_S0 (a);                           \
  h += F1 (a, b, c);                            \
}

#define SHA512_EXPAND(x,y,z,w) (SHA512_S3 (x) + y + SHA512_S2 (z) + w)

// Snippet from inc_hash_constants.h
typedef enum sha2_64_constants
{
  // SHA-384 Initial Hash Values
  SHA384M_A=0xcbbb9d5dc1059ed8,
  SHA384M_B=0x629a292a367cd507,
  SHA384M_C=0x9159015a3070dd17,
  SHA384M_D=0x152fecd8f70e5939,
  SHA384M_E=0x67332667ffc00b31,
  SHA384M_F=0x8eb44a8768581511,
  SHA384M_G=0xdb0c2e0d64f98fa7,
  SHA384M_H=0x47b5481dbefa4fa4,

  // SHA-512 Initial Hash Values
  SHA512M_A=0x6a09e667f3bcc908,
  SHA512M_B=0xbb67ae8584caa73b,
  SHA512M_C=0x3c6ef372fe94f82b,
  SHA512M_D=0xa54ff53a5f1d36f1,
  SHA512M_E=0x510e527fade682d1,
  SHA512M_F=0x9b05688c2b3e6c1f,
  SHA512M_G=0x1f83d9abfb41bd6b,
  SHA512M_H=0x5be0cd19137e2179,

  // SHA-384/512 Constants
  SHA512C00=0x428a2f98d728ae22,
  SHA512C01=0x7137449123ef65cd,
  SHA512C02=0xb5c0fbcfec4d3b2f,
  SHA512C03=0xe9b5dba58189dbbc,
  SHA512C04=0x3956c25bf348b538,
  SHA512C05=0x59f111f1b605d019,
  SHA512C06=0x923f82a4af194f9b,
  SHA512C07=0xab1c5ed5da6d8118,
  SHA512C08=0xd807aa98a3030242,
  SHA512C09=0x12835b0145706fbe,
  SHA512C0a=0x243185be4ee4b28c,
  SHA512C0b=0x550c7dc3d5ffb4e2,
  SHA512C0c=0x72be5d74f27b896f,
  SHA512C0d=0x80deb1fe3b1696b1,
  SHA512C0e=0x9bdc06a725c71235,
  SHA512C0f=0xc19bf174cf692694,
  SHA512C10=0xe49b69c19ef14ad2,
  SHA512C11=0xefbe4786384f25e3,
  SHA512C12=0x0fc19dc68b8cd5b5,
  SHA512C13=0x240ca1cc77ac9c65,
  SHA512C14=0x2de92c6f592b0275,
  SHA512C15=0x4a7484aa6ea6e483,
  SHA512C16=0x5cb0a9dcbd41fbd4,
  SHA512C17=0x76f988da831153b5,
  SHA512C18=0x983e5152ee66dfab,
  SHA512C19=0xa831c66d2db43210,
  SHA512C1a=0xb00327c898fb213f,
  SHA512C1b=0xbf597fc7beef0ee4,
  SHA512C1c=0xc6e00bf33da88fc2,
  SHA512C1d=0xd5a79147930aa725,
  SHA512C1e=0x06ca6351e003826f,
  SHA512C1f=0x142929670a0e6e70,
  SHA512C20=0x27b70a8546d22ffc,
  SHA512C21=0x2e1b21385c26c926,
  SHA512C22=0x4d2c6dfc5ac42aed,
  SHA512C23=0x53380d139d95b3df,
  SHA512C24=0x650a73548baf63de,
  SHA512C25=0x766a0abb3c77b2a8,
  SHA512C26=0x81c2c92e47edaee6,
  SHA512C27=0x92722c851482353b,
  SHA512C28=0xa2bfe8a14cf10364,
  SHA512C29=0xa81a664bbc423001,
  SHA512C2a=0xc24b8b70d0f89791,
  SHA512C2b=0xc76c51a30654be30,
  SHA512C2c=0xd192e819d6ef5218,
  SHA512C2d=0xd69906245565a910,
  SHA512C2e=0xf40e35855771202a,
  SHA512C2f=0x106aa07032bbd1b8,
  SHA512C30=0x19a4c116b8d2d0c8,
  SHA512C31=0x1e376c085141ab53,
  SHA512C32=0x2748774cdf8eeb99,
  SHA512C33=0x34b0bcb5e19b48a8,
  SHA512C34=0x391c0cb3c5c95a63,
  SHA512C35=0x4ed8aa4ae3418acb,
  SHA512C36=0x5b9cca4f7763e373,
  SHA512C37=0x682e6ff3d6b2b8a3,
  SHA512C38=0x748f82ee5defb2fc,
  SHA512C39=0x78a5636f43172f60,
  SHA512C3a=0x84c87814a1f0ab72,
  SHA512C3b=0x8cc702081a6439ec,
  SHA512C3c=0x90befffa23631e28,
  SHA512C3d=0xa4506cebde82bde9,
  SHA512C3e=0xbef9a3f7b2c67915,
  SHA512C3f=0xc67178f2e372532b,
  SHA512C40=0xca273eceea26619c,
  SHA512C41=0xd186b8c721c0c207,
  SHA512C42=0xeada7dd6cde0eb1e,
  SHA512C43=0xf57d4f7fee6ed178,
  SHA512C44=0x06f067aa72176fba,
  SHA512C45=0x0a637dc5a2c898a6,
  SHA512C46=0x113f9804bef90dae,
  SHA512C47=0x1b710b35131c471b,
  SHA512C48=0x28db77f523047d84,
  SHA512C49=0x32caab7b40c72493,
  SHA512C4a=0x3c9ebe0a15c9bebc,
  SHA512C4b=0x431d67c49c100d4c,
  SHA512C4c=0x4cc5d4becb3e42b6,
  SHA512C4d=0x597f299cfc657e2a,
  SHA512C4e=0x5fcb6fab3ad6faec,
  SHA512C4f=0x6c44198c4a475817

} sha2_64_constants_t;

// Snippet from inc_hash_sha512.cl

// important notes on this:
// input buf unused bytes needs to be set to zero
// input buf needs to be in algorithm native byte order (md5 = LE, sha1 = BE, etc)
// input buf needs to be 128 byte aligned when using sha512_update()

__constant u64a k_sha512[80] =
{
  SHA512C00, SHA512C01, SHA512C02, SHA512C03,
  SHA512C04, SHA512C05, SHA512C06, SHA512C07,
  SHA512C08, SHA512C09, SHA512C0a, SHA512C0b,
  SHA512C0c, SHA512C0d, SHA512C0e, SHA512C0f,
  SHA512C10, SHA512C11, SHA512C12, SHA512C13,
  SHA512C14, SHA512C15, SHA512C16, SHA512C17,
  SHA512C18, SHA512C19, SHA512C1a, SHA512C1b,
  SHA512C1c, SHA512C1d, SHA512C1e, SHA512C1f,
  SHA512C20, SHA512C21, SHA512C22, SHA512C23,
  SHA512C24, SHA512C25, SHA512C26, SHA512C27,
  SHA512C28, SHA512C29, SHA512C2a, SHA512C2b,
  SHA512C2c, SHA512C2d, SHA512C2e, SHA512C2f,
  SHA512C30, SHA512C31, SHA512C32, SHA512C33,
  SHA512C34, SHA512C35, SHA512C36, SHA512C37,
  SHA512C38, SHA512C39, SHA512C3a, SHA512C3b,
  SHA512C3c, SHA512C3d, SHA512C3e, SHA512C3f,
  SHA512C40, SHA512C41, SHA512C42, SHA512C43,
  SHA512C44, SHA512C45, SHA512C46, SHA512C47,
  SHA512C48, SHA512C49, SHA512C4a, SHA512C4b,
  SHA512C4c, SHA512C4d, SHA512C4e, SHA512C4f,
};

typedef struct sha512_ctx
{
  u64 h[8];

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];
  u32 w4[4];
  u32 w5[4];
  u32 w6[4];
  u32 w7[4];

  int len;

} sha512_ctx_t;

DECLSPEC void sha512_transform (const u32 *w0, const u32 *w1, const u32 *w2, const u32 *w3, const u32 *w4, const u32 *w5, const u32 *w6, const u32 *w7, u64 *digest)
{
  u64 a = digest[0];
  u64 b = digest[1];
  u64 c = digest[2];
  u64 d = digest[3];
  u64 e = digest[4];
  u64 f = digest[5];
  u64 g = digest[6];
  u64 h = digest[7];

  u64 w0_t = hl32_to_64_S (w0[0], w0[1]);
  u64 w1_t = hl32_to_64_S (w0[2], w0[3]);
  u64 w2_t = hl32_to_64_S (w1[0], w1[1]);
  u64 w3_t = hl32_to_64_S (w1[2], w1[3]);
  u64 w4_t = hl32_to_64_S (w2[0], w2[1]);
  u64 w5_t = hl32_to_64_S (w2[2], w2[3]);
  u64 w6_t = hl32_to_64_S (w3[0], w3[1]);
  u64 w7_t = hl32_to_64_S (w3[2], w3[3]);
  u64 w8_t = hl32_to_64_S (w4[0], w4[1]);
  u64 w9_t = hl32_to_64_S (w4[2], w4[3]);
  u64 wa_t = hl32_to_64_S (w5[0], w5[1]);
  u64 wb_t = hl32_to_64_S (w5[2], w5[3]);
  u64 wc_t = hl32_to_64_S (w6[0], w6[1]);
  u64 wd_t = hl32_to_64_S (w6[2], w6[3]);
  u64 we_t = hl32_to_64_S (w7[0], w7[1]);
  u64 wf_t = hl32_to_64_S (w7[2], w7[3]);

  #define ROUND_EXPAND_S()                            \
  {                                                   \
    w0_t = SHA512_EXPAND_S (we_t, w9_t, w1_t, w0_t);  \
    w1_t = SHA512_EXPAND_S (wf_t, wa_t, w2_t, w1_t);  \
    w2_t = SHA512_EXPAND_S (w0_t, wb_t, w3_t, w2_t);  \
    w3_t = SHA512_EXPAND_S (w1_t, wc_t, w4_t, w3_t);  \
    w4_t = SHA512_EXPAND_S (w2_t, wd_t, w5_t, w4_t);  \
    w5_t = SHA512_EXPAND_S (w3_t, we_t, w6_t, w5_t);  \
    w6_t = SHA512_EXPAND_S (w4_t, wf_t, w7_t, w6_t);  \
    w7_t = SHA512_EXPAND_S (w5_t, w0_t, w8_t, w7_t);  \
    w8_t = SHA512_EXPAND_S (w6_t, w1_t, w9_t, w8_t);  \
    w9_t = SHA512_EXPAND_S (w7_t, w2_t, wa_t, w9_t);  \
    wa_t = SHA512_EXPAND_S (w8_t, w3_t, wb_t, wa_t);  \
    wb_t = SHA512_EXPAND_S (w9_t, w4_t, wc_t, wb_t);  \
    wc_t = SHA512_EXPAND_S (wa_t, w5_t, wd_t, wc_t);  \
    wd_t = SHA512_EXPAND_S (wb_t, w6_t, we_t, wd_t);  \
    we_t = SHA512_EXPAND_S (wc_t, w7_t, wf_t, we_t);  \
    wf_t = SHA512_EXPAND_S (wd_t, w8_t, w0_t, wf_t);  \
  }

  #define ROUND_STEP_S(i)                                                                   \
  {                                                                                         \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, a, b, c, d, e, f, g, h, w0_t, k_sha512[i +  0]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, h, a, b, c, d, e, f, g, w1_t, k_sha512[i +  1]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, g, h, a, b, c, d, e, f, w2_t, k_sha512[i +  2]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, f, g, h, a, b, c, d, e, w3_t, k_sha512[i +  3]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, e, f, g, h, a, b, c, d, w4_t, k_sha512[i +  4]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, d, e, f, g, h, a, b, c, w5_t, k_sha512[i +  5]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, c, d, e, f, g, h, a, b, w6_t, k_sha512[i +  6]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, b, c, d, e, f, g, h, a, w7_t, k_sha512[i +  7]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, a, b, c, d, e, f, g, h, w8_t, k_sha512[i +  8]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, h, a, b, c, d, e, f, g, w9_t, k_sha512[i +  9]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, g, h, a, b, c, d, e, f, wa_t, k_sha512[i + 10]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, f, g, h, a, b, c, d, e, wb_t, k_sha512[i + 11]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, e, f, g, h, a, b, c, d, wc_t, k_sha512[i + 12]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, d, e, f, g, h, a, b, c, wd_t, k_sha512[i + 13]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, c, d, e, f, g, h, a, b, we_t, k_sha512[i + 14]); \
    SHA512_STEP_S (SHA512_F0o, SHA512_F1o, b, c, d, e, f, g, h, a, wf_t, k_sha512[i + 15]); \
  }

  ROUND_STEP_S (0);

  #ifdef _unroll
  #pragma unroll
  #endif
  for (int i = 16; i < 80; i += 16)
  {
    ROUND_EXPAND_S (); ROUND_STEP_S (i);
  }

  #undef ROUND_EXPAND_S
  #undef ROUND_STEP_S

  digest[0] += a;
  digest[1] += b;
  digest[2] += c;
  digest[3] += d;
  digest[4] += e;
  digest[5] += f;
  digest[6] += g;
  digest[7] += h;
}

DECLSPEC void sha512_init (sha512_ctx_t *ctx)
{
  ctx->h[0] = SHA512M_A;
  ctx->h[1] = SHA512M_B;
  ctx->h[2] = SHA512M_C;
  ctx->h[3] = SHA512M_D;
  ctx->h[4] = SHA512M_E;
  ctx->h[5] = SHA512M_F;
  ctx->h[6] = SHA512M_G;
  ctx->h[7] = SHA512M_H;

  ctx->w0[0] = 0;
  ctx->w0[1] = 0;
  ctx->w0[2] = 0;
  ctx->w0[3] = 0;
  ctx->w1[0] = 0;
  ctx->w1[1] = 0;
  ctx->w1[2] = 0;
  ctx->w1[3] = 0;
  ctx->w2[0] = 0;
  ctx->w2[1] = 0;
  ctx->w2[2] = 0;
  ctx->w2[3] = 0;
  ctx->w3[0] = 0;
  ctx->w3[1] = 0;
  ctx->w3[2] = 0;
  ctx->w3[3] = 0;
  ctx->w4[0] = 0;
  ctx->w4[1] = 0;
  ctx->w4[2] = 0;
  ctx->w4[3] = 0;
  ctx->w5[0] = 0;
  ctx->w5[1] = 0;
  ctx->w5[2] = 0;
  ctx->w5[3] = 0;
  ctx->w6[0] = 0;
  ctx->w6[1] = 0;
  ctx->w6[2] = 0;
  ctx->w6[3] = 0;
  ctx->w7[0] = 0;
  ctx->w7[1] = 0;
  ctx->w7[2] = 0;
  ctx->w7[3] = 0;

  ctx->len = 0;
}

DECLSPEC void sha512_update_128 (sha512_ctx_t *ctx, u32 *w0, u32 *w1, u32 *w2, u32 *w3, u32 *w4, u32 *w5, u32 *w6, u32 *w7, const int len)
{
  MAYBE_VOLATILE const int pos = ctx->len & 127;

  ctx->len += len;

  if ((pos + len) < 128)
  {
    switch_buffer_by_offset_8x4_be_S (w0, w1, w2, w3, w4, w5, w6, w7, pos);

    ctx->w0[0] |= w0[0];
    ctx->w0[1] |= w0[1];
    ctx->w0[2] |= w0[2];
    ctx->w0[3] |= w0[3];
    ctx->w1[0] |= w1[0];
    ctx->w1[1] |= w1[1];
    ctx->w1[2] |= w1[2];
    ctx->w1[3] |= w1[3];
    ctx->w2[0] |= w2[0];
    ctx->w2[1] |= w2[1];
    ctx->w2[2] |= w2[2];
    ctx->w2[3] |= w2[3];
    ctx->w3[0] |= w3[0];
    ctx->w3[1] |= w3[1];
    ctx->w3[2] |= w3[2];
    ctx->w3[3] |= w3[3];
    ctx->w4[0] |= w4[0];
    ctx->w4[1] |= w4[1];
    ctx->w4[2] |= w4[2];
    ctx->w4[3] |= w4[3];
    ctx->w5[0] |= w5[0];
    ctx->w5[1] |= w5[1];
    ctx->w5[2] |= w5[2];
    ctx->w5[3] |= w5[3];
    ctx->w6[0] |= w6[0];
    ctx->w6[1] |= w6[1];
    ctx->w6[2] |= w6[2];
    ctx->w6[3] |= w6[3];
    ctx->w7[0] |= w7[0];
    ctx->w7[1] |= w7[1];
    ctx->w7[2] |= w7[2];
    ctx->w7[3] |= w7[3];
  }
  else
  {
    u32 c0[4] = { 0 };
    u32 c1[4] = { 0 };
    u32 c2[4] = { 0 };
    u32 c3[4] = { 0 };
    u32 c4[4] = { 0 };
    u32 c5[4] = { 0 };
    u32 c6[4] = { 0 };
    u32 c7[4] = { 0 };

    switch_buffer_by_offset_8x4_carry_be_S (w0, w1, w2, w3, w4, w5, w6, w7, c0, c1, c2, c3, c4, c5, c6, c7, pos);

    ctx->w0[0] |= w0[0];
    ctx->w0[1] |= w0[1];
    ctx->w0[2] |= w0[2];
    ctx->w0[3] |= w0[3];
    ctx->w1[0] |= w1[0];
    ctx->w1[1] |= w1[1];
    ctx->w1[2] |= w1[2];
    ctx->w1[3] |= w1[3];
    ctx->w2[0] |= w2[0];
    ctx->w2[1] |= w2[1];
    ctx->w2[2] |= w2[2];
    ctx->w2[3] |= w2[3];
    ctx->w3[0] |= w3[0];
    ctx->w3[1] |= w3[1];
    ctx->w3[2] |= w3[2];
    ctx->w3[3] |= w3[3];
    ctx->w4[0] |= w4[0];
    ctx->w4[1] |= w4[1];
    ctx->w4[2] |= w4[2];
    ctx->w4[3] |= w4[3];
    ctx->w5[0] |= w5[0];
    ctx->w5[1] |= w5[1];
    ctx->w5[2] |= w5[2];
    ctx->w5[3] |= w5[3];
    ctx->w6[0] |= w6[0];
    ctx->w6[1] |= w6[1];
    ctx->w6[2] |= w6[2];
    ctx->w6[3] |= w6[3];
    ctx->w7[0] |= w7[0];
    ctx->w7[1] |= w7[1];
    ctx->w7[2] |= w7[2];
    ctx->w7[3] |= w7[3];

    sha512_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->w4, ctx->w5, ctx->w6, ctx->w7, ctx->h);

    ctx->w0[0] = c0[0];
    ctx->w0[1] = c0[1];
    ctx->w0[2] = c0[2];
    ctx->w0[3] = c0[3];
    ctx->w1[0] = c1[0];
    ctx->w1[1] = c1[1];
    ctx->w1[2] = c1[2];
    ctx->w1[3] = c1[3];
    ctx->w2[0] = c2[0];
    ctx->w2[1] = c2[1];
    ctx->w2[2] = c2[2];
    ctx->w2[3] = c2[3];
    ctx->w3[0] = c3[0];
    ctx->w3[1] = c3[1];
    ctx->w3[2] = c3[2];
    ctx->w3[3] = c3[3];
    ctx->w4[0] = c4[0];
    ctx->w4[1] = c4[1];
    ctx->w4[2] = c4[2];
    ctx->w4[3] = c4[3];
    ctx->w5[0] = c5[0];
    ctx->w5[1] = c5[1];
    ctx->w5[2] = c5[2];
    ctx->w5[3] = c5[3];
    ctx->w6[0] = c6[0];
    ctx->w6[1] = c6[1];
    ctx->w6[2] = c6[2];
    ctx->w6[3] = c6[3];
    ctx->w7[0] = c7[0];
    ctx->w7[1] = c7[1];
    ctx->w7[2] = c7[2];
    ctx->w7[3] = c7[3];
  }
}

DECLSPEC void sha512_update (sha512_ctx_t *ctx, const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];
  u32 w4[4];
  u32 w5[4];
  u32 w6[4];
  u32 w7[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 128; pos1 += 128, pos4 += 32)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];
    w4[0] = w[pos4 + 16];
    w4[1] = w[pos4 + 17];
    w4[2] = w[pos4 + 18];
    w4[3] = w[pos4 + 19];
    w5[0] = w[pos4 + 20];
    w5[1] = w[pos4 + 21];
    w5[2] = w[pos4 + 22];
    w5[3] = w[pos4 + 23];
    w6[0] = w[pos4 + 24];
    w6[1] = w[pos4 + 25];
    w6[2] = w[pos4 + 26];
    w6[3] = w[pos4 + 27];
    w7[0] = w[pos4 + 28];
    w7[1] = w[pos4 + 29];
    w7[2] = w[pos4 + 30];
    w7[3] = w[pos4 + 31];

    sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, 128);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];
  w4[0] = w[pos4 + 16];
  w4[1] = w[pos4 + 17];
  w4[2] = w[pos4 + 18];
  w4[3] = w[pos4 + 19];
  w5[0] = w[pos4 + 20];
  w5[1] = w[pos4 + 21];
  w5[2] = w[pos4 + 22];
  w5[3] = w[pos4 + 23];
  w6[0] = w[pos4 + 24];
  w6[1] = w[pos4 + 25];
  w6[2] = w[pos4 + 26];
  w6[3] = w[pos4 + 27];
  w7[0] = w[pos4 + 28];
  w7[1] = w[pos4 + 29];
  w7[2] = w[pos4 + 30];
  w7[3] = w[pos4 + 31];

  sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, len - pos1);
}

DECLSPEC void sha512_update_swap (sha512_ctx_t *ctx, const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];
  u32 w4[4];
  u32 w5[4];
  u32 w6[4];
  u32 w7[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 128; pos1 += 128, pos4 += 32)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];
    w4[0] = w[pos4 + 16];
    w4[1] = w[pos4 + 17];
    w4[2] = w[pos4 + 18];
    w4[3] = w[pos4 + 19];
    w5[0] = w[pos4 + 20];
    w5[1] = w[pos4 + 21];
    w5[2] = w[pos4 + 22];
    w5[3] = w[pos4 + 23];
    w6[0] = w[pos4 + 24];
    w6[1] = w[pos4 + 25];
    w6[2] = w[pos4 + 26];
    w6[3] = w[pos4 + 27];
    w7[0] = w[pos4 + 28];
    w7[1] = w[pos4 + 29];
    w7[2] = w[pos4 + 30];
    w7[3] = w[pos4 + 31];

    w0[0] = swap32_S (w0[0]);
    w0[1] = swap32_S (w0[1]);
    w0[2] = swap32_S (w0[2]);
    w0[3] = swap32_S (w0[3]);
    w1[0] = swap32_S (w1[0]);
    w1[1] = swap32_S (w1[1]);
    w1[2] = swap32_S (w1[2]);
    w1[3] = swap32_S (w1[3]);
    w2[0] = swap32_S (w2[0]);
    w2[1] = swap32_S (w2[1]);
    w2[2] = swap32_S (w2[2]);
    w2[3] = swap32_S (w2[3]);
    w3[0] = swap32_S (w3[0]);
    w3[1] = swap32_S (w3[1]);
    w3[2] = swap32_S (w3[2]);
    w3[3] = swap32_S (w3[3]);
    w4[0] = swap32_S (w4[0]);
    w4[1] = swap32_S (w4[1]);
    w4[2] = swap32_S (w4[2]);
    w4[3] = swap32_S (w4[3]);
    w5[0] = swap32_S (w5[0]);
    w5[1] = swap32_S (w5[1]);
    w5[2] = swap32_S (w5[2]);
    w5[3] = swap32_S (w5[3]);
    w6[0] = swap32_S (w6[0]);
    w6[1] = swap32_S (w6[1]);
    w6[2] = swap32_S (w6[2]);
    w6[3] = swap32_S (w6[3]);
    w7[0] = swap32_S (w7[0]);
    w7[1] = swap32_S (w7[1]);
    w7[2] = swap32_S (w7[2]);
    w7[3] = swap32_S (w7[3]);

    sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, 128);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];
  w4[0] = w[pos4 + 16];
  w4[1] = w[pos4 + 17];
  w4[2] = w[pos4 + 18];
  w4[3] = w[pos4 + 19];
  w5[0] = w[pos4 + 20];
  w5[1] = w[pos4 + 21];
  w5[2] = w[pos4 + 22];
  w5[3] = w[pos4 + 23];
  w6[0] = w[pos4 + 24];
  w6[1] = w[pos4 + 25];
  w6[2] = w[pos4 + 26];
  w6[3] = w[pos4 + 27];
  w7[0] = w[pos4 + 28];
  w7[1] = w[pos4 + 29];
  w7[2] = w[pos4 + 30];
  w7[3] = w[pos4 + 31];

  w0[0] = swap32_S (w0[0]);
  w0[1] = swap32_S (w0[1]);
  w0[2] = swap32_S (w0[2]);
  w0[3] = swap32_S (w0[3]);
  w1[0] = swap32_S (w1[0]);
  w1[1] = swap32_S (w1[1]);
  w1[2] = swap32_S (w1[2]);
  w1[3] = swap32_S (w1[3]);
  w2[0] = swap32_S (w2[0]);
  w2[1] = swap32_S (w2[1]);
  w2[2] = swap32_S (w2[2]);
  w2[3] = swap32_S (w2[3]);
  w3[0] = swap32_S (w3[0]);
  w3[1] = swap32_S (w3[1]);
  w3[2] = swap32_S (w3[2]);
  w3[3] = swap32_S (w3[3]);
  w4[0] = swap32_S (w4[0]);
  w4[1] = swap32_S (w4[1]);
  w4[2] = swap32_S (w4[2]);
  w4[3] = swap32_S (w4[3]);
  w5[0] = swap32_S (w5[0]);
  w5[1] = swap32_S (w5[1]);
  w5[2] = swap32_S (w5[2]);
  w5[3] = swap32_S (w5[3]);
  w6[0] = swap32_S (w6[0]);
  w6[1] = swap32_S (w6[1]);
  w6[2] = swap32_S (w6[2]);
  w6[3] = swap32_S (w6[3]);
  w7[0] = swap32_S (w7[0]);
  w7[1] = swap32_S (w7[1]);
  w7[2] = swap32_S (w7[2]);
  w7[3] = swap32_S (w7[3]);

  sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, len - pos1);
}

DECLSPEC void sha512_update_global (sha512_ctx_t *ctx, const __global u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];
  u32 w4[4];
  u32 w5[4];
  u32 w6[4];
  u32 w7[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 128; pos1 += 128, pos4 += 32)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];
    w4[0] = w[pos4 + 16];
    w4[1] = w[pos4 + 17];
    w4[2] = w[pos4 + 18];
    w4[3] = w[pos4 + 19];
    w5[0] = w[pos4 + 20];
    w5[1] = w[pos4 + 21];
    w5[2] = w[pos4 + 22];
    w5[3] = w[pos4 + 23];
    w6[0] = w[pos4 + 24];
    w6[1] = w[pos4 + 25];
    w6[2] = w[pos4 + 26];
    w6[3] = w[pos4 + 27];
    w7[0] = w[pos4 + 28];
    w7[1] = w[pos4 + 29];
    w7[2] = w[pos4 + 30];
    w7[3] = w[pos4 + 31];

    sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, 128);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];
  w4[0] = w[pos4 + 16];
  w4[1] = w[pos4 + 17];
  w4[2] = w[pos4 + 18];
  w4[3] = w[pos4 + 19];
  w5[0] = w[pos4 + 20];
  w5[1] = w[pos4 + 21];
  w5[2] = w[pos4 + 22];
  w5[3] = w[pos4 + 23];
  w6[0] = w[pos4 + 24];
  w6[1] = w[pos4 + 25];
  w6[2] = w[pos4 + 26];
  w6[3] = w[pos4 + 27];
  w7[0] = w[pos4 + 28];
  w7[1] = w[pos4 + 29];
  w7[2] = w[pos4 + 30];
  w7[3] = w[pos4 + 31];

  sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, len - pos1);
}

DECLSPEC void sha512_update_global_swap (sha512_ctx_t *ctx, const __global u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];
  u32 w4[4];
  u32 w5[4];
  u32 w6[4];
  u32 w7[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 128; pos1 += 128, pos4 += 32)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];
    w4[0] = w[pos4 + 16];
    w4[1] = w[pos4 + 17];
    w4[2] = w[pos4 + 18];
    w4[3] = w[pos4 + 19];
    w5[0] = w[pos4 + 20];
    w5[1] = w[pos4 + 21];
    w5[2] = w[pos4 + 22];
    w5[3] = w[pos4 + 23];
    w6[0] = w[pos4 + 24];
    w6[1] = w[pos4 + 25];
    w6[2] = w[pos4 + 26];
    w6[3] = w[pos4 + 27];
    w7[0] = w[pos4 + 28];
    w7[1] = w[pos4 + 29];
    w7[2] = w[pos4 + 30];
    w7[3] = w[pos4 + 31];

    w0[0] = swap32_S (w0[0]);
    w0[1] = swap32_S (w0[1]);
    w0[2] = swap32_S (w0[2]);
    w0[3] = swap32_S (w0[3]);
    w1[0] = swap32_S (w1[0]);
    w1[1] = swap32_S (w1[1]);
    w1[2] = swap32_S (w1[2]);
    w1[3] = swap32_S (w1[3]);
    w2[0] = swap32_S (w2[0]);
    w2[1] = swap32_S (w2[1]);
    w2[2] = swap32_S (w2[2]);
    w2[3] = swap32_S (w2[3]);
    w3[0] = swap32_S (w3[0]);
    w3[1] = swap32_S (w3[1]);
    w3[2] = swap32_S (w3[2]);
    w3[3] = swap32_S (w3[3]);
    w4[0] = swap32_S (w4[0]);
    w4[1] = swap32_S (w4[1]);
    w4[2] = swap32_S (w4[2]);
    w4[3] = swap32_S (w4[3]);
    w5[0] = swap32_S (w5[0]);
    w5[1] = swap32_S (w5[1]);
    w5[2] = swap32_S (w5[2]);
    w5[3] = swap32_S (w5[3]);
    w6[0] = swap32_S (w6[0]);
    w6[1] = swap32_S (w6[1]);
    w6[2] = swap32_S (w6[2]);
    w6[3] = swap32_S (w6[3]);
    w7[0] = swap32_S (w7[0]);
    w7[1] = swap32_S (w7[1]);
    w7[2] = swap32_S (w7[2]);
    w7[3] = swap32_S (w7[3]);

    sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, 128);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];
  w4[0] = w[pos4 + 16];
  w4[1] = w[pos4 + 17];
  w4[2] = w[pos4 + 18];
  w4[3] = w[pos4 + 19];
  w5[0] = w[pos4 + 20];
  w5[1] = w[pos4 + 21];
  w5[2] = w[pos4 + 22];
  w5[3] = w[pos4 + 23];
  w6[0] = w[pos4 + 24];
  w6[1] = w[pos4 + 25];
  w6[2] = w[pos4 + 26];
  w6[3] = w[pos4 + 27];
  w7[0] = w[pos4 + 28];
  w7[1] = w[pos4 + 29];
  w7[2] = w[pos4 + 30];
  w7[3] = w[pos4 + 31];

  w0[0] = swap32_S (w0[0]);
  w0[1] = swap32_S (w0[1]);
  w0[2] = swap32_S (w0[2]);
  w0[3] = swap32_S (w0[3]);
  w1[0] = swap32_S (w1[0]);
  w1[1] = swap32_S (w1[1]);
  w1[2] = swap32_S (w1[2]);
  w1[3] = swap32_S (w1[3]);
  w2[0] = swap32_S (w2[0]);
  w2[1] = swap32_S (w2[1]);
  w2[2] = swap32_S (w2[2]);
  w2[3] = swap32_S (w2[3]);
  w3[0] = swap32_S (w3[0]);
  w3[1] = swap32_S (w3[1]);
  w3[2] = swap32_S (w3[2]);
  w3[3] = swap32_S (w3[3]);
  w4[0] = swap32_S (w4[0]);
  w4[1] = swap32_S (w4[1]);
  w4[2] = swap32_S (w4[2]);
  w4[3] = swap32_S (w4[3]);
  w5[0] = swap32_S (w5[0]);
  w5[1] = swap32_S (w5[1]);
  w5[2] = swap32_S (w5[2]);
  w5[3] = swap32_S (w5[3]);
  w6[0] = swap32_S (w6[0]);
  w6[1] = swap32_S (w6[1]);
  w6[2] = swap32_S (w6[2]);
  w6[3] = swap32_S (w6[3]);
  w7[0] = swap32_S (w7[0]);
  w7[1] = swap32_S (w7[1]);
  w7[2] = swap32_S (w7[2]);
  w7[3] = swap32_S (w7[3]);

  sha512_update_128 (ctx, w0, w1, w2, w3, w4, w5, w6, w7, len - pos1);
}

DECLSPEC void sha512_final (sha512_ctx_t *ctx)
{
  MAYBE_VOLATILE const int pos = ctx->len & 127;

  append_0x80_8x4_S (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->w4, ctx->w5, ctx->w6, ctx->w7, pos ^ 3);

  if (pos >= 112)
  {
    sha512_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->w4, ctx->w5, ctx->w6, ctx->w7, ctx->h);

    ctx->w0[0] = 0;
    ctx->w0[1] = 0;
    ctx->w0[2] = 0;
    ctx->w0[3] = 0;
    ctx->w1[0] = 0;
    ctx->w1[1] = 0;
    ctx->w1[2] = 0;
    ctx->w1[3] = 0;
    ctx->w2[0] = 0;
    ctx->w2[1] = 0;
    ctx->w2[2] = 0;
    ctx->w2[3] = 0;
    ctx->w3[0] = 0;
    ctx->w3[1] = 0;
    ctx->w3[2] = 0;
    ctx->w3[3] = 0;
    ctx->w4[0] = 0;
    ctx->w4[1] = 0;
    ctx->w4[2] = 0;
    ctx->w4[3] = 0;
    ctx->w5[0] = 0;
    ctx->w5[1] = 0;
    ctx->w5[2] = 0;
    ctx->w5[3] = 0;
    ctx->w6[0] = 0;
    ctx->w6[1] = 0;
    ctx->w6[2] = 0;
    ctx->w6[3] = 0;
    ctx->w7[0] = 0;
    ctx->w7[1] = 0;
    ctx->w7[2] = 0;
    ctx->w7[3] = 0;
  }

  ctx->w7[2] = 0;
  ctx->w7[3] = ctx->len * 8;

  sha512_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->w4, ctx->w5, ctx->w6, ctx->w7, ctx->h);
}

