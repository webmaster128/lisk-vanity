/*

Generated using

(
  echo "// File: src/opencl_device_info.h"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_device_info.h
  echo "// File: src/opencl_misc.h"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_misc.h
  echo "// File: src/opencl_mask_extras.h"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_mask_extras.h
  echo "// File: src/opencl_sha2_common.h"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_sha2_common.h
  echo "// File: src/opencl_sha256.h"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_sha256.h
  echo "// File: src/opencl_rawsha256.h"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_rawsha256.h
  echo "// File: opencl/sha256_kernel.cl"
  curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl/sha256_kernel.cl
) | grep -v '#include "' > src/opencl/sha256.cl

*/

// File: src/opencl_device_info.h
/*
 * Developed by Claudio André <claudioandre.br at gmail.com> in 2012
 *
 * Copyright (c) 2012-2015 Claudio André <claudioandre.br at gmail.com>
 * This program comes with ABSOLUTELY NO WARRANTY; express or implied.
 *
 * This is free software, and you are welcome to redistribute it
 * under certain conditions; as expressed here
 * http://www.gnu.org/licenses/gpl-2.0.html
 */

#ifndef OPENCL_DEVICE_INFO_H
#define	OPENCL_DEVICE_INFO_H

//Copied from opencl_common.h
#define DEV_UNKNOWN                 0           //0
#define DEV_CPU                     (1 << 0)    //1
#define DEV_GPU                     (1 << 1)    //2
#define DEV_ACCELERATOR             (1 << 2)    //4
#define DEV_AMD                     (1 << 3)    //8
#define DEV_NVIDIA                  (1 << 4)    //16
#define DEV_INTEL                   (1 << 5)    //32
#define PLATFORM_APPLE              (1 << 6)    //64
#define DEV_AMD_GCN_10              (1 << 7)    //128
#define DEV_AMD_GCN_11              (1 << 8)    //256
#define DEV_AMD_GCN_12              (1 << 9)    //512
#define DEV_AMD_VLIW4               (1 << 12)   //4096
#define DEV_AMD_VLIW5               (1 << 13)   //8192
#define DEV_NV_C2X                  (1 << 14)   //16384
#define DEV_NV_C30                  (1 << 15)   //32768
#define DEV_NV_C32                  (1 << 16)   //65536
#define DEV_NV_C35                  (1 << 17)   //131072
#define DEV_NV_MAXWELL              (1 << 18)   //262144
#define DEV_NV_PASCAL               (1 << 19)   //524288
#define DEV_NV_VOLTA                (1 << 20)   //1M
#define DEV_USE_LOCAL               (1 << 21)   //2M
#define DEV_NO_BYTE_ADDRESSABLE     (1 << 22)   //4M
#define DEV_MESA                    (1 << 23)   //8M

#define cpu(n)                      ((n & DEV_CPU) == (DEV_CPU))
#define gpu(n)                      ((n & DEV_GPU) == (DEV_GPU))
#define gpu_amd(n)                  ((n & DEV_AMD) && gpu(n))
#define gpu_nvidia(n)               ((n & DEV_NVIDIA) && gpu(n))
#define gpu_intel(n)                ((n & DEV_INTEL) && gpu(n))
#define cpu_amd(n)                  ((n & DEV_AMD) && cpu(n))
#define cpu_intel(n)                ((n & DEV_INTEL) && cpu(n))
#define amd_gcn_10(n)               ((n & DEV_AMD_GCN_10) && gpu_amd(n))
#define amd_gcn_11(n)               ((n & DEV_AMD_GCN_11) && gpu_amd(n))
#define amd_gcn_12(n)               ((n & DEV_AMD_GCN_12) && gpu_amd(n))
#define amd_gcn(n)                  (amd_gcn_10(n) || (amd_gcn_11(n)) || amd_gcn_12(n))
#define amd_vliw4(n)                ((n & DEV_AMD_VLIW4) && gpu_amd(n))
#define amd_vliw5(n)                ((n & DEV_AMD_VLIW5) && gpu_amd(n))
#define nvidia_sm_2x(n)             ((n & DEV_NV_C2X) && gpu_nvidia(n))
#define nvidia_sm_3x(n)             (((n & DEV_NV_C30) || (n & DEV_NV_C32) || (n & DEV_NV_C35)) && gpu_nvidia(n))
#define nvidia_sm_5x(n)             ((n & DEV_NV_MAXWELL) && gpu_nvidia(n))
#define nvidia_sm_6x(n)             ((n & DEV_NV_PASCAL) && gpu_nvidia(n))
#define no_byte_addressable(n)      ((n & DEV_NO_BYTE_ADDRESSABLE))
#define use_local(n)                ((n & DEV_USE_LOCAL))

/* Only usable in host code */
#if !_OPENCL_COMPILER
#define platform_apple(p)           (get_platform_vendor_id(p) == PLATFORM_APPLE)
#endif

#endif	/* OPENCL_DEVICE_INFO_H */
// File: src/opencl_misc.h
/*
 * OpenCL common macros
 *
 * Copyright (c) 2014-2015, magnum
 * This software is hereby released to the general public under
 * the following terms: Redistribution and use in source and binary
 * forms, with or without modification, are permitted.
 *
 * NOTICE: After changes in headers, with nvidia driver you probably
 * need to drop cached kernels to ensure the changes take effect:
 *
 * rm -fr ~/.nv/ComputeCache
 *
 */

#ifndef _OPENCL_MISC_H
#define _OPENCL_MISC_H

/* Nvidia bug workaround nicked from hashcat. These are for __constant arrays */
#if gpu_nvidia(DEVICE_INFO)
#define __const_a8	__constant __attribute__ ((aligned (8)))
#else
#define __const_a8 __constant
#endif

#if SIZEOF_SIZE_T == 8
typedef uint64_t host_size_t;
#else
typedef uint32_t host_size_t;
#endif

/*
 * "Copy" of the one in dyna_salt.h (we only need it to be right size,
 * bitfields are not allowed in OpenCL)
 */
typedef struct dyna_salt_t {
	host_size_t salt_cmp_size;
	host_size_t bitfield_and_offset;
} dyna_salt;

#ifndef MIN
#define MIN(a,b) ((a)<(b)?(a):(b))
#endif
#ifndef MAX
#define MAX(a,b) ((a)>(b)?(a):(b))
#endif

/*
 * Host code may pass -DV_WIDTH=2 or some other width.
 */
#if V_WIDTH > 1
#define MAYBE_VECTOR_UINT	VECTOR(uint, V_WIDTH)
#define MAYBE_VECTOR_ULONG	VECTOR(ulong, V_WIDTH)
#else
#define MAYBE_VECTOR_UINT	uint
#define MAYBE_VECTOR_ULONG	ulong
#define SCALAR 1
#endif

#if SCALAR && 0 /* Used for testing */
#define HAVE_LUT3	1
inline uint lut3(uint x, uint y, uint z, uchar m)
{
	uint i;
	uint r = 0;
	for (i = 0; i < sizeof(uint) * 8; i++)
		r |= (uint)((m >> ( (((x >> i) & 1) << 2) |
		                    (((y >> i) & 1) << 1) |
		                     ((z >> i) & 1) )) & 1) << i;
	return r;
}
#endif

/*
 * Apparently nvidias can optimize stuff better (ending up in *better* LUT
 * use) with the basic formulas instead of bitselect ones. Most formats
 * show no difference but pwsafe does.
 */
#if !gpu_nvidia(DEVICE_INFO)
#define USE_BITSELECT 1
#endif

#if SM_MAJOR == 1
#define OLD_NVIDIA 1
#endif

#if cpu(DEVICE_INFO)
#define HAVE_ANDNOT 1
#endif

#if SCALAR && SM_MAJOR >= 5 && (DEV_VER_MAJOR > 352 || (DEV_VER_MAJOR == 352 && DEV_VER_MINOR >= 21))
#define HAVE_LUT3	1
inline uint lut3(uint a, uint b, uint c, uint imm)
{
	uint r;
	asm("lop3.b32 %0, %1, %2, %3, %4;"
	    : "=r" (r)
	    : "r" (a), "r" (b), "r" (c), "i" (imm));
	return r;
}

#if 0 /* This does no good */
#define HAVE_LUT3_64	1
inline ulong lut3_64(ulong a, ulong b, ulong c, uint imm)
{
	ulong t, r;

	asm("lop3.b32 %0, %1, %2, %3, %4;"
	    : "=r" (t)
	    : "r" ((uint)a), "r" ((uint)b), "r" ((uint)c), "i" (imm));
	r = t;
	asm("lop3.b32 %0, %1, %2, %3, %4;"
	    : "=r" (t)
	    : "r" ((uint)(a >> 32)), "r" ((uint)(b >> 32)), "r" ((uint)(c >> 32)), "i" (imm));
	return r + (t << 32);
}
#endif
#endif

#if defined cl_amd_media_ops && !__MESA__
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#define BITALIGN(hi, lo, s) amd_bitalign((hi), (lo), (s))
#elif SCALAR && SM_MAJOR > 3 || (SM_MAJOR == 3 && SM_MINOR >= 2)
inline uint funnel_shift_right(uint hi, uint lo, uint s)
{
	uint r;
	asm("shf.r.wrap.b32 %0, %1, %2, %3;"
	    : "=r" (r)
	    : "r" (lo), "r" (hi), "r" (s));
	return r;
}

inline uint funnel_shift_right_imm(uint hi, uint lo, uint s)
{
	uint r;
	asm("shf.r.wrap.b32 %0, %1, %2, %3;"
	    : "=r" (r)
	    : "r" (lo), "r" (hi), "i" (s));
	return r;
}
#define BITALIGN(hi, lo, s) funnel_shift_right(hi, lo, s)
#define BITALIGN_IMM(hi, lo, s) funnel_shift_right_imm(hi, lo, s)
#else
#define BITALIGN(hi, lo, s) (((hi) << (32 - (s))) | ((lo) >> (s)))
#endif

#ifndef BITALIGN_IMM
#define BITALIGN_IMM(hi, lo, s) BITALIGN(hi, lo, s)
#endif

#define CONCAT(TYPE,WIDTH)	TYPE ## WIDTH
#define VECTOR(x, y)		CONCAT(x, y)

/* Workaround for problem seen with 9600GT */
#ifndef MAYBE_CONSTANT
#if OLD_NVIDIA
#define MAYBE_CONSTANT	__global const
#else
#define MAYBE_CONSTANT	__constant
#endif
#endif

#if USE_BITSELECT
inline uint SWAP32(uint x)
{
	return bitselect(rotate(x, 24U), rotate(x, 8U), 0x00FF00FFU);
}

#define SWAP64(n)	bitselect( \
		bitselect(rotate(n, 24UL), \
		          rotate(n, 8UL), 0x000000FF000000FFUL), \
		bitselect(rotate(n, 56UL), \
		          rotate(n, 40UL), 0x00FF000000FF0000UL), \
		0xFFFF0000FFFF0000UL)
#else
inline uint SWAP32(uint x)
{
	x = rotate(x, 16U);
	return ((x & 0x00FF00FF) << 8) + ((x >> 8) & 0x00FF00FF);
}

// You would not believe how many driver bugs variants of this macro reveal
#define SWAP64(n)	  \
            (((n)             << 56)   | (((n) & 0xff00)     << 40) |   \
            (((n) & 0xff0000) << 24)   | (((n) & 0xff000000) << 8)  |   \
            (((n) >> 8)  & 0xff000000) | (((n) >> 24) & 0xff0000)   |   \
            (((n) >> 40) & 0xff00)     | ((n)  >> 56))
#endif

#if SCALAR
#define VSWAP32 SWAP32
#else
/* Vector-capable swap32() */
inline MAYBE_VECTOR_UINT VSWAP32(MAYBE_VECTOR_UINT x)
{
	x = rotate(x, 16U);
	return ((x & 0x00FF00FF) << 8) + ((x >> 8) & 0x00FF00FF);
}
#endif

/*
 * These macros must not require alignment of (b).
 */
#define GET_UINT32(n, b, i)	  \
	{ \
		(n) = ((uint) (b)[(i)]      ) \
			| ((uint) (b)[(i) + 1] <<  8) \
			| ((uint) (b)[(i) + 2] << 16) \
			| ((uint) (b)[(i) + 3] << 24); \
	}

#define PUT_UINT32(n, b, i)	  \
	{ \
		(b)[(i)    ] = (uchar) ((n)      ); \
		(b)[(i) + 1] = (uchar) ((n) >>  8); \
		(b)[(i) + 2] = (uchar) ((n) >> 16); \
		(b)[(i) + 3] = (uchar) ((n) >> 24); \
	}

#define GET_UINT32BE(n, b, i)	  \
	{ \
		(n) = ((uint) (b)[(i)] << 24) \
			| ((uint) (b)[(i) + 1] << 16) \
			| ((uint) (b)[(i) + 2] <<  8) \
			| ((uint) (b)[(i) + 3]      ); \
	}

#define PUT_UINT32BE(n, b, i)	  \
	{ \
		(b)[(i)    ] = (uchar) ((n) >> 24); \
		(b)[(i) + 1] = (uchar) ((n) >> 16); \
		(b)[(i) + 2] = (uchar) ((n) >>  8); \
		(b)[(i) + 3] = (uchar) ((n)      ); \
	}

#define PUT_UINT64(n, b, i)	  \
	{ \
		(b)[(i)    ] = (uchar) ((n)      ); \
		(b)[(i) + 1] = (uchar) ((ulong)(n) >>  8); \
		(b)[(i) + 2] = (uchar) ((ulong)(n) >> 16); \
		(b)[(i) + 3] = (uchar) ((ulong)(n) >> 24); \
		(b)[(i) + 4] = (uchar) ((ulong)(n) >> 32); \
		(b)[(i) + 5] = (uchar) ((ulong)(n) >> 40); \
		(b)[(i) + 6] = (uchar) ((ulong)(n) >> 48); \
		(b)[(i) + 7] = (uchar) ((ulong)(n) >> 56); \
	}

#define GET_UINT64BE(n, b, i)	  \
	{ \
		(n) = ((ulong) (b)[(i)] << 56) \
			| ((ulong) (b)[(i) + 1] << 48) \
			| ((ulong) (b)[(i) + 2] << 40) \
			| ((ulong) (b)[(i) + 3] << 32) \
			| ((ulong) (b)[(i) + 4] << 24) \
			| ((ulong) (b)[(i) + 5] << 16) \
			| ((ulong) (b)[(i) + 6] <<  8) \
			| ((ulong) (b)[(i) + 7]      ); \
	}

#define PUT_UINT64BE(n, b, i)	  \
	{ \
		(b)[(i)    ] = (uchar) ((ulong)(n) >> 56); \
		(b)[(i) + 1] = (uchar) ((ulong)(n) >> 48); \
		(b)[(i) + 2] = (uchar) ((ulong)(n) >> 40); \
		(b)[(i) + 3] = (uchar) ((ulong)(n) >> 32); \
		(b)[(i) + 4] = (uchar) ((ulong)(n) >> 24); \
		(b)[(i) + 5] = (uchar) ((ulong)(n) >> 16); \
		(b)[(i) + 6] = (uchar) ((ulong)(n) >>  8); \
		(b)[(i) + 7] = (uchar) ((n)      ); \
	}

/*
 * These require (b) to be aligned!
 */
#if __ENDIAN_LITTLE__
#define GET_UINT32_ALIGNED(n, b, i)	(n) = ((uint*)(b))[(i) >> 2]
#define PUT_UINT32_ALIGNED(n, b, i)	((uint*)(b))[(i) >> 2] = (n)
#define GET_UINT32BE_ALIGNED(n, b, i)	(n) = SWAP32(((uint*)(b))[(i) >> 2])
#define PUT_UINT32BE_ALIGNED(n, b, i)	((uint*)(b))[(i) >> 2] = SWAP32(n)
#define PUT_UINT64_ALIGNED(n, b, i)	((ulong*)(b))[(i) >> 3] = (n)
#define GET_UINT64BE_ALIGNED(n, b, i)	(n) = SWAP64(((ulong*)(b))[(i) >> 3])
#define PUT_UINT64BE_ALIGNED(n, b, i)	((ulong*)(b))[(i) >> 3] = SWAP64(n)
#else
#define GET_UINT32_ALIGNED(n, b, i)	(n) = SWAP32(((uint*)(b))[(i) >> 2])
#define PUT_UINT32_ALIGNED(n, b, i)	((uint*)(b))[(i) >> 2] = SWAP32(n)
#define GET_UINT32BE_ALIGNED(n, b, i)	(n) = ((uint*)(b))[(i) >> 2]
#define PUT_UINT32BE_ALIGNED(n, b, i)	((uint*)(b))[(i) >> 2] = (n)
#define PUT_UINT64_ALIGNED(n, b, i)	((ulong*)(b))[(i) >> 3] = SWAP64(n)
#define GET_UINT64BE_ALIGNED(n, b, i)	(n) = ((ulong*)(b))[(i) >> 3]
#define PUT_UINT64BE_ALIGNED(n, b, i)	((ulong*)(b))[(i) >> 3] = (n)
#endif

/* Any device can do 8-bit reads BUT these macros are scalar only! */
#define GETCHAR(buf, index) (((uchar*)(buf))[(index)])
#define GETCHAR_G(buf, index) (((__global uchar*)(buf))[(index)])
#define GETCHAR_L(buf, index) (((__local uchar*)(buf))[(index)])
#define GETCHAR_BE(buf, index) (((uchar*)(buf))[(index) ^ 3])
#define GETCHAR_MC(buf, index) (((MAYBE_CONSTANT uchar*)(buf))[(index)])
#define LASTCHAR_BE(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2] & (0xffffff00U << ((((index) & 3) ^ 3) << 3))) + ((val) << ((((index) & 3) ^ 3) << 3))

#if no_byte_addressable(DEVICE_INFO) || !SCALAR || (gpu_amd(DEVICE_INFO) && defined(AMD_PUTCHAR_NOCAST))
/* 32-bit stores */
#define PUTCHAR(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2] & ~(0xffU << (((index) & 3) << 3))) + ((val) << (((index) & 3) << 3))
#define PUTCHAR_G	PUTCHAR
#define PUTCHAR_L	PUTCHAR
#define PUTCHAR_BE(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2] & ~(0xffU << ((((index) & 3) ^ 3) << 3))) + ((val) << ((((index) & 3) ^ 3) << 3))
#define PUTCHAR_BE_G	PUTCHAR_BE
#define PUTSHORT(buf, index, val) (buf)[(index)>>1] = ((buf)[(index)>>1] & ~(0xffffU << (((index) & 1) << 4))) + ((val) << (((index) & 1) << 4))
#define PUTSHORT_BE(buf, index, val) (buf)[(index)>>1] = ((buf)[(index)>>1] & ~(0xffffU << ((((index) & 1) ^ 3) << 4))) + ((val) << ((((index) & 1) ^ 3) << 4))
#define XORCHAR(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2]) ^ ((val) << (((index) & 3) << 3))
#define XORCHAR_BE(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2]) ^ ((val) << ((((index) & 3) ^ 3) << 3))

#else
/* 8-bit stores */
#define PUTCHAR(buf, index, val) ((uchar*)(buf))[index] = (val)
#define PUTCHAR_G(buf, index, val) ((__global uchar*)(buf))[(index)] = (val)
#define PUTCHAR_L(buf, index, val) ((__local uchar*)(buf))[(index)] = (val)
#define PUTCHAR_BE(buf, index, val) ((uchar*)(buf))[(index) ^ 3] = (val)
#define PUTCHAR_BE_G(buf, index, val) ((__global uchar*)(buf))[(index) ^ 3] = (val)
#define PUTSHORT(buf, index, val) ((ushort*)(buf))[index] = (val)
#define PUTSHORT_BE(buf, index, val) ((ushort*)(buf))[(index) ^ 1] = (val)
#define XORCHAR(buf, index, val) ((uchar*)(buf))[(index)] ^= (val)
#define XORCHAR_BE(buf, index, val) ((uchar*)(buf))[(index) ^ 3] ^= (val)
#endif

inline int check_pkcs_pad(const uchar *data, int len, int blocksize)
{
	int pad_len, padding, real_len;

	if (len & (blocksize - 1) || len < blocksize)
		return -1;

	pad_len = data[len - 1];

	if (pad_len < 1 || pad_len > blocksize)
		return -1;

	real_len = len - pad_len;
	data += real_len;

	padding = pad_len;

	while (pad_len--)
		if (*data++ != padding)
			return -1;

	return real_len;
}

/*
 * Use with some caution. Memory type agnostic and if both src and dst are
 * 8-bit types, this works like a normal memcpy.
 *
 * If src and dst are larger but same size, it will still work fine but
 * 'count' is number of ELEMENTS and not BYTES.
 *
 * If src and dst are different size types, you will get what you asked for...
 */
#define memcpy_macro(dst, src, count) do {	  \
		uint c = count; \
		for (uint _i = 0; _i < c; _i++) \
			(dst)[_i] = (src)[_i]; \
	} while (0)

/*
 * Optimized functions. You need to pick the one that corresponds to the
 * source- and destination memory type(s).
 *
 * Note that for very small sizes, the overhead may make these functions
 * slower than naive code. On the other hand, due to inlining we will
 * hopefully have stuff optimized away more often than not!
 */

/* src and dst are private mem */
inline void memcpy_pp(void *dst, const void *src, uint count)
{
	union {
		const uint *w;
		const uchar *c;
	} s;
	union {
		uint *w;
		uchar *c;
	} d;

	s.c = src;
	d.c = dst;

	if (((size_t)dst & 0x03) == ((size_t)src & 0x03)) {
		while (((size_t)s.c) & 0x03 && count--)
			*d.c++ = *s.c++;

		while (count >= 4) {
			*d.w++ = *s.w++;
			count -= 4;
		}
	}

	while (count--) {
		*d.c++ = *s.c++;
	}
}

/* src is private mem, dst is global mem */
inline void memcpy_pg(__global void *dst, const void *src, uint count)
{
	union {
		const uint *w;
		const uchar *c;
	} s;
	union {
		__global uint *w;
		__global uchar *c;
	} d;

	s.c = src;
	d.c = dst;

	if (((size_t)dst & 0x03) == ((size_t)src & 0x03)) {
		while (((size_t)s.c) & 0x03 && count--)
			*d.c++ = *s.c++;

		while (count >= 4) {
			*d.w++ = *s.w++;
			count -= 4;
		}
	}

	while (count--) {
		*d.c++ = *s.c++;
	}
}

/* src is global mem, dst is private mem */
inline void memcpy_gp(void *dst, __global const void *src, uint count)
{
	union {
		__global const uint *w;
		__global const uchar *c;
	} s;
	union {
		uint *w;
		uchar *c;
	} d;

	s.c = src;
	d.c = dst;

	if (((size_t)dst & 0x03) == ((size_t)src & 0x03)) {
		while (((size_t)s.c) & 0x03 && count--)
			*d.c++ = *s.c++;

		while (count >= 4) {
			*d.w++ = *s.w++;
			count -= 4;
		}
	}

	while (count--) {
		*d.c++ = *s.c++;
	}
}

/* src is constant mem, dst is private mem */
inline void memcpy_cp(void *dst, __constant void *src, uint count)
{
	union {
		__constant uint *w;
		__constant uchar *c;
	} s;
	union {
		uint *w;
		uchar *c;
	} d;

	s.c = src;
	d.c = dst;

	if (((size_t)dst & 0x03) == ((size_t)src & 0x03)) {
		while (((size_t)s.c) & 0x03 && count--)
			*d.c++ = *s.c++;

		while (count >= 4) {
			*d.w++ = *s.w++;
			count -= 4;
		}
	}

	while (count--) {
		*d.c++ = *s.c++;
	}
}

/* src is MAYBE_CONSTANT mem, dst is private mem */
inline void memcpy_mcp(void *dst, MAYBE_CONSTANT void *src, uint count)
{
	union {
		MAYBE_CONSTANT uint *w;
		MAYBE_CONSTANT uchar *c;
	} s;
	union {
		uint *w;
		uchar *c;
	} d;

	s.c = src;
	d.c = dst;

	if (((size_t)dst & 0x03) == ((size_t)src & 0x03)) {
		while (((size_t)s.c) & 0x03 && count--)
			*d.c++ = *s.c++;

		while (count >= 4) {
			*d.w++ = *s.w++;
			count -= 4;
		}
	}

	while (count--) {
		*d.c++ = *s.c++;
	}
}

/* dst is private mem */
inline void memset_p(void *p, uint val, uint count)
{
	const uint val4 = val | (val << 8) | (val << 16) | (val << 24);
	union {
		uint *w;
		uchar *c;
	} d;

	d.c = p;

	while (((size_t)d.c) & 0x03 && count--)
		*d.c++ = val;

	while (count >= 4) {
		*d.w++ = val4;
		count -= 4;
	}

	while (count--)
		*d.c++ = val;
}

/* dst is global mem */
inline void memset_g(__global void *p, uint val, uint count)
{
	const uint val4 = val | (val << 8) | (val << 16) | (val << 24);
	union {
		__global uint *w;
		__global uchar *c;
	} d;

	d.c = p;

	while (((size_t)d.c) & 0x03 && count--)
		*d.c++ = val;

	while (count >= 4) {
		*d.w++ = val4;
		count -= 4;
	}

	while (count--)
		*d.c++ = val;
}

/* s1 and s2 are private mem */
inline int memcmp_pp(const void *s1, const void *s2, uint size)
{
	union {
		const uint *w;
		const uchar *c;
	} a;
	union {
		const uint *w;
		const uchar *c;
	} b;

	a.c = s1;
	b.c = s2;

	if (((size_t)s1 & 0x03) == ((size_t)s2 & 0x03)) {
		while (((size_t)a.c) & 0x03 && size--)
			if (*b.c++ != *a.c++)
				return 1;

		while (size >= 4) {
			if (*b.w++ != *a.w++)
				return 1;
			size -= 4;
		}
	}

	while (size--)
		if (*b.c++ != *a.c++)
			return 1;

	return 0;
}

/* s1 is private mem, s2 is constant mem */
inline int memcmp_pc(const void *s1, __constant const void *s2, uint size)
{
	union {
		const uint *w;
		const uchar *c;
	} a;
	union {
		__constant const uint *w;
		__constant const uchar *c;
	} b;

	a.c = s1;
	b.c = s2;

	if (((size_t)s1 & 0x03) == ((size_t)s2 & 0x03)) {
		while (((size_t)a.c) & 0x03 && size--)
			if (*b.c++ != *a.c++)
				return 1;

		while (size >= 4) {
			if (*b.w++ != *a.w++)
				return 1;
			size -= 4;
		}
	}

	while (size--)
		if (*b.c++ != *a.c++)
			return 1;

	return 0;
}

/* s1 is private mem, s2 is MAYBE_CONSTANT mem */
inline int memcmp_pmc(const void *s1, MAYBE_CONSTANT void *s2, uint size)
{
	union {
		const uint *w;
		const uchar *c;
	} a;
	union {
		MAYBE_CONSTANT uint *w;
		MAYBE_CONSTANT uchar *c;
	} b;

	a.c = s1;
	b.c = s2;

	if (((size_t)s1 & 0x03) == ((size_t)s2 & 0x03)) {
		while (((size_t)a.c) & 0x03 && size--)
			if (*b.c++ != *a.c++)
				return 1;

		while (size >= 4) {
			if (*b.w++ != *a.w++)
				return 1;
			size -= 4;
		}
	}

	while (size--)
		if (*b.c++ != *a.c++)
			return 1;

	return 0;
}

/* haystack is private mem, needle is constant mem */
inline int memmem_pc(const void *haystack, size_t haystack_len,
                     __constant const void *needle, size_t needle_len)
{
	char* haystack_ = (char*)haystack;
	__constant const char* needle_ = (__constant const char*)needle;
	int hash = 0;
	int hay_hash = 0;
	char* last;
	size_t i;

	if (haystack_len < needle_len)
		return 0;

	if (!needle_len)
		return 1;

	for (i = needle_len; i; --i) {
		hash += *needle_++;
		hay_hash += *haystack_++;
	}

	haystack_ = (char*)haystack;
	needle_ = (__constant char*)needle;
	last = haystack_+(haystack_len - needle_len + 1);
	for (; haystack_ < last; ++haystack_) {
		if (hash == hay_hash &&
		    *haystack_ == *needle_ &&
		    !memcmp_pc (haystack_, needle_, needle_len))
			return 1;

		hay_hash -= *haystack_;
		hay_hash += *(haystack_+needle_len);
	}

	return 0;
}

#define STRINGIZE2(s) #s
#define STRINGIZE(s) STRINGIZE2(s)

/*
 * The reason the functions below are macros is it's the only way we can use
 * them regardless of memory type (eg. __local or __global). The downside is
 * we can't cast them so we need eg. dump8_le for a char array, or output will
 * not be correct.
 */

/* Dump an array (or variable) as hex */
#define dump(x)   dump_stuff_msg(STRINGIZE(x), x, sizeof(x))
#define dump_stuff(x, size) dump_stuff_msg(STRINGIZE(x), x, size)

/*
 * This clumsy beast finally hides the problem from user.
 */
#define dump_stuff_msg(msg, x, size) do {	  \
		switch (sizeof((x)[0])) { \
		case 8: \
			dump_stuff64_msg(msg, x, size); \
			break; \
		case 4: \
			dump_stuff32_msg(msg, x, size); \
			break; \
		case 2: \
			dump_stuff16_msg(msg, x, size); \
			break; \
		case 1: \
			dump_stuff8_msg(msg, x, size); \
			break; \
		} \
	} while (0)

/* requires char/uchar */
#define dump_stuff8_msg(msg, x, size) do {	  \
		uint ii; \
		printf("%s : ", msg); \
		for (ii = 0; ii < (uint)size; ii++) { \
			printf("%02x", (x)[ii]); \
			if (ii % 4 == 3) \
				printf(" "); \
		} \
		printf("\n"); \
	} while (0)

/* requires short/ushort */
#define dump_stuff16_msg(msg, x, size) do {	  \
		uint ii; \
		printf("%s : ", msg); \
		for (ii = 0; ii < (uint)(size)/2; ii++) { \
			printf("%04x", (x)[ii]); \
			if (ii % 2 == 1) \
				printf(" "); \
		} \
		printf("\n"); \
	} while (0)

/* requires int/uint */
#define dump_stuff32_msg(msg, x, size) do {	  \
		uint ii; \
		printf("%s : ", msg); \
		for (ii = 0; ii < (uint)(size)/4; ii++) \
			printf("%08x ", SWAP32((x)[ii])); \
		printf("\n"); \
	} while (0)

/* requires long/ulong */
#define dump_stuff64_msg(msg, x, size) do {	  \
		uint ii; \
		printf("%s : ", msg); \
		for (ii = 0; ii < (uint)(size)/8; ii++) \
			printf("%016lx ", SWAP64((x)[ii])); \
		printf("\n"); \
	} while (0)

#endif
// File: src/opencl_mask_extras.h
/*
 * This file is part of John the Ripper password cracker.
 *
 * Common OpenCL functions go in this file.
 *
 * This software is
 * Copyright (c) 2014 by Sayantan Datta
 * Copyright (c) 2012-2016 Claudio André <claudioandre.br at gmail.com>
 * and is hereby released to the general public under the following terms:
 *    Redistribution and use in source and binary forms, with or without
 *    modifications, are permitted.
 */

#ifndef _JOHN_OPENCL_MASK_EXTRAS_H
#define _JOHN_OPENCL_MASK_EXTRAS_H

#ifdef _OPENCL_COMPILER
//To keep Sayantan license, some code was moved to this file.

#ifndef BITMAP_SIZE_MINUS1
#define BITMAP_SIZE_MINUS1 0
#endif

#define MASK_KEYS_GENERATION(id)                                    \
        uint32_t ikl = int_key_loc[get_global_id(0)];               \
        uint32_t pos = (ikl & 0xff) + W_OFFSET;                     \
        PUTCHAR(w, pos, (int_keys[id] & 0xff));                     \
                                                                    \
        pos = ((ikl & 0xff00U) >> 8) + W_OFFSET;                    \
        if ((ikl & 0xff00) != 0x8000)                               \
            PUTCHAR(w, pos, ((int_keys[id] & 0xff00U) >> 8));       \
                                                                    \
        pos = ((ikl & 0xff0000U) >> 16) + W_OFFSET;                 \
        if ((ikl & 0xff0000) != 0x800000)                           \
            PUTCHAR(w, pos, ((int_keys[id] & 0xff0000U) >> 16));    \
                                                                    \
        pos = ((ikl & 0xff000000U) >> 24) + W_OFFSET;               \
        if ((ikl & 0xff000000) != 0x80000000)                       \
            PUTCHAR(w, pos, ((int_keys[id] & 0xff000000U) >> 24));  \

#endif

#endif
// File: src/opencl_sha2_common.h
/*
 * Developed by Claudio André <claudioandre.br at gmail.com> in 2012
 *
 * Copyright (c) 2012-2015 Claudio André <claudioandre.br at gmail.com>
 * This program comes with ABSOLUTELY NO WARRANTY; express or implied.
 *
 * This is free software, and you are welcome to redistribute it
 * under certain conditions; as expressed here
 * http://www.gnu.org/licenses/gpl-2.0.html
 */

#ifndef OPENCL_SHA2_COMMON_H
#define OPENCL_SHA2_COMMON_H

// Type names definition.
// NOTE: long is always 64-bit in OpenCL, and long long is 128 bit.
#ifdef _OPENCL_COMPILER

// ** Precomputed index to position/values. **
//0:        0                   =>  1
//0: 3      14,28                   =>  2
//0: 7      6,12,18,24,30,36            =>  6
//0: 3,7    2,4,8,10,16,20,22,26,32,34,38,40    => 12
//1:        21                  =>  1
//1: 3      7,35                    =>  2
//1: 7      3,9,15,27,33,39             =>  6
//1: 3,7    1,5,11,13,17,19,23,25,29,31,37,41   => 12
__const_a8 int loop_index[] = {
	0, /* 0,000 */ 7, /* 1,111 */ 3, /* 2,011 */ 5, /* 3,101 */
	3, /* 4,011 */ 7, /* 5,111 */ 1, /* 6,001 */ 6, /* 7,110 */
	3, /* 8,011 */ 5, /* 9,101 */ 3, /*10,011 */ 7, /*11,111 */
	1, /*12,001 */ 7, /*13,111 */ 2, /*14,010 */ 5, /*15,101 */
	3, /*16,011 */ 7, /*17,111 */ 1, /*18,001 */ 7, /*19,111 */
	3, /*20,011 */ 4, /*21,100 */ 3, /*22,011 */ 7, /*23,111 */
	1, /*24,001 */ 7, /*25,111 */ 3, /*26,011 */ 5, /*27,101 */
	2, /*28,010 */ 7, /*29,111 */ 1, /*30,001 */ 7, /*31,111 */
	3, /*32,011 */ 5, /*33,101 */ 3, /*34,011 */ 6, /*35,110 */
	1, /*36,001 */ 7, /*37,111 */ 3, /*38,011 */ 5, /*39,101 */
	3, /*40,011 */ 7,           /*41,111 */
};

__const_a8 int generator_index[] = {
	0,                          /*  0, 000 */
	6,                          /*  6, 001 */
	14,                         /* 14, 010 */
	2,                          /*  2, 011 */
	21,                         /* 21, 100 */
	3,                          /*  3, 101 */
	7,                          /*  7, 110 */
	1                           /*  1, 111 */
};
#endif

#undef USE_BITSELECT            //What used in opencl_misc cannot handle all situations.
#if gpu_amd(DEVICE_INFO)        //At least, it will fail for cpu and nvidia
#define USE_BITSELECT   1
#endif

//Macros.
#ifdef USE_BITSELECT
#define Ch(x, y, z)     bitselect(z, y, x)
#define Maj(x, y, z)    bitselect(x, y, z ^ x)
#else
#if HAVE_LUT3 && BITS_32
#define Ch(x, y, z) lut3(x, y, z, 0xca)
#elif HAVE_ANDNOT
#define Ch(x, y, z) ((x & y) ^ ((~x) & z))
#else
#define Ch(x, y, z) (z ^ (x & (y ^ z)))
#endif

#if HAVE_LUT3 && BITS_32
#define Maj(x, y, z) lut3(x, y, z, 0xe8)
#else
#define Maj(x, y, z) ((x & y) | (z & (x | y)))
#endif
#endif

// Start documenting NVIDIA OpenCL bugs.
///#if gpu_nvidia(DEVICE_INFO)
///#define NVIDIA_STUPID_BUG_1    1
///#endif

// Start documenting AMD OpenCL bugs.
///#if amd_vliw5(DEVICE_INFO) || amd_vliw4(DEVICE_INFO)
///amd_vliw4() is a guess.

///Needed (at least) in 14.9 and 15.7
///TODO: can't remove the [unroll]. (At least) HD 6770.
///#ifdef AMD_STUPID_BUG_1
///  #pragma unroll 2
///#endif
///for (uint i = 16U; i < 80U; i++) {
///#define AMD_STUPID_BUG_1    1

///TODO: can't use a valid command twice on sha256crypt. (At least) HD 6770.
///Fixed (back in 14.12). Kept for future reference.
/// ----------------------
///  #define SWAP32(n)  rotate(n & 0x00FF00FF, 24U) | rotate(n & 0xFF00FF00, 8U)
///  #ifdef AMD_STUPID_BUG_2
///    #define SWAP_V(n)    bitselect(rotate(n, 24U), rotate(n, 8U), 0x00FF00FFU)
/// ----------------------
///#define AMD_STUPID_BUG_2

///TODO: can't use constant. (At least) HD 6770.
///Fixed. Kept for future reference.
/// ----------------------
///inline void sha512_prepare(__constant   sha512_salt     * salt_data,
/// ----------------------
///#define AMD_STUPID_BUG_3
///#endif

//Functions.
/* Macros for reading/writing chars from int32's (from rar_kernel.cl) */
#define ATTRIB(buf, index, val) (buf)[(index)] = val

#if no_byte_addressable(DEVICE_INFO) || (gpu_amd(DEVICE_INFO) && defined(AMD_PUTCHAR_NOCAST))
#define USE_32BITS_FOR_CHAR
#endif

#ifdef USE_32BITS_FOR_CHAR
#define PUT         PUTCHAR
#define BUFFER      ctx->buffer->mem_32
#define F_BUFFER    ctx.buffer->mem_32
#else
#define PUT         ATTRIB
#define BUFFER      ctx->buffer->mem_08
#define F_BUFFER    ctx.buffer->mem_08
#endif
#define TRANSFER_SIZE           (1024 * 64)

#define ROUND_A(A, B, C, D, E, F, G, H, ki, wi)\
    t = (ki) + (wi) + (H) + Sigma1(E) + Ch((E),(F),(G));\
    D += (t); H = (t) + Sigma0(A) + Maj((A), (B), (C));

#define ROUND_B(A, B, C, D, E, F, G, H, ki, wi, wj, wk, wl, wm)\
    wi = (wl) + (wm) + sigma1(wj) + sigma0(wk);\
    t = (ki) + (wi) + (H) + Sigma1(E) + Ch((E),(F),(G));\
    D += (t); H = (t) + Sigma0(A) + Maj((A), (B), (C));

#define SHA256_SHORT()\
    ROUND_A(a, b, c, d, e, f, g, h, k[0],  w[0])\
    ROUND_A(h, a, b, c, d, e, f, g, k[1],  w[1])\
    ROUND_A(g, h, a, b, c, d, e, f, k[2],  w[2])\
    ROUND_A(f, g, h, a, b, c, d, e, k[3],  w[3])\
    ROUND_A(e, f, g, h, a, b, c, d, k[4],  w[4])\
    ROUND_A(d, e, f, g, h, a, b, c, k[5],  w[5])\
    ROUND_A(c, d, e, f, g, h, a, b, k[6],  w[6])\
    ROUND_A(b, c, d, e, f, g, h, a, k[7],  w[7])\
    ROUND_A(a, b, c, d, e, f, g, h, k[8],  w[8])\
    ROUND_A(h, a, b, c, d, e, f, g, k[9],  w[9])\
    ROUND_A(g, h, a, b, c, d, e, f, k[10], w[10])\
    ROUND_A(f, g, h, a, b, c, d, e, k[11], w[11])\
    ROUND_A(e, f, g, h, a, b, c, d, k[12], w[12])\
    ROUND_A(d, e, f, g, h, a, b, c, k[13], w[13])\
    ROUND_A(c, d, e, f, g, h, a, b, k[14], w[14])\
    ROUND_A(b, c, d, e, f, g, h, a, k[15], w[15])\
    ROUND_B(a, b, c, d, e, f, g, h, k[16], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[17], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[18], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[19], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[20], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[21], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[22], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[23], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[24], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[25], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[26], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[27], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[28], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[29], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[30], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[31], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[32], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[33], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[34], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[35], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[36], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[37], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[38], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[39], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[40], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[41], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[42], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[43], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[44], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[45], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[46], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[47], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[48], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[49], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[50], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[51], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[52], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[53], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[54], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[55], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[56], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[57], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[58], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[59], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[60], w[12], w[10], w[13], w[12], w[5])

#define SHA256()\
    ROUND_A(a, b, c, d, e, f, g, h, k[0],  w[0])\
    ROUND_A(h, a, b, c, d, e, f, g, k[1],  w[1])\
    ROUND_A(g, h, a, b, c, d, e, f, k[2],  w[2])\
    ROUND_A(f, g, h, a, b, c, d, e, k[3],  w[3])\
    ROUND_A(e, f, g, h, a, b, c, d, k[4],  w[4])\
    ROUND_A(d, e, f, g, h, a, b, c, k[5],  w[5])\
    ROUND_A(c, d, e, f, g, h, a, b, k[6],  w[6])\
    ROUND_A(b, c, d, e, f, g, h, a, k[7],  w[7])\
    ROUND_A(a, b, c, d, e, f, g, h, k[8],  w[8])\
    ROUND_A(h, a, b, c, d, e, f, g, k[9],  w[9])\
    ROUND_A(g, h, a, b, c, d, e, f, k[10], w[10])\
    ROUND_A(f, g, h, a, b, c, d, e, k[11], w[11])\
    ROUND_A(e, f, g, h, a, b, c, d, k[12], w[12])\
    ROUND_A(d, e, f, g, h, a, b, c, k[13], w[13])\
    ROUND_A(c, d, e, f, g, h, a, b, k[14], w[14])\
    ROUND_A(b, c, d, e, f, g, h, a, k[15], w[15])\
    ROUND_B(a, b, c, d, e, f, g, h, k[16], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[17], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[18], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[19], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[20], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[21], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[22], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[23], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[24], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[25], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[26], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[27], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[28], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[29], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[30], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[31], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[32], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[33], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[34], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[35], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[36], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[37], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[38], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[39], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[40], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[41], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[42], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[43], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[44], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[45], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[46], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[47], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[48], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[49], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[50], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[51], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[52], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[53], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[54], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[55], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[56], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[57], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[58], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[59], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[60], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[61], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[62], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[63], w[15], w[13], w[0],  w[15], w[8])

#define SHA512_SHORT()\
    ROUND_A(a, b, c, d, e, f, g, h, k[0],  w[0])\
    ROUND_A(h, a, b, c, d, e, f, g, k[1],  w[1])\
    ROUND_A(g, h, a, b, c, d, e, f, k[2],  w[2])\
    ROUND_A(f, g, h, a, b, c, d, e, k[3],  w[3])\
    ROUND_A(e, f, g, h, a, b, c, d, k[4],  w[4])\
    ROUND_A(d, e, f, g, h, a, b, c, k[5],  w[5])\
    ROUND_A(c, d, e, f, g, h, a, b, k[6],  w[6])\
    ROUND_A(b, c, d, e, f, g, h, a, k[7],  w[7])\
    ROUND_A(a, b, c, d, e, f, g, h, k[8],  w[8])\
    ROUND_A(h, a, b, c, d, e, f, g, k[9],  w[9])\
    ROUND_A(g, h, a, b, c, d, e, f, k[10], w[10])\
    ROUND_A(f, g, h, a, b, c, d, e, k[11], w[11])\
    ROUND_A(e, f, g, h, a, b, c, d, k[12], w[12])\
    ROUND_A(d, e, f, g, h, a, b, c, k[13], w[13])\
    ROUND_A(c, d, e, f, g, h, a, b, k[14], w[14])\
    ROUND_A(b, c, d, e, f, g, h, a, k[15], w[15])\
    ROUND_B(a, b, c, d, e, f, g, h, k[16], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[17], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[18], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[19], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[20], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[21], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[22], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[23], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[24], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[25], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[26], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[27], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[28], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[29], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[30], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[31], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[32], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[33], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[34], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[35], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[36], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[37], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[38], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[39], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[40], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[41], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[42], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[43], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[44], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[45], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[46], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[47], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[48], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[49], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[50], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[51], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[52], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[53], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[54], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[55], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[56], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[57], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[58], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[59], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[60], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[61], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[62], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[63], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[64], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[65], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[66], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[67], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[68], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[69], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[70], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[71], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[72], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[73], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[74], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[75], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[76], w[12], w[10], w[13], w[12], w[5])

#define SHA512()\
    ROUND_A(a, b, c, d, e, f, g, h, k[0],  w[0])\
    ROUND_A(h, a, b, c, d, e, f, g, k[1],  w[1])\
    ROUND_A(g, h, a, b, c, d, e, f, k[2],  w[2])\
    ROUND_A(f, g, h, a, b, c, d, e, k[3],  w[3])\
    ROUND_A(e, f, g, h, a, b, c, d, k[4],  w[4])\
    ROUND_A(d, e, f, g, h, a, b, c, k[5],  w[5])\
    ROUND_A(c, d, e, f, g, h, a, b, k[6],  w[6])\
    ROUND_A(b, c, d, e, f, g, h, a, k[7],  w[7])\
    ROUND_A(a, b, c, d, e, f, g, h, k[8],  w[8])\
    ROUND_A(h, a, b, c, d, e, f, g, k[9],  w[9])\
    ROUND_A(g, h, a, b, c, d, e, f, k[10], w[10])\
    ROUND_A(f, g, h, a, b, c, d, e, k[11], w[11])\
    ROUND_A(e, f, g, h, a, b, c, d, k[12], w[12])\
    ROUND_A(d, e, f, g, h, a, b, c, k[13], w[13])\
    ROUND_A(c, d, e, f, g, h, a, b, k[14], w[14])\
    ROUND_A(b, c, d, e, f, g, h, a, k[15], w[15])\
    ROUND_B(a, b, c, d, e, f, g, h, k[16], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[17], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[18], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[19], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[20], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[21], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[22], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[23], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[24], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[25], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[26], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[27], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[28], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[29], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[30], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[31], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[32], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[33], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[34], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[35], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[36], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[37], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[38], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[39], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[40], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[41], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[42], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[43], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[44], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[45], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[46], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[47], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[48], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[49], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[50], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[51], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[52], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[53], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[54], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[55], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[56], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[57], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[58], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[59], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[60], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[61], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[62], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[63], w[15], w[13], w[0],  w[15], w[8])\
    ROUND_B(a, b, c, d, e, f, g, h, k[64], w[0],  w[14], w[1],  w[0],  w[9])\
    ROUND_B(h, a, b, c, d, e, f, g, k[65], w[1],  w[15], w[2],  w[1],  w[10])\
    ROUND_B(g, h, a, b, c, d, e, f, k[66], w[2],  w[0],  w[3],  w[2],  w[11])\
    ROUND_B(f, g, h, a, b, c, d, e, k[67], w[3],  w[1],  w[4],  w[3],  w[12])\
    ROUND_B(e, f, g, h, a, b, c, d, k[68], w[4],  w[2],  w[5],  w[4],  w[13])\
    ROUND_B(d, e, f, g, h, a, b, c, k[69], w[5],  w[3],  w[6],  w[5],  w[14])\
    ROUND_B(c, d, e, f, g, h, a, b, k[70], w[6],  w[4],  w[7],  w[6],  w[15])\
    ROUND_B(b, c, d, e, f, g, h, a, k[71], w[7],  w[5],  w[8],  w[7],  w[0])\
    ROUND_B(a, b, c, d, e, f, g, h, k[72], w[8],  w[6],  w[9],  w[8],  w[1])\
    ROUND_B(h, a, b, c, d, e, f, g, k[73], w[9],  w[7],  w[10], w[9],  w[2])\
    ROUND_B(g, h, a, b, c, d, e, f, k[74], w[10], w[8],  w[11], w[10], w[3])\
    ROUND_B(f, g, h, a, b, c, d, e, k[75], w[11], w[9],  w[12], w[11], w[4])\
    ROUND_B(e, f, g, h, a, b, c, d, k[76], w[12], w[10], w[13], w[12], w[5])\
    ROUND_B(d, e, f, g, h, a, b, c, k[77], w[13], w[11], w[14], w[13], w[6])\
    ROUND_B(c, d, e, f, g, h, a, b, k[78], w[14], w[12], w[15], w[14], w[7])\
    ROUND_B(b, c, d, e, f, g, h, a, k[79], w[15], w[13], w[0],  w[15], w[8])

#ifndef _OPENCL_COMPILER
/* --
 * Public domain hash function by DJ Bernstein
 * We are hashing almost the entire struct
-- */
int common_salt_hash(void *salt, int salt_size, int salt_hash_size);
#endif

#endif                          /* OPENCL_SHA2_COMMON_H */
// File: src/opencl_sha256.h
/*
 * Developed by Claudio André <claudioandre.br at gmail.com> in 2012
 *
 * Copyright (c) 2012-2015 Claudio André <claudioandre.br at gmail.com>
 * This program comes with ABSOLUTELY NO WARRANTY; express or implied.
 *
 * This is free software, and you are welcome to redistribute it
 * under certain conditions; as expressed here
 * http://www.gnu.org/licenses/gpl-2.0.html
 */

#ifndef OPENCL_SHA256_H
#define OPENCL_SHA256_H


#define MIN_KEYS_PER_CRYPT      1
#define MAX_KEYS_PER_CRYPT      1

//Macros.
#ifdef USE_BITSELECT
#define ror32(x, n)             (rotate(x, (32U-n)))
#elif (cpu(DEVICE_INFO))
#define ror32(x, n)             ((x >> n) | (x << (32U-n)))
#else
#define ror32(x, n)             (rotate(x, (32U-n)))
#endif
#define SWAP32_V(n)   \
    (((n) << 24)           | (((n) & 0xff00U) << 8) | \
    (((n) >> 8) & 0xff00U) | ((n) >> 24))
#define Sigma0(x)       ((ror32(x,2U))  ^ (ror32(x,13U)) ^ (ror32(x,22U)))
#define Sigma1(x)       ((ror32(x,6U))  ^ (ror32(x,11U)) ^ (ror32(x,25U)))
#define sigma0(x)       ((ror32(x,7U))  ^ (ror32(x,18U)) ^ (x>>3))
#define sigma1(x)       ((ror32(x,17U)) ^ (ror32(x,19U)) ^ (x>>10))

//SHA256 constants.
#define H0      0x6a09e667U
#define H1      0xbb67ae85U
#define H2      0x3c6ef372U
#define H3      0xa54ff53aU
#define H4      0x510e527fU
#define H5      0x9b05688cU
#define H6      0x1f83d9abU
#define H7      0x5be0cd19U

#ifdef _OPENCL_COMPILER
__const_a8 uint32_t k[] = {
	0x428a2f98U, 0x71374491U, 0xb5c0fbcfU, 0xe9b5dba5U,
	0x3956c25bU, 0x59f111f1U, 0x923f82a4U, 0xab1c5ed5U,
	0xd807aa98U, 0x12835b01U, 0x243185beU, 0x550c7dc3U,
	0x72be5d74U, 0x80deb1feU, 0x9bdc06a7U, 0xc19bf174U,
	0xe49b69c1U, 0xefbe4786U, 0x0fc19dc6U, 0x240ca1ccU,
	0x2de92c6fU, 0x4a7484aaU, 0x5cb0a9dcU, 0x76f988daU,
	0x983e5152U, 0xa831c66dU, 0xb00327c8U, 0xbf597fc7U,
	0xc6e00bf3U, 0xd5a79147U, 0x06ca6351U, 0x14292967U,
	0x27b70a85U, 0x2e1b2138U, 0x4d2c6dfcU, 0x53380d13U,
	0x650a7354U, 0x766a0abbU, 0x81c2c92eU, 0x92722c85U,
	0xa2bfe8a1U, 0xa81a664bU, 0xc24b8b70U, 0xc76c51a3U,
	0xd192e819U, 0xd6990624U, 0xf40e3585U, 0x106aa070U,
	0x19a4c116U, 0x1e376c08U, 0x2748774cU, 0x34b0bcb5U,
	0x391c0cb3U, 0x4ed8aa4aU, 0x5b9cca4fU, 0x682e6ff3U,
	0x748f82eeU, 0x78a5636fU, 0x84c87814U, 0x8cc70208U,
	0x90befffaU, 0xa4506cebU, 0xbef9a3f7U, 0xc67178f2U
};

__const_a8 uint32_t clear_mask[] = {
	0xffffffffU, 0x000000ffU,   //0,   8bits
	0x0000ffffU, 0x00ffffffU,   //16, 24bits
	0xffffffffU                 //32    bits
};

__const_a8 uint32_t clear_be_mask[] = {
	0xffffffffU, 0xff000000U,   //0,   8bits
	0xffff0000U, 0xffffff00U,   //16, 24bits
	0xffffffffU                 //32    bits
};

#define OFFSET(index, position)            \
    (get_global_id(0) +                \
        (get_global_size(0) *          \
        (index * 32 + position))           \
    )

#define CLEAR_BUFFER_32(dest, start) {             \
    uint32_t tmp, pos;                             \
    tmp = ((start) & 3U);              \
    pos = ((start) >> 2);              \
    dest[pos] = dest[pos] & clear_mask[tmp];       \
    if (tmp)                                       \
        length = pos + 1;                          \
    else                                           \
    length = pos;                              \
}

#define CLEAR_BUFFER_32_SINGLE(dest, start) {      \
    uint32_t tmp, pos;                             \
    tmp = ((start) & 3U);              \
    pos = ((start) >> 2);              \
    dest[pos] = dest[pos] & clear_mask[tmp];       \
}

#define APPEND_BE_SINGLE(dest, src, start) {       \
    uint32_t tmp, pos;                             \
    tmp = (((start) & 3U) << 3);                   \
    pos = ((start) >> 2);                          \
    dest[pos] = (dest[pos] | (src >> tmp));        \
}

#define APPEND_BE_SPECIAL(dest, src, index, start) {            \
    uint32_t tmp, pos, offset;                      \
    tmp = (((start) & 3U) << 3);                    \
    pos = ((start) >> 2);                       \
    offset = OFFSET(index, pos);                    \
    dest[offset] = (dest[offset] | (src >> tmp));           \
    if (pos < 17) {                             \
    pos++;                              \
    offset = OFFSET(index, pos);                    \
    dest[offset] = (tmp ? (src << (32U - tmp)) : 0U);       \
    }                                   \
}

#define APPEND_BE_BUFFER(dest, src)                 \
    dest[pos] = (dest[pos] | (src >> tmp));             \
    dest[++pos] = (tmp ? (src << (32U - tmp)) : 0U);

#define APPEND_BE_BUFFER_F(dest, src)                   \
    dest[pos] = (dest[pos] | (src >> tmp));             \
    if (pos < 15)                           \
        dest[++pos] = (tmp ? (src << (32U - tmp)) : 0U);        \

#define APPEND_SINGLE(dest, src, start) {               \
    uint32_t tmp, pos;                          \
    tmp = (((start) & 3U) << 3);                    \
    pos = ((start) >> 2);                       \
    dest[pos] = (dest[pos] | (src << tmp));             \
}

#define APPEND_BUFFER_F(dest, src)                  \
    dest[pos] = (dest[pos] | (src << tmp));             \
    if (pos < 15)                           \
        dest[++pos] = (tmp ? (src >> (32U - tmp)) : 0U);
#endif

#endif                          /* OPENCL_SHA256_H */
// File: src/opencl_rawsha256.h
/*
 * Developed by Claudio André <claudioandre.br at gmail.com> in 2012
 *
 * More information at http://openwall.info/wiki/john/OpenCL-RAWSHA-256
 *
 * Copyright (c) 2012-2015 Claudio André <claudioandre.br at gmail.com>
 * This program comes with ABSOLUTELY NO WARRANTY; express or implied.
 *
 * This is free software, and you are welcome to redistribute it
 * under certain conditions; as expressed here
 * http://www.gnu.org/licenses/gpl-2.0.html
 */

#ifndef _RAWSHA256_H
#define _RAWSHA256_H


//Constants.
#define RAW_PLAINTEXT_LENGTH    55  /* 55 characters + 0x80 */
#define PLAINTEXT_LENGTH    RAW_PLAINTEXT_LENGTH

#define BUFFER_SIZE             56  /* RAW_PLAINTEXT_LENGTH multiple of 4 */

#ifdef _OPENCL_COMPILER
#define BINARY_SIZE             32
#endif

#define HASH_PARTS      BINARY_SIZE / 4
#define SALT_SIZE               0
#define SALT_ALIGN              1
#define STEP            0
#define SEED            1024

#define KEYS_PER_CORE_CPU       65536
#define KEYS_PER_CORE_GPU       512

#define SPREAD_32(X0, X1, X2, X3, SIZE_MIN_1, X, Y) {                         \
	X = (X0) ^ (X1) ^ (X2);                                               \
	X = X & SIZE_MIN_1;                                                   \
	Y = (X + (X3)) ^ (X0);                                                \
	Y = Y & SIZE_MIN_1;                                                   \
}

//Data types.
typedef union buffer_32_u {
	uint8_t mem_08[4];
	uint16_t mem_16[2];
	uint32_t mem_32[1];
} buffer_32;

typedef struct {
	uint32_t v[8];              //256 bits
} sha256_hash;

typedef struct {
	uint32_t buflen;
	buffer_32 buffer[16];       //512 bits
} sha256_ctx;

#ifndef _OPENCL_COMPILER
static const char *warn[] = {
	"prep: ", ", xfer pass: ", ", idx: ", ", crypt: ", ", result: ",
	", mask xfer: ", " + "
};
#endif

#endif                          /* _RAWSHA256_H */
// File: opencl/sha256_kernel.cl
/*
 * Developed by Claudio André <claudioandre.br at gmail.com> in 2012
 *
 * More information at http://openwall.info/wiki/john/OpenCL-RAWSHA-256
 *
 * Copyright (c) 2012-2016 Claudio André <claudioandre.br at gmail.com>
 * This program comes with ABSOLUTELY NO WARRANTY; express or implied.
 *
 * This is free software, and you are welcome to redistribute it
 * under certain conditions; as expressed here
 * http://www.gnu.org/licenses/gpl-2.0.html
 */


#ifndef UNROLL_LOOP
    ///	    *** UNROLL ***
    ///AMD: sometimes a bad thing(?).
    ///NVIDIA: GTX 570 don't allow full unroll.
    #if amd_vliw4(DEVICE_INFO) || amd_vliw5(DEVICE_INFO)
        #define UNROLL_LOOP    132104
    #elif amd_gcn(DEVICE_INFO)
        #define UNROLL_LOOP    132104
    #elif (nvidia_sm_2x(DEVICE_INFO) || nvidia_sm_3x(DEVICE_INFO))
        #define UNROLL_LOOP    132098
    #elif nvidia_sm_5x(DEVICE_INFO)
        #define UNROLL_LOOP    132104
    #else
        #define UNROLL_LOOP    0
    #endif
#endif

#if (UNROLL_LOOP & (1 << 25))
    #define VECTOR_USAGE    1
#endif

#if gpu_amd(DEVICE_INFO)
    #define USE_LOCAL       1
#endif

inline void _memcpy(               uint32_t * dest,
                    __global const uint32_t * src,
                             const uint32_t   len) {

    for (uint i = 0; i < len; i += 4)
        *dest++ = *src++;
}

inline void any_hash_cracked(
	const uint32_t iter,                        //which candidates_number is this one
	volatile __global uint32_t * const hash_id, //information about how recover the cracked password
	const uint32_t * const hash,                //the hash calculated by this kernel
	__global const uint32_t * const bitmap) {

    uint32_t bit_mask_x, bit_mask_y, found;

    SPREAD_32(hash[0], hash[1], hash[2], hash[3], BITMAP_SIZE_MINUS1, bit_mask_x, bit_mask_y)

    if (bitmap[bit_mask_x >> 5] & (1U << (bit_mask_x & 31))) {

	if (bitmap[bit_mask_y >> 5] & (1U << (bit_mask_y & 31))) {
	    //A possible crack have been found.
	    found = atomic_inc(&hash_id[0]);

	    {
		//Save (the probably) hashed key metadata.
		uint32_t base = get_global_id(0);

		hash_id[1 + 3 * found] = base;
		hash_id[2 + 3 * found] = iter;
		hash_id[3 + 3 * found] = (uint32_t) hash[0];
	    }
	}
    }
}

inline void sha256_block(	  const uint32_t * const buffer,
				  const uint32_t total, uint32_t * const H) {

    uint32_t a = H0;
    uint32_t b = H1;
    uint32_t c = H2;
    uint32_t d = H3;
    uint32_t e = H4;
    uint32_t f = H5;
    uint32_t g = H6;
    uint32_t h = H7;
    uint32_t t;
    uint32_t w[16];	//#define  w   buffer

#ifdef VECTOR_USAGE
    uint16  w_vector;
    w_vector = vload16(0, buffer);
    w_vector = SWAP32_V(w_vector);
    vstore16(w_vector, 0, w);
#else
    #pragma unroll
    for (uint i = 0U; i < 15U; i++)
        w[i] = SWAP32(buffer[i]);
#endif
    w[15] = (total * 8U);

#if (UNROLL_LOOP & (1 << 1))
    #pragma unroll 1
#elif (UNROLL_LOOP & (1 << 2))
    #pragma unroll 4
#elif (UNROLL_LOOP & (1 << 3))
    #pragma unroll
#endif
    for (uint i = 0U; i < 16U; i++) {
	t = k[i] + w[i] + h + Sigma1(e) + Ch(e, f, g);

	h = g;
	g = f;
	f = e;
	e = d + t;
	t = t + Maj(a, b, c) + Sigma0(a);
	d = c;
	c = b;
	b = a;
	a = t;
    }

#if (UNROLL_LOOP & (1 << 9))
    #pragma unroll 1
#elif (UNROLL_LOOP & (1 << 10))
    #pragma unroll 16
#elif (UNROLL_LOOP & (1 << 11))
    #pragma unroll
#endif
    for (uint i = 16U; i < 64U; i++) {
	w[i & 15] = sigma1(w[(i - 2) & 15]) + sigma0(w[(i - 15) & 15]) + w[(i - 16) & 15] + w[(i - 7) & 15];
	t = k[i] + w[i & 15] + h + Sigma1(e) + Ch(e, f, g);

	h = g;
	g = f;
	f = e;
	e = d + t;
	t = t + Maj(a, b, c) + Sigma0(a);
	d = c;
	c = b;
	b = a;
	a = t;
    }

    /* Put checksum in context given as argument. */
    H[0] = (a + H0);
    H[1] = (b + H1);
    H[2] = (c + H2);
    H[3] = (d + H3);
    H[4] = (e + H4);
    H[5] = (f + H5);
    H[6] = (g + H6);
    H[7] = (h + H7);
}

/* *****************
- index,		//keys offset and length
- int_key_loc,		//the position of the mask to apply
- int_keys,		//mask to be applied
- candidates_number,	//the number of candidates by mask mode
- hash_id,		//information about how recover the cracked password
- bitmap,		//bitmap containing all to crack hashes
***************** */
__kernel
void kernel_plaintext_raw(
	     __global const uint32_t *       __restrict keys_buffer,
             __global const uint32_t * const __restrict index,
	     __global const uint32_t * const __restrict int_key_loc,
	     __global const uint32_t * const __restrict int_keys,
		      const uint32_t              candidate_id,
	     __global       uint32_t * const __restrict computed_total,
	     __global       uint32_t * const __restrict computed_w) {

    //Compute buffers (on CPU and NVIDIA, better private)
    uint32_t		w[16];
    size_t gid = get_global_id(0);

#ifdef USE_LOCAL
    __local uint32_t	_ltotal[512];
    #define		total    _ltotal[get_local_id(0)]
#else
    uint32_t            _ltotal;
    #define		total    _ltotal
#endif

    {
	//Get the position and length of the target key.
	uint32_t base = index[gid];
	total = base & 63;

	//Ajust keys to it start position.
	keys_buffer += (base >> 6);
    }
    //- Differences -------------------------------
    #define		W_OFFSET    0

    //Clear the buffer.
    #pragma unroll
    for (uint i = 0; i < 15; i++)
        w[i] = 0;

    //Get password.
    _memcpy((uint32_t *) w, keys_buffer, total);
    //---------------------------------------------

    //Prepare buffer.
    CLEAR_BUFFER_32_SINGLE(w, total);
    APPEND_SINGLE(w, 0x80U, total);

#ifdef GPU_MASK_MODE
	    //Mask Mode: keys generation/finalization.
	    MASK_KEYS_GENERATION(candidate_id)
#endif

    //save computed w[]
    computed_total[gid] = total;

    #pragma unroll
    for (uint i = 0; i < 15; i++)
        computed_w[gid * 16 + i] = w[i];
}
#undef		W_OFFSET

__kernel
void kernel_crypt(
		      const uint32_t              candidate_id,
    volatile __global       uint32_t * const __restrict hash_id,
             __global       uint32_t * const __restrict bitmap,
	     __global const uint32_t *       __restrict computed_total,
	     __global const uint32_t *       __restrict computed_w) {

    //Compute buffers (on CPU and NVIDIA, better private)
    uint32_t		w[16];
    uint32_t		H[8];
    size_t gid = get_global_id(0);

#ifdef USE_LOCAL
    __local uint32_t	_ltotal[512];
    #define		total    _ltotal[get_local_id(0)]
#else
    uint32_t            _ltotal;
    #define		total    _ltotal
#endif

    //Get w[].
    total = computed_total[gid];

    #pragma unroll
    for (uint i = 0; i < 15; i++)
        w[i] = computed_w[gid * 16 + i];

    /* Run the collected hash value through sha256. */
    sha256_block(w, total, H);

    any_hash_cracked(candidate_id, hash_id, H, bitmap);
}

__kernel
void kernel_crypt_raw(
	     __global const uint32_t *       __restrict keys_buffer,
             __global const uint32_t * const __restrict index,
	     __global const uint32_t * const __restrict int_key_loc,
	     __global const uint32_t * const __restrict int_keys,
		      const uint32_t              candidates_number,
    volatile __global       uint32_t * const __restrict hash_id,
             __global const uint32_t * const __restrict bitmap) {

    //Compute buffers (on CPU and NVIDIA, better private)
    uint32_t		w[16];
    uint32_t		H[8];
#ifdef USE_LOCAL
    __local uint32_t	_ltotal[512];
    #define		total    _ltotal[get_local_id(0)]
#else
    uint32_t            _ltotal;
    #define		total    _ltotal
#endif

    {
	//Get position and length of informed key.
	uint32_t base = index[get_global_id(0)];
	total = base & 63;

	//Ajust keys to it start position.
	keys_buffer += (base >> 6);
    }
    //- Differences -------------------------------
    #define		W_OFFSET    0

    //Clear the buffer.
    #pragma unroll
    for (uint i = 0; i < 15; i++)
        w[i] = 0;

    //Get password.
    _memcpy((uint32_t *) w, keys_buffer, total);
    //---------------------------------------------

    //Prepare buffer.
    CLEAR_BUFFER_32_SINGLE(w, total);
    APPEND_SINGLE(w, 0x80U, total);

    {
	uint32_t i = 0;

#ifdef GPU_MASK_MODE
	//Handle the GPU mask mode candidates generation.
	for (; i < candidates_number; i++) {
#endif

#ifdef GPU_MASK_MODE
	    //Mask Mode: keys generation/finalization.
	    MASK_KEYS_GENERATION(i)
#endif
	    /* Run the collected hash value through sha256. */
	    sha256_block(w, total, H);

	    any_hash_cracked(i, hash_id, H, bitmap);
#ifdef GPU_MASK_MODE
	}
#endif
    }
}
#undef		W_OFFSET

__kernel
void kernel_prepare(
    const    uint32_t                    candidates_number,
    __global uint32_t * const __restrict hash_id) {

    //Clean bitmap and result buffer
    if (get_global_id(0) == 0)
	hash_id[0] = 0;
}
