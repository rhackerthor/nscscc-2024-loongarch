#ifndef __CSTD_MACRO_H__
#define __CSTD_MACRO_H__

/* max and min */
#define MAX(X, Y) ((X) > (Y) ? (X) : (Y))
#define MIN(X, Y) ((X) < (Y) ? (X) : (Y))

#define BITMASK(bits) ((1ull << (bits)) - 1)
#define BITS(x, hi, lo) (((x) >> (lo)) & BITMASK((hi) - (lo) + 1))
#define SEXT(x, len) ({ struct { int64_t n : len; } __x = { .n = (int64_t) x }; (uint64_t)__x.n; })

/* string */
#define STRLEN(str) (int)(sizeof(str) - 1)

/* arrange length */
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

/* macro range */
#define RANGE(X, L, R) (((L) <= (X) && (X) < R) ? true : false)

/* macro concatenation */
#define concat_temp(x, y) x ## y
#define concat(x, y) concat_temp(x, y)
#define concat3(x, y, z) concat(concat(x, y), z)
#define concat4(x, y, z, w) concat3(concat(x, y), z, w)
#define concat5(x, y, z, v, w) concat4(concat(x, y), z, v, w)

#endif