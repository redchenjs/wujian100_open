/*
 * sha2.h
 *
 *  Created on: 2023-08-13 22:01
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_SHA2_H_
#define INC_DRIVER_SHA2_H_

#include <stdint.h>

typedef enum {
    SHA2_MODE_SHA_224 = 0x00,
    SHA2_MODE_SHA_256 = 0x01,
    SHA2_MODE_SHA_384 = 0x02,
    SHA2_MODE_SHA_512 = 0x03
} sha2_mode_t;

typedef enum {
    SHA2_WORDS_SHA_224 = 7,
    SHA2_WORDS_SHA_256 = 8,
    SHA2_WORDS_SHA_384 = 12,
    SHA2_WORDS_SHA_512 = 16
} sha2_bytes_t;

extern void sha2_init(void);

extern void sha2_calc_data(sha2_mode_t mode, const uint8_t *block, uint32_t size, uint32_t *result);

#endif /* INC_DRIVER_SHA2_H_ */
