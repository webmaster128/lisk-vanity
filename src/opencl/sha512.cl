/*

Generated using

(
    echo "// File: src/opencl_device_info.h"
    curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_device_info.h
    echo "// File: src/opencl_misc.h"
    curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_misc.h
    echo "// File: src/opencl_sha2.h"
    curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl_sha2.h
    echo "// File: opencl/sha512_kernel.cl"
    curl -sS --location https://github.com/magnumripper/JohnTheRipper/raw/bleeding-jumbo/src/opencl/sha512_kernel.cl
) | grep -v '#include "' > src/opencl/sha512.cl

and some hand-selected modifications

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
// File: src/opencl_sha2.h
/*
 * This software is Copyright (c) 2013 Lukas Odzioba <ukasz at openwall dot net>
 * and Copyright (c) 2014-2018 magnum
 * and it is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted.
 */

#ifndef _OPENCL_SHA2_H
#define _OPENCL_SHA2_H


#define SHA2_H_SHA256_LUT3 HAVE_LUT3
#define SHA2_H_SHA512_LUT3 HAVE_LUT3_64

#if SHA2_H_SHA256_LUT3
#define Ch(x, y, z) lut3(x, y, z, 0xca)
#elif USE_BITSELECT
#define Ch(x, y, z) bitselect(z, y, x)
#elif HAVE_ANDNOT
#define Ch(x, y, z) ((x & y) ^ ((~x) & z))
#else
#define Ch(x, y, z) (z ^ (x & (y ^ z)))
#endif

#if SHA2_H_SHA256_LUT3
#define Maj(x, y, z) lut3(x, y, z, 0xe8)
#elif USE_BITSELECT
#define Maj(x, y, z) bitselect(x, y, z ^ x)
#else
#define Maj(x, y, z) ((x & y) | (z & (x | y)))
#endif

#define ror(x, n)	rotate(x, 32U-(n))

__const_a8 uint h[] = {
	0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
	0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
};

__const_a8 uint SHA2_H_k[] = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
	0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
	0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
	0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
	0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
	0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

#if 0 && SHA2_H_SHA256_LUT3
/* LOP3.LUT alternative - does no good */
#define SHA2_H_Sigma0(x) lut3(ror(x, 2), ror(x, 13), ror(x, 22), 0x96)
#define SHA2_H_Sigma1(x) lut3(ror(x, 6), ror(x, 11), ror(x, 25), 0x96)
#elif gpu_nvidia(DEVICE_INFO)
/*
 * These Sigma alternatives are from "Fast SHA-256 Implementations on Intel
 * Architecture Processors" whitepaper by Intel. They were intended for use
 * with destructive rotate (minimizing register copies) but might be better
 * or worse on different hardware for other reasons.
 */
#define SHA2_H_Sigma0(x) (ror(ror(ror(x, 9) ^ x, 11) ^ x, 2))
#define SHA2_H_Sigma1(x) (ror(ror(ror(x, 14) ^ x, 5) ^ x, 6))
#else
/* Original SHA-2 function */
#define SHA2_H_Sigma0(x) (ror(x, 2) ^ ror(x, 13) ^ ror(x, 22))
#define SHA2_H_Sigma1(x) (ror(x, 6) ^ ror(x, 11) ^ ror(x, 25))
#endif

#if 0 && SHA2_H_SHA256_LUT3
/* LOP3.LUT alternative - does no good */
#define SHA2_H_sigma0(x) lut3(ror(x, 7), ror(x, 18), (x >> 3), 0x96)
#define SHA2_H_sigma1(x) lut3(ror(x, 17), ror(x, 19), (x >> 10), 0x96)
#elif 0
/*
 * These sigma alternatives are derived from "Fast SHA-512 Implementations
 * on Intel Architecture Processors" whitepaper by Intel (rewritten here
 * for SHA-256 by magnum). They were intended for use with destructive shifts
 * (minimizing register copies) but might be better or worse on different
 * hardware for other reasons. They will likely always be a regression when
 * we have hardware rotate instructions.
 */
#define SHA2_H_sigma0(x) ((((((x >> 11) ^ x) >> 4) ^ x) >> 3) ^ (((x << 11) ^ x) << 14))
#define SHA2_H_sigma1(x) ((((((x >> 2) ^ x) >> 7) ^ x) >> 10) ^ (((x << 2) ^ x) << 13))
#else
/* Original SHA-2 function */
#define SHA2_H_sigma0(x) (ror(x, 7) ^ ror(x, 18) ^ (x >> 3))
#define SHA2_H_sigma1(x) (ror(x, 17) ^ ror(x, 19) ^ (x >> 10))
#endif

#define SHA2_H_ROUND_A(a,b,c,d,e,f,g,h,ki,wi)	  \
	{ \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

#define SHA2_H_ROUND_Z(a,b,c,d,e,f,g,h,ki)	  \
	{ \
		t = (ki) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

#define SHA2_H_ROUND_B(a,b,c,d,e,f,g,h,ki,wi,wj,wk,wl,wm)	  \
	{ \
		wi = SHA2_H_sigma1(wj) + SHA2_H_sigma0(wk) + wl + wm; \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

//0110
#define SHA2_H_ROUND_I(a,b,c,d,e,f,g,h,ki,wi,wj,wk,wl,wm)	  \
	{ \
		wi = SHA2_H_sigma0(wk) + wl; \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

//1110
#define SHA2_H_ROUND_J(a,b,c,d,e,f,g,h,ki,wi,wj,wk,wl,wm)	  \
	{ \
		wi = SHA2_H_sigma1(wj) + SHA2_H_sigma0(wk) + wl; \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

//1011
#define SHA2_H_ROUND_K(a,b,c,d,e,f,g,h,ki,wi,wj,wk,wl,wm)	  \
	{ \
		wi = SHA2_H_sigma1(wj) + wl + wm; \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

//1001
#define SHA2_H_ROUND_L(a,b,c,d,e,f,g,h,ki,wi,wj,wk,wl,wm)	  \
	{ \
		wi = SHA2_H_sigma1(wj)+ wm; \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

//1101
#define SHA2_H_ROUND_M(a,b,c,d,e,f,g,h,ki,wi,wj,wk,wl,wm)	  \
	{ \
		wi = SHA2_H_sigma1(wj) + SHA2_H_sigma0(wk) + wm; \
		t = (ki) + (wi) + (h) + SHA2_H_Sigma1(e) + Ch((e),(f),(g)); \
		d += (t); h = (t) + SHA2_H_Sigma0(a) + Maj((a), (b), (c)); \
	}

#define SHA2_H_SHA256(A,B,C,D,E,F,G,H,W)	  \
	SHA2_H_ROUND_A(A,B,C,D,E,F,G,H,SHA2_H_k[0],W[0]); \
	SHA2_H_ROUND_A(H,A,B,C,D,E,F,G,SHA2_H_k[1],W[1]); \
	SHA2_H_ROUND_A(G,H,A,B,C,D,E,F,SHA2_H_k[2],W[2]); \
	SHA2_H_ROUND_A(F,G,H,A,B,C,D,E,SHA2_H_k[3],W[3]); \
	SHA2_H_ROUND_A(E,F,G,H,A,B,C,D,SHA2_H_k[4],W[4]); \
	SHA2_H_ROUND_A(D,E,F,G,H,A,B,C,SHA2_H_k[5],W[5]); \
	SHA2_H_ROUND_A(C,D,E,F,G,H,A,B,SHA2_H_k[6],W[6]); \
	SHA2_H_ROUND_A(B,C,D,E,F,G,H,A,SHA2_H_k[7],W[7]); \
	SHA2_H_ROUND_A(A,B,C,D,E,F,G,H,SHA2_H_k[8],W[8]); \
	SHA2_H_ROUND_A(H,A,B,C,D,E,F,G,SHA2_H_k[9],W[9]); \
	SHA2_H_ROUND_A(G,H,A,B,C,D,E,F,SHA2_H_k[10],W[10]); \
	SHA2_H_ROUND_A(F,G,H,A,B,C,D,E,SHA2_H_k[11],W[11]); \
	SHA2_H_ROUND_A(E,F,G,H,A,B,C,D,SHA2_H_k[12],W[12]); \
	SHA2_H_ROUND_A(D,E,F,G,H,A,B,C,SHA2_H_k[13],W[13]); \
	SHA2_H_ROUND_A(C,D,E,F,G,H,A,B,SHA2_H_k[14],W[14]); \
	SHA2_H_ROUND_A(B,C,D,E,F,G,H,A,SHA2_H_k[15],W[15]); \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[16],W[0],  W[14],W[1],W[0],W[9]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[17],W[1],  W[15],W[2],W[1],W[10]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[18],W[2],  W[0],W[3],W[2],W[11]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[19],W[3],  W[1],W[4],W[3],W[12]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[20],W[4],  W[2],W[5],W[4],W[13]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[21],W[5],  W[3],W[6],W[5],W[14]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[22],W[6],  W[4],W[7],W[6],W[15]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[23],W[7],  W[5],W[8],W[7],W[0]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[24],W[8],  W[6],W[9],W[8],W[1]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[25],W[9],  W[7],W[10],W[9],W[2]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[26],W[10],  W[8],W[11],W[10],W[3]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[27],W[11],  W[9],W[12],W[11],W[4]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[28],W[12],  W[10],W[13],W[12],W[5]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[29],W[13],  W[11],W[14],W[13],W[6]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[30],W[14],  W[12],W[15],W[14],W[7]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[31],W[15],  W[13],W[0],W[15],W[8]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[32],W[0],  W[14],W[1],W[0],W[9]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[33],W[1],  W[15],W[2],W[1],W[10]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[34],W[2],  W[0],W[3],W[2],W[11]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[35],W[3],  W[1],W[4],W[3],W[12]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[36],W[4],  W[2],W[5],W[4],W[13]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[37],W[5],  W[3],W[6],W[5],W[14]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[38],W[6],  W[4],W[7],W[6],W[15]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[39],W[7],  W[5],W[8],W[7],W[0]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[40],W[8],  W[6],W[9],W[8],W[1]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[41],W[9],  W[7],W[10],W[9],W[2]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[42],W[10],  W[8],W[11],W[10],W[3]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[43],W[11],  W[9],W[12],W[11],W[4]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[44],W[12],  W[10],W[13],W[12],W[5]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[45],W[13],  W[11],W[14],W[13],W[6]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[46],W[14],  W[12],W[15],W[14],W[7]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[47],W[15],  W[13],W[0],W[15],W[8]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[48],W[0],  W[14],W[1],W[0],W[9]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[49],W[1],  W[15],W[2],W[1],W[10]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[50],W[2],  W[0],W[3],W[2],W[11]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[51],W[3],  W[1],W[4],W[3],W[12]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[52],W[4],  W[2],W[5],W[4],W[13]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[53],W[5],  W[3],W[6],W[5],W[14]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[54],W[6],  W[4],W[7],W[6],W[15]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[55],W[7],  W[5],W[8],W[7],W[0]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[56],W[8],  W[6],W[9],W[8],W[1]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[57],W[9],  W[7],W[10],W[9],W[2]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[58],W[10],  W[8],W[11],W[10],W[3]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[59],W[11],  W[9],W[12],W[11],W[4]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[60],W[12],  W[10],W[13],W[12],W[5]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[61],W[13],  W[11],W[14],W[13],W[6]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[62],W[14],  W[12],W[15],W[14],W[7]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[63],W[15],  W[13],W[0],W[15],W[8])

#define Z (0)
//W[9]-W[14] are zeros
#define SHA2_H_SHA256_ZEROS(A,B,C,D,E,F,G,H,W)	  \
	SHA2_H_ROUND_A(A,B,C,D,E,F,G,H,SHA2_H_k[0],W[0]); \
	SHA2_H_ROUND_A(H,A,B,C,D,E,F,G,SHA2_H_k[1],W[1]); \
	SHA2_H_ROUND_A(G,H,A,B,C,D,E,F,SHA2_H_k[2],W[2]); \
	SHA2_H_ROUND_A(F,G,H,A,B,C,D,E,SHA2_H_k[3],W[3]); \
	SHA2_H_ROUND_A(E,F,G,H,A,B,C,D,SHA2_H_k[4],W[4]); \
	SHA2_H_ROUND_A(D,E,F,G,H,A,B,C,SHA2_H_k[5],W[5]); \
	SHA2_H_ROUND_A(C,D,E,F,G,H,A,B,SHA2_H_k[6],W[6]); \
	SHA2_H_ROUND_A(B,C,D,E,F,G,H,A,SHA2_H_k[7],W[7]); \
	SHA2_H_ROUND_A(A,B,C,D,E,F,G,H,SHA2_H_k[8],W[8]); \
	SHA2_H_ROUND_Z(H,A,B,C,D,E,F,G,SHA2_H_k[9]); \
	SHA2_H_ROUND_Z(G,H,A,B,C,D,E,F,SHA2_H_k[10]); \
	SHA2_H_ROUND_Z(F,G,H,A,B,C,D,E,SHA2_H_k[11]); \
	SHA2_H_ROUND_Z(E,F,G,H,A,B,C,D,SHA2_H_k[12]); \
	SHA2_H_ROUND_Z(D,E,F,G,H,A,B,C,SHA2_H_k[13]); \
	SHA2_H_ROUND_Z(C,D,E,F,G,H,A,B,SHA2_H_k[14]); \
	SHA2_H_ROUND_A(B,C,D,E,F,G,H,A,SHA2_H_k[15],W[15]); \
	SHA2_H_ROUND_I(A,B,C,D,E,F,G,H,SHA2_H_k[16],W[0],  Z,W[1],W[0],Z) \
	SHA2_H_ROUND_J(H,A,B,C,D,E,F,G,SHA2_H_k[17],W[1],  W[15],W[2],W[1],Z) \
	SHA2_H_ROUND_J(G,H,A,B,C,D,E,F,SHA2_H_k[18],W[2],  W[0],W[3],W[2],Z) \
	SHA2_H_ROUND_J(F,G,H,A,B,C,D,E,SHA2_H_k[19],W[3],  W[1],W[4],W[3],Z) \
	SHA2_H_ROUND_J(E,F,G,H,A,B,C,D,SHA2_H_k[20],W[4],  W[2],W[5],W[4],Z) \
	SHA2_H_ROUND_J(D,E,F,G,H,A,B,C,SHA2_H_k[21],W[5],  W[3],W[6],W[5],Z) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[22],W[6],  W[4],W[7],W[6],W[15]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[23],W[7],  W[5],W[8],W[7],W[0]) \
	SHA2_H_ROUND_K(A,B,C,D,E,F,G,H,SHA2_H_k[24],W[8],  W[6],Z,W[8],W[1]) \
	SHA2_H_ROUND_L(H,A,B,C,D,E,F,G,SHA2_H_k[25],W[9],  W[7],Z,Z,W[2]) \
	SHA2_H_ROUND_L(G,H,A,B,C,D,E,F,SHA2_H_k[26],W[10],  W[8],Z,Z,W[3]) \
	SHA2_H_ROUND_L(F,G,H,A,B,C,D,E,SHA2_H_k[27],W[11],  W[9],Z,Z,W[4]) \
	SHA2_H_ROUND_L(E,F,G,H,A,B,C,D,SHA2_H_k[28],W[12],  W[10],Z,Z,W[5]) \
	SHA2_H_ROUND_L(D,E,F,G,H,A,B,C,SHA2_H_k[29],W[13],  W[11],Z,Z,W[6]) \
	SHA2_H_ROUND_M(C,D,E,F,G,H,A,B,SHA2_H_k[30],W[14],  W[12],W[15],Z,W[7]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[31],W[15],  W[13],W[0],W[15],W[8]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[32],W[0],  W[14],W[1],W[0],W[9]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[33],W[1],  W[15],W[2],W[1],W[10]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[34],W[2],  W[0],W[3],W[2],W[11]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[35],W[3],  W[1],W[4],W[3],W[12]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[36],W[4],  W[2],W[5],W[4],W[13]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[37],W[5],  W[3],W[6],W[5],W[14]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[38],W[6],  W[4],W[7],W[6],W[15]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[39],W[7],  W[5],W[8],W[7],W[0]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[40],W[8],  W[6],W[9],W[8],W[1]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[41],W[9],  W[7],W[10],W[9],W[2]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[42],W[10],  W[8],W[11],W[10],W[3]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[43],W[11],  W[9],W[12],W[11],W[4]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[44],W[12],  W[10],W[13],W[12],W[5]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[45],W[13],  W[11],W[14],W[13],W[6]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[46],W[14],  W[12],W[15],W[14],W[7]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[47],W[15],  W[13],W[0],W[15],W[8]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[48],W[0],  W[14],W[1],W[0],W[9]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[49],W[1],  W[15],W[2],W[1],W[10]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[50],W[2],  W[0],W[3],W[2],W[11]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[51],W[3],  W[1],W[4],W[3],W[12]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[52],W[4],  W[2],W[5],W[4],W[13]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[53],W[5],  W[3],W[6],W[5],W[14]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[54],W[6],  W[4],W[7],W[6],W[15]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[55],W[7],  W[5],W[8],W[7],W[0]) \
	SHA2_H_ROUND_B(A,B,C,D,E,F,G,H,SHA2_H_k[56],W[8],  W[6],W[9],W[8],W[1]) \
	SHA2_H_ROUND_B(H,A,B,C,D,E,F,G,SHA2_H_k[57],W[9],  W[7],W[10],W[9],W[2]) \
	SHA2_H_ROUND_B(G,H,A,B,C,D,E,F,SHA2_H_k[58],W[10],  W[8],W[11],W[10],W[3]) \
	SHA2_H_ROUND_B(F,G,H,A,B,C,D,E,SHA2_H_k[59],W[11],  W[9],W[12],W[11],W[4]) \
	SHA2_H_ROUND_B(E,F,G,H,A,B,C,D,SHA2_H_k[60],W[12],  W[10],W[13],W[12],W[5]) \
	SHA2_H_ROUND_B(D,E,F,G,H,A,B,C,SHA2_H_k[61],W[13],  W[11],W[14],W[13],W[6]) \
	SHA2_H_ROUND_B(C,D,E,F,G,H,A,B,SHA2_H_k[62],W[14],  W[12],W[15],W[14],W[7]) \
	SHA2_H_ROUND_B(B,C,D,E,F,G,H,A,SHA2_H_k[63],W[15],  W[13],W[0],W[15],W[8])

#define sha256_init(ctx)	  \
	{ \
		uint i; \
		for (i = 0; i < 8; i++) \
			(ctx)[i] = h[i]; \
	}

#define sha256_block(pad, ctx)\
 {	  \
	uint A, B, C, D, E, F, G, H, t; \
	A = (ctx)[0]; \
	B = (ctx)[1]; \
	C = (ctx)[2]; \
	D = (ctx)[3]; \
	E = (ctx)[4]; \
	F = (ctx)[5]; \
	G = (ctx)[6]; \
	H = (ctx)[7]; \
	SHA2_H_SHA256(A,B,C,D,E,F,G,H,pad); \
	(ctx)[0] += A; \
	(ctx)[1] += B; \
	(ctx)[2] += C; \
	(ctx)[3] += D; \
	(ctx)[4] += E; \
	(ctx)[5] += F; \
	(ctx)[6] += G; \
	(ctx)[7] += H; \
}

#define sha256_block_zeros(pad, ctx)\
 {	  \
	uint A, B, C, D, E, F, G, H, t; \
	A = (ctx)[0]; \
	B = (ctx)[1]; \
	C = (ctx)[2]; \
	D = (ctx)[3]; \
	E = (ctx)[4]; \
	F = (ctx)[5]; \
	G = (ctx)[6]; \
	H = (ctx)[7]; \
	SHA2_H_SHA256_ZEROS(A,B,C,D,E,F,G,H,pad); \
	(ctx)[0] += A; \
	(ctx)[1] += B; \
	(ctx)[2] += C; \
	(ctx)[3] += D; \
	(ctx)[4] += E; \
	(ctx)[5] += F; \
	(ctx)[6] += G; \
	(ctx)[7] += H; \
}

/*
 ***************************************************************************
 * SHA2_H_SHA512 below this line
 ***************************************************************************
 */

#undef Maj
#undef Ch

#if SHA2_H_SHA512_LUT3
#define Ch(x, y, z) lut3_64(x, y, z, 0xca)
#elif USE_BITSELECT
#define Ch(x, y, z) bitselect(z, y, x)
#elif HAVE_ANDNOT
#define Ch(x, y, z) ((x & y) ^ ((~x) & z))
#else
#define Ch(x, y, z) (z ^ (x & (y ^ z)))
#endif

#if SHA2_H_SHA512_LUT3
#define Maj(x, y, z) lut3_64(x, y, z, 0xe8)
#elif USE_BITSELECT
#define Maj(x, y, z) bitselect(x, y, z ^ x)
#else
#define Maj(x, y, z) ((x & y) | (z & (x | y)))
#endif

__const_a8 ulong K[] = {
	0x428a2f98d728ae22UL, 0x7137449123ef65cdUL, 0xb5c0fbcfec4d3b2fUL,
	0xe9b5dba58189dbbcUL, 0x3956c25bf348b538UL, 0x59f111f1b605d019UL,
	0x923f82a4af194f9bUL, 0xab1c5ed5da6d8118UL, 0xd807aa98a3030242UL,
	0x12835b0145706fbeUL, 0x243185be4ee4b28cUL, 0x550c7dc3d5ffb4e2UL,
	0x72be5d74f27b896fUL, 0x80deb1fe3b1696b1UL, 0x9bdc06a725c71235UL,
	0xc19bf174cf692694UL, 0xe49b69c19ef14ad2UL, 0xefbe4786384f25e3UL,
	0x0fc19dc68b8cd5b5UL, 0x240ca1cc77ac9c65UL, 0x2de92c6f592b0275UL,
	0x4a7484aa6ea6e483UL, 0x5cb0a9dcbd41fbd4UL, 0x76f988da831153b5UL,
	0x983e5152ee66dfabUL, 0xa831c66d2db43210UL, 0xb00327c898fb213fUL,
	0xbf597fc7beef0ee4UL, 0xc6e00bf33da88fc2UL, 0xd5a79147930aa725UL,
	0x06ca6351e003826fUL, 0x142929670a0e6e70UL, 0x27b70a8546d22ffcUL,
	0x2e1b21385c26c926UL, 0x4d2c6dfc5ac42aedUL, 0x53380d139d95b3dfUL,
	0x650a73548baf63deUL, 0x766a0abb3c77b2a8UL, 0x81c2c92e47edaee6UL,
	0x92722c851482353bUL, 0xa2bfe8a14cf10364UL, 0xa81a664bbc423001UL,
	0xc24b8b70d0f89791UL, 0xc76c51a30654be30UL, 0xd192e819d6ef5218UL,
	0xd69906245565a910UL, 0xf40e35855771202aUL, 0x106aa07032bbd1b8UL,
	0x19a4c116b8d2d0c8UL, 0x1e376c085141ab53UL, 0x2748774cdf8eeb99UL,
	0x34b0bcb5e19b48a8UL, 0x391c0cb3c5c95a63UL, 0x4ed8aa4ae3418acbUL,
	0x5b9cca4f7763e373UL, 0x682e6ff3d6b2b8a3UL, 0x748f82ee5defb2fcUL,
	0x78a5636f43172f60UL, 0x84c87814a1f0ab72UL, 0x8cc702081a6439ecUL,
	0x90befffa23631e28UL, 0xa4506cebde82bde9UL, 0xbef9a3f7b2c67915UL,
	0xc67178f2e372532bUL, 0xca273eceea26619cUL, 0xd186b8c721c0c207UL,
	0xeada7dd6cde0eb1eUL, 0xf57d4f7fee6ed178UL, 0x06f067aa72176fbaUL,
	0x0a637dc5a2c898a6UL, 0x113f9804bef90daeUL, 0x1b710b35131c471bUL,
	0x28db77f523047d84UL, 0x32caab7b40c72493UL, 0x3c9ebe0a15c9bebcUL,
	0x431d67c49c100d4cUL, 0x4cc5d4becb3e42b6UL, 0x597f299cfc657e2aUL,
	0x5fcb6fab3ad6faecUL, 0x6c44198c4a475817UL
};

#if gpu_amd(DEVICE_INFO) && SCALAR && defined(cl_amd_media_ops) && !__MESA__
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
/* Bug seen with multiples of 8 */
#define ror64(x, n)	(n % 8 ? \
	 ((n) < 32 ? (amd_bitalign((uint)((x) >> 32), (uint)(x), (uint)(n)) | ((ulong)amd_bitalign((uint)(x), (uint)((x) >> 32), (uint)(n)) << 32)) : (amd_bitalign((uint)(x), (uint)((x) >> 32), (uint)(n) - 32) | ((ulong)amd_bitalign((uint)((x) >> 32), (uint)(x), (uint)(n) - 32) << 32))) : \
	 rotate(x, (ulong)(64 - n)) \
		)
#elif __OS_X__ && gpu_nvidia(DEVICE_INFO)
/* Bug workaround for OSX nvidia 10.2.7 310.41.25f01 */
#define ror64(x, n)       ((x >> n) | (x << (64 - n)))
#else
#define ror64(x, n)       rotate(x, (ulong)(64 - n))
#endif

#if 0 && SHA2_H_SHA512_LUT3
/* LOP3.LUT alternative - does no good */
#define SHA2_H_Sigma0_64(x) lut3_64(ror64(x, 28), ror64(x, 34), ror64(x, 39), 0x96)
#define SHA2_H_Sigma1_64(x) lut3_64(ror64(x, 14), ror64(x, 18), ror64(x, 41), 0x96)
#elif 0
/*
 * These Sigma alternatives are derived from "Fast SHA-256 Implementations
 * on Intel Architecture Processors" whitepaper by Intel (rewritten here
 * for SHA-512 by magnum). They were intended for use with destructive rotate
 * (minimizing register copies) but might be better or worse on different
 * hardware for other reasons.
 */
#define SHA2_H_Sigma0_64(x) (ror64(ror64(ror64(x, 5) ^ x, 6) ^ x, 28))
#define SHA2_H_Sigma1_64(x) (ror64(ror64(ror64(x, 23) ^ x, 4) ^ x, 14))
#else
/* Original SHA-2 function */
#define SHA2_H_Sigma0_64(x) (ror64(x, 28) ^ ror64(x, 34) ^ ror64(x, 39))
#define SHA2_H_Sigma1_64(x) (ror64(x, 14) ^ ror64(x, 18) ^ ror64(x, 41))
#endif

#if 0 && SHA2_H_SHA512_LUT3
/* LOP3.LUT alternative - does no good */
#define SHA2_H_sigma0_64(x) lut3_64(ror64(x, 1), ror64(x, 8), (x >> 7), 0x96)
#define SHA2_H_sigma1_64(x) lut3_64(ror64(x, 19), ror64(x, 61), (x >> 6), 0x96)
#elif 0
/*
 * These sigma alternatives are from "Fast SHA-512 Implementations on Intel
 * Architecture Processors" whitepaper by Intel. They were intended for use
 * with destructive shifts (minimizing register copies) but might be better
 * or worse on different hardware for other reasons. They will likely always
 * be a regression when we have 64-bit hardware rotate instructions - but
 * that probably doesn't exist for current GPU's as of now since they're all
 * 32-bit (and may not even have 32-bit rotate for that matter).
 */
#define SHA2_H_sigma0_64(x) ((((((x >> 1) ^ x) >> 6) ^ x) >> 1) ^ (((x << 7) ^ x) << 56))
#define SHA2_H_sigma1_64(x) ((((((x >> 42) ^ x) >> 13) ^ x) >> 6) ^ (((x << 42) ^ x) << 3))
#else
/* Original SHA-2 function */
#define SHA2_H_sigma0_64(x) (ror64(x, 1)  ^ ror64(x, 8) ^ (x >> 7))
#define SHA2_H_sigma1_64(x) (ror64(x, 19) ^ ror64(x, 61) ^ (x >> 6))
#endif

#define SHA2_INIT_A	0x6a09e667f3bcc908UL
#define SHA2_INIT_B	0xbb67ae8584caa73bUL
#define SHA2_INIT_C	0x3c6ef372fe94f82bUL
#define SHA2_INIT_D	0xa54ff53a5f1d36f1UL
#define SHA2_INIT_E	0x510e527fade682d1UL
#define SHA2_INIT_F	0x9b05688c2b3e6c1fUL
#define SHA2_INIT_G	0x1f83d9abfb41bd6bUL
#define SHA2_INIT_H	0x5be0cd19137e2179UL

#define ROUND512_A(a, b, c, d, e, f, g, h, ki, wi)	\
	t = (ki) + (wi) + (h) + SHA2_H_Sigma1_64(e) + Ch((e), (f), (g)); \
	d += (t); h = (t) + SHA2_H_Sigma0_64(a) + Maj((a), (b), (c));

#define ROUND512_Z(a, b, c, d, e, f, g, h, ki)	\
	t = (ki) + (h) + SHA2_H_Sigma1_64(e) + Ch((e), (f), (g)); \
	d += (t); h = (t) + SHA2_H_Sigma0_64(a) + Maj((a), (b), (c));

#define ROUND512_B(a, b, c, d, e, f, g, h, ki, wi, wj, wk, wl, wm)	  \
	wi = SHA2_H_sigma1_64(wj) + SHA2_H_sigma0_64(wk) + wl + wm; \
	t = (ki) + (wi) + (h) + SHA2_H_Sigma1_64(e) + Ch((e), (f), (g)); \
	d += (t); h = (t) + SHA2_H_Sigma0_64(a) + Maj((a), (b), (c));

#define SHA2_H_SHA512(A, B, C, D, E, F, G, H, W)	  \
	ROUND512_A(A,B,C,D,E,F,G,H,K[0],W[0]) \
	ROUND512_A(H,A,B,C,D,E,F,G,K[1],W[1]) \
	ROUND512_A(G,H,A,B,C,D,E,F,K[2],W[2]) \
	ROUND512_A(F,G,H,A,B,C,D,E,K[3],W[3]) \
	ROUND512_A(E,F,G,H,A,B,C,D,K[4],W[4]) \
	ROUND512_A(D,E,F,G,H,A,B,C,K[5],W[5]) \
	ROUND512_A(C,D,E,F,G,H,A,B,K[6],W[6]) \
	ROUND512_A(B,C,D,E,F,G,H,A,K[7],W[7]) \
	ROUND512_A(A,B,C,D,E,F,G,H,K[8],W[8]) \
	ROUND512_A(H,A,B,C,D,E,F,G,K[9],W[9]) \
	ROUND512_A(G,H,A,B,C,D,E,F,K[10],W[10]) \
	ROUND512_A(F,G,H,A,B,C,D,E,K[11],W[11]) \
	ROUND512_A(E,F,G,H,A,B,C,D,K[12],W[12]) \
	ROUND512_A(D,E,F,G,H,A,B,C,K[13],W[13]) \
	ROUND512_A(C,D,E,F,G,H,A,B,K[14],W[14]) \
	ROUND512_A(B,C,D,E,F,G,H,A,K[15],W[15]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[16],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[17],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[18],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[19],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[20],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[21],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[22],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[23],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[24],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[25],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[26],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[27],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[28],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[29],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[30],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[31],W[15],  W[13],W[0],W[15],W[8]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[32],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[33],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[34],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[35],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[36],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[37],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[38],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[39],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[40],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[41],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[42],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[43],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[44],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[45],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[46],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[47],W[15],  W[13],W[0],W[15],W[8]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[48],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[49],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[50],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[51],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[52],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[53],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[54],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[55],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[56],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[57],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[58],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[59],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[60],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[61],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[62],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[63],W[15],  W[13],W[0],W[15],W[8]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[64],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[65],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[66],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[67],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[68],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[69],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[70],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[71],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[72],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[73],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[74],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[75],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[76],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[77],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[78],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[79],W[15],  W[13],W[0],W[15],W[8])

#define z 0UL
//W[9]-W[14] are zeros
#define SHA2_H_SHA512_ZEROS(A, B, C, D, E, F, G, H, W)	  \
	ROUND512_A(A,B,C,D,E,F,G,H,K[0],W[0]) \
	ROUND512_A(H,A,B,C,D,E,F,G,K[1],W[1]) \
	ROUND512_A(G,H,A,B,C,D,E,F,K[2],W[2]) \
	ROUND512_A(F,G,H,A,B,C,D,E,K[3],W[3]) \
	ROUND512_A(E,F,G,H,A,B,C,D,K[4],W[4]) \
	ROUND512_A(D,E,F,G,H,A,B,C,K[5],W[5]) \
	ROUND512_A(C,D,E,F,G,H,A,B,K[6],W[6]) \
	ROUND512_A(B,C,D,E,F,G,H,A,K[7],W[7]) \
	ROUND512_A(A,B,C,D,E,F,G,H,K[8],W[8]) \
	ROUND512_Z(H,A,B,C,D,E,F,G,K[9]) \
	ROUND512_Z(G,H,A,B,C,D,E,F,K[10]) \
	ROUND512_Z(F,G,H,A,B,C,D,E,K[11]) \
	ROUND512_Z(E,F,G,H,A,B,C,D,K[12]) \
	ROUND512_Z(D,E,F,G,H,A,B,C,K[13]) \
	ROUND512_Z(C,D,E,F,G,H,A,B,K[14]) \
	ROUND512_A(B,C,D,E,F,G,H,A,K[15],W[15]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[16],W[0],  z,W[1],W[0],z) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[17],W[1],  W[15],W[2],W[1],z) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[18],W[2],  W[0],W[3],W[2],z) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[19],W[3],  W[1],W[4],W[3],z) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[20],W[4],  W[2],W[5],W[4],z) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[21],W[5],  W[3],W[6],W[5],z) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[22],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[23],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[24],W[8],  W[6],z,W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[25],W[9],  W[7],z,z,W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[26],W[10],  W[8],z,z,W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[27],W[11],  W[9],z,z,W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[28],W[12],  W[10],z,z,W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[29],W[13],  W[11],z,z,W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[30],W[14],  W[12],W[15],z,W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[31],W[15],  W[13],W[0],W[15],W[8]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[32],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[33],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[34],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[35],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[36],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[37],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[38],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[39],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[40],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[41],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[42],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[43],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[44],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[45],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[46],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[47],W[15],  W[13],W[0],W[15],W[8]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[48],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[49],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[50],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[51],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[52],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[53],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[54],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[55],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[56],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[57],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[58],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[59],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[60],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[61],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[62],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[63],W[15],  W[13],W[0],W[15],W[8]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[64],W[0],  W[14],W[1],W[0],W[9]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[65],W[1],  W[15],W[2],W[1],W[10]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[66],W[2],  W[0],W[3],W[2],W[11]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[67],W[3],  W[1],W[4],W[3],W[12]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[68],W[4],  W[2],W[5],W[4],W[13]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[69],W[5],  W[3],W[6],W[5],W[14]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[70],W[6],  W[4],W[7],W[6],W[15]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[71],W[7],  W[5],W[8],W[7],W[0]) \
	ROUND512_B(A,B,C,D,E,F,G,H,K[72],W[8],  W[6],W[9],W[8],W[1]) \
	ROUND512_B(H,A,B,C,D,E,F,G,K[73],W[9],  W[7],W[10],W[9],W[2]) \
	ROUND512_B(G,H,A,B,C,D,E,F,K[74],W[10],  W[8],W[11],W[10],W[3]) \
	ROUND512_B(F,G,H,A,B,C,D,E,K[75],W[11],  W[9],W[12],W[11],W[4]) \
	ROUND512_B(E,F,G,H,A,B,C,D,K[76],W[12],  W[10],W[13],W[12],W[5]) \
	ROUND512_B(D,E,F,G,H,A,B,C,K[77],W[13],  W[11],W[14],W[13],W[6]) \
	ROUND512_B(C,D,E,F,G,H,A,B,K[78],W[14],  W[12],W[15],W[14],W[7]) \
	ROUND512_B(B,C,D,E,F,G,H,A,K[79],W[15],  W[13],W[0],W[15],W[8])

#ifdef SCALAR
#define sha512_single_s		sha512_single
#else

/* Raw'n'lean single-block SHA-512, no context[tm] */
inline void sha512_single_s(ulong *W, ulong *output)
{
	ulong A, B, C, D, E, F, G, H, t;

	A = SHA2_INIT_A;
	B = SHA2_INIT_B;
	C = SHA2_INIT_C;
	D = SHA2_INIT_D;
	E = SHA2_INIT_E;
	F = SHA2_INIT_F;
	G = SHA2_INIT_G;
	H = SHA2_INIT_H;

	SHA2_H_SHA512(A, B, C, D, E, F, G, H, W)

	output[0] = A + SHA2_INIT_A;
	output[1] = B + SHA2_INIT_B;
	output[2] = C + SHA2_INIT_C;
	output[3] = D + SHA2_INIT_D;
	output[4] = E + SHA2_INIT_E;
	output[5] = F + SHA2_INIT_F;
	output[6] = G + SHA2_INIT_G;
	output[7] = H + SHA2_INIT_H;
}
#endif

/* Raw'n'lean single-block SHA-512, no context[tm] */
inline void sha512_single(MAYBE_VECTOR_ULONG *W, MAYBE_VECTOR_ULONG *output)
{
	MAYBE_VECTOR_ULONG A, B, C, D, E, F, G, H, t;

	A = SHA2_INIT_A;
	B = SHA2_INIT_B;
	C = SHA2_INIT_C;
	D = SHA2_INIT_D;
	E = SHA2_INIT_E;
	F = SHA2_INIT_F;
	G = SHA2_INIT_G;
	H = SHA2_INIT_H;

	SHA2_H_SHA512(A, B, C, D, E, F, G, H, W)

	output[0] = A + SHA2_INIT_A;
	output[1] = B + SHA2_INIT_B;
	output[2] = C + SHA2_INIT_C;
	output[3] = D + SHA2_INIT_D;
	output[4] = E + SHA2_INIT_E;
	output[5] = F + SHA2_INIT_F;
	output[6] = G + SHA2_INIT_G;
	output[7] = H + SHA2_INIT_H;
}

inline void sha512_single_zeros(MAYBE_VECTOR_ULONG *W,
                                MAYBE_VECTOR_ULONG *output)
{
	MAYBE_VECTOR_ULONG A, B, C, D, E, F, G, H, t;

	A = SHA2_INIT_A;
	B = SHA2_INIT_B;
	C = SHA2_INIT_C;
	D = SHA2_INIT_D;
	E = SHA2_INIT_E;
	F = SHA2_INIT_F;
	G = SHA2_INIT_G;
	H = SHA2_INIT_H;

	SHA2_H_SHA512_ZEROS(A, B, C, D, E, F, G, H, W)

	output[0] = A + SHA2_INIT_A;
	output[1] = B + SHA2_INIT_B;
	output[2] = C + SHA2_INIT_C;
	output[3] = D + SHA2_INIT_D;
	output[4] = E + SHA2_INIT_E;
	output[5] = F + SHA2_INIT_F;
	output[6] = G + SHA2_INIT_G;
	output[7] = H + SHA2_INIT_H;
}

#endif /* _OPENCL_SHA2_H */
// File: opencl/sha512_kernel.cl
/*
 * This software is Copyright (c) 2012 Myrice <qqlddg at gmail dot com>
 * and it is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, with or without modification, are permitted.
 */


typedef struct { // notice memory align problem
	uint32_t buffer[32];	//1024 bits
	uint32_t buflen;
} sha512_ctx;

inline void sha512(uchar *password, uint8_t pass_len,
	uchar *hash, uint32_t offset)
{
	__private sha512_ctx ctx;
	uint32_t *b32 = ctx.buffer;

	//set password to buffer
	for (uint32_t i = 0; i < pass_len; i++) {
		PUTCHAR(b32,i,password[i]);
	}
	ctx.buflen = pass_len;

	//append 1 to ctx buffer
	uint32_t length = ctx.buflen;
	PUTCHAR(b32, length, 0x80);
	while((++length & 3) != 0)  {
		PUTCHAR(b32, length, 0);
	}

	uint32_t *buffer32 = b32+(length>>2);
	for (uint32_t i = length; i < 128; i+=4) {// append 0 to 128
		*buffer32++=0;
	}

	//append length to buffer
	uint64_t *buffer64 = (uint64_t *)ctx.buffer;
	buffer64[15] = SWAP64((uint64_t) ctx.buflen * 8);

	// sha512 main
	int i;

	uint64_t a = 0x6a09e667f3bcc908UL;
	uint64_t b = 0xbb67ae8584caa73bUL;
	uint64_t c = 0x3c6ef372fe94f82bUL;
	uint64_t d = 0xa54ff53a5f1d36f1UL;
	uint64_t e = 0x510e527fade682d1UL;
	uint64_t f = 0x9b05688c2b3e6c1fUL;
	uint64_t g = 0x1f83d9abfb41bd6bUL;
	uint64_t h = 0x5be0cd19137e2179UL;

	__private uint64_t w[16];

	uint64_t *data = (uint64_t *) ctx.buffer;

#pragma unroll 16
	for (i = 0; i < 16; i++)
		w[i] = SWAP64(data[i]);

	uint64_t t1, t2;
#pragma unroll 16
	for (i = 0; i < 16; i++) {
		t1 = K[i] + w[i] + h + SHA2_H_Sigma1_64(e) + Ch(e, f, g);
		t2 = Maj(a, b, c) + SHA2_H_Sigma0_64(a);

		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}

#pragma unroll 61
	for (i = 16; i < 77; i++) {

		w[i & 15] =SHA2_H_sigma1_64(w[(i - 2) & 15]) + SHA2_H_sigma0_64(w[(i - 15) & 15]) + w[(i -16) & 15] + w[(i - 7) & 15];
		t1 = K[i] + w[i & 15] + h + SHA2_H_Sigma1_64(e) + Ch(e, f, g);
		t2 = Maj(a, b, c) + SHA2_H_Sigma0_64(a);

		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}
	hash[offset] = SWAP64(a);
}

__kernel void kernel_cmp(
	__constant uint64_t *binary,
	__global uint64_t *hash,
	__global uint32_t *result)
{
	uint32_t idx = get_global_id(0);

	if (idx == 0)
		*result = 0;

	barrier(CLK_GLOBAL_MEM_FENCE);

	if (*binary == hash[idx])
		*result = 1;
}
