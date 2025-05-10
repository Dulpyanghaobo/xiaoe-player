/*
Copyright 2019, Tencent Technology (Shenzhen) Co Ltd
Description: This file is part of the Tencent SM (Pro Version) Library.
*/

#ifndef HEADER_SM_H
#define HEADER_SM_H

#ifdef OS_ANDROID
#ifdef DEBUG
#include <android/log.h>
#endif /* DEBUG */
#endif /* OS_ANDROID */

#include <stdint.h>
#include <stddef.h>
#include <time.h>

namespace yt_sdk{

#undef SMLib_EXPORT
#if defined (_WIN32) && !defined (_WIN_STATIC)
#if defined(SMLib_EXPORTS)
#define  SMLib_EXPORT __declspec(dllexport)
#else
#define  SMLib_EXPORT __declspec(dllimport)
#endif
#else /* defined (_WIN32) */
#define SMLib_EXPORT
#endif

#define SM3_DIGEST_LENGTH  32
#define SM3_HMAC_SIZE    (SM3_DIGEST_LENGTH)
  
#define TENCENTSM_VERSION ("1.7.3-2")


typedef struct {
  uint32_t digest[8];
  int nblocks;
  unsigned char block[64];
  int num;
} sm3_ctx_t;
// typedef struct stHmacSm3Ctx TstHmacSm3Ctx;

/* ---------------------------------------------------------------- 以下为SM2/SM3/SM4通用能力接口 ---------------------------------------------------------------- */

SMLib_EXPORT const char* version(void);

/**
 SM3上下文结构体的大小
 */
SMLib_EXPORT int SM3CtxSize(void);

/**
 SM3 hash算法，3个接口用法与OpenSSL的MD5算法的接口保持一致。
 digest至少需要分配32字节
 */
SMLib_EXPORT int SM3Init(sm3_ctx_t *ctx);
SMLib_EXPORT int SM3Update(sm3_ctx_t *ctx, const unsigned char* data, size_t data_len);
SMLib_EXPORT int SM3Final(sm3_ctx_t *ctx, unsigned char *digest);

/**
 SM3 hash算法， 内部依次调用了init update和final三个接口
 */
SMLib_EXPORT int SM3(const unsigned char *data, size_t datalen, unsigned char *digest);

} // namespace
#endif
