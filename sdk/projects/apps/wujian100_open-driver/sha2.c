/*
 * sha2.c
 *
 *  Created on: 2023-08-13 22:01
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#include "sha2.h"

// SHA2 Functions
#define SHA2_RSTN_BIT               (0x00000001)

#define SHA2_LAST_BIT               (0x00000001)
#define SHA2_READ_BIT               (0x00000008)

#define SHA2_NEXT_BIT               (0x40000000)
#define SHA2_DONE_BIT               (0x80000000)

#define SHA2_CTRL_0_REG_BASE        (0x40200000UL)
#define SHA2_CTRL_1_REG_BASE        (0x40200004UL)

#define SHA2_DATA_I_LO_REG_BASE     (0x40200008UL)
#define SHA2_DATA_I_HI_REG_BASE     (0x4020000CUL)

#define SHA2_DATA_O_LO_REG_BASE     (0x40200010UL)
#define SHA2_DATA_O_HI_REG_BASE     (0x40200014UL)

#define SHA2_CTRL_0_REG     (*(volatile uint32_t *)SHA2_CTRL_0_REG_BASE)
#define SHA2_CTRL_1_REG     (*(volatile uint32_t *)SHA2_CTRL_1_REG_BASE)

#define SHA2_DATA_I_LO_REG  (*(volatile uint32_t *)SHA2_DATA_I_LO_REG_BASE)
#define SHA2_DATA_I_HI_REG  (*(volatile uint32_t *)SHA2_DATA_I_HI_REG_BASE)

#define SHA2_DATA_O_LO_REG  (*(volatile uint32_t *)SHA2_DATA_O_LO_REG_BASE)
#define SHA2_DATA_O_HI_REG  (*(volatile uint32_t *)SHA2_DATA_O_HI_REG_BASE)

void sha2_init(void)
{
    SHA2_CTRL_0_REG = 0x00000000;
    SHA2_CTRL_0_REG = SHA2_RSTN_BIT;
}

void sha2_write_block_fill_1(uint8_t *temp, sha2_mode_t mode, uint32_t n_bytes, const uint8_t *block)
{
    while (!(SHA2_CTRL_1_REG & SHA2_NEXT_BIT));

    memset(temp, 0x00, 128);

    switch (mode) {
        case SHA2_MODE_SHA_224:
        case SHA2_MODE_SHA_256: {
            uint32_t remain = n_bytes % 64;

            memcpy(temp, block, remain);

            temp[remain] = 0x80;

            temp[63 - 0] = (n_bytes << 3);
            temp[63 - 1] = (n_bytes << 3) >> 8;
            temp[63 - 2] = (n_bytes << 3) >> 16;
            temp[63 - 3] = (n_bytes << 3) >> 24;

            for (int i = 0; i < 16; i++) {
				SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i);
				SHA2_DATA_I_HI_REG = 0x00000000;
            }

            break;
        }
        case SHA2_MODE_SHA_384:
        case SHA2_MODE_SHA_512: {
            uint32_t remain = n_bytes % 128;

            memcpy(temp, block, remain);

            temp[remain] = 0x80;

            temp[127 - 0] = (n_bytes << 3);
            temp[127 - 1] = (n_bytes << 3) >> 8;
            temp[127 - 2] = (n_bytes << 3) >> 16;
            temp[127 - 3] = (n_bytes << 3) >> 24;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i * 2 + 1);
                SHA2_DATA_I_HI_REG = *((uint32_t *)temp + i * 2);
            }

            break;
        }
        default: {
            break;
        }
    }
}

void sha2_write_block_fill_2a(uint8_t *temp, sha2_mode_t mode, uint32_t n_bytes, const uint8_t *block)
{
    while (!(SHA2_CTRL_1_REG & SHA2_NEXT_BIT));

    memset(temp, 0x00, 128);

    switch (mode) {
        case SHA2_MODE_SHA_224:
        case SHA2_MODE_SHA_256: {
            uint32_t remain = n_bytes % 64;

            memcpy(temp, block, remain);

            temp[remain] = 0x80;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i);
				SHA2_DATA_I_HI_REG = 0x00000000;
            }

            break;
        }
        case SHA2_MODE_SHA_384:
        case SHA2_MODE_SHA_512: {
            uint32_t remain = n_bytes % 128;

            memcpy(temp, block, remain);

            temp[remain] = 0x80;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i * 2 + 1);
                SHA2_DATA_I_HI_REG = *((uint32_t *)temp + i * 2);
            }

            break;
        }
        default: {
            break;
        }
    }
}

void sha2_write_block_fill_2b(uint8_t *temp, sha2_mode_t mode, uint32_t n_bytes)
{
    while (!(SHA2_CTRL_1_REG & SHA2_NEXT_BIT));

    memset(temp, 0x00, 128);

    switch (mode) {
        case SHA2_MODE_SHA_224:
        case SHA2_MODE_SHA_256: {
            temp[63 - 0] = (n_bytes << 3);
            temp[63 - 1] = (n_bytes << 3) >> 8;
            temp[63 - 2] = (n_bytes << 3) >> 16;
            temp[63 - 3] = (n_bytes << 3) >> 24;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i);
				SHA2_DATA_I_HI_REG = 0x00000000;
            }

            break;
        }
        case SHA2_MODE_SHA_384:
        case SHA2_MODE_SHA_512: {
            temp[127 - 0] = (n_bytes << 3);
            temp[127 - 1] = (n_bytes << 3) >> 8;
            temp[127 - 2] = (n_bytes << 3) >> 16;
            temp[127 - 3] = (n_bytes << 3) >> 24;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i * 2 + 1);
                SHA2_DATA_I_HI_REG = *((uint32_t *)temp + i * 2);
            }

            break;
        }
        default: {
            break;
        }
    }
}

void sha2_write_block_fill_3(uint8_t *temp, sha2_mode_t mode, uint32_t n_bytes)
{
    while (!(SHA2_CTRL_1_REG & SHA2_NEXT_BIT));

    memset(temp, 0x00, 128);

    switch (mode) {
        case SHA2_MODE_SHA_224:
        case SHA2_MODE_SHA_256: {
            temp[0] = 0x80;

            temp[63 - 0] = (n_bytes << 3);
            temp[63 - 1] = (n_bytes << 3) >> 8;
            temp[63 - 2] = (n_bytes << 3) >> 16;
            temp[63 - 3] = (n_bytes << 3) >> 24;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i);
				SHA2_DATA_I_HI_REG = 0x00000000;
            }

            break;
        }
        case SHA2_MODE_SHA_384:
        case SHA2_MODE_SHA_512: {
            temp[0] = 0x80;

            temp[127 - 0] = (n_bytes << 3);
            temp[127 - 1] = (n_bytes << 3) >> 8;
            temp[127 - 2] = (n_bytes << 3) >> 16;
            temp[127 - 3] = (n_bytes << 3) >> 24;

            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)temp + i * 2 + 1);
                SHA2_DATA_I_HI_REG = *((uint32_t *)temp + i * 2);
            }

            break;
        }
        default: {
            break;
        }
    }
}

void sha2_write_block(sha2_mode_t mode, const uint8_t *block)
{
    while (!(SHA2_CTRL_1_REG & SHA2_NEXT_BIT));

    switch (mode) {
        case SHA2_MODE_SHA_224:
        case SHA2_MODE_SHA_256: {
            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)block + i);
				SHA2_DATA_I_HI_REG = 0x00000000;
            }

            break;
        }
        case SHA2_MODE_SHA_384:
        case SHA2_MODE_SHA_512: {
            for (int i = 0; i < 16; i++) {
                SHA2_DATA_I_LO_REG = *((uint32_t *)block + i * 2 + 1);
                SHA2_DATA_I_HI_REG = *((uint32_t *)block + i * 2);
            }

            break;
        }
        default: {
            break;
        }
    }
}

void sha2_read_result(sha2_mode_t mode, uint32_t *result)
{
    uint32_t count = 0;

    while (!(SHA2_CTRL_1_REG & SHA2_DONE_BIT));

    switch (mode) {
        case SHA2_MODE_SHA_224: {
            count = 7;
            break;
        }
        case SHA2_MODE_SHA_256: {
            count = 8;
            break;
        }
        case SHA2_MODE_SHA_384: {
            count = 12;
            break;
        }
        case SHA2_MODE_SHA_512: {
            count = 16;
            break;
        }
        default: {
            count = 0;
            break;
        }
    }

    for (int i = 0; i < count; i++) {
        SHA2_CTRL_1_REG = SHA2_READ_BIT | (mode << 1);

        asm volatile (
            "nop;"
            "nop;"
            "nop;"
            "nop;"
        );

        result[i*2]   = SHA2_DATA_O_LO_REG;
		result[i*2+1] = SHA2_DATA_O_HI_REG;
    }

    for (int i = count; i < 16; i++) {
        SHA2_CTRL_1_REG = SHA2_READ_BIT | (mode << 1);
    }
}

void sha2_calc_data(sha2_mode_t mode, const uint8_t *block, uint32_t n_bytes, uint32_t *result)
{
    uint32_t cur = 0;
    uint32_t rem = n_bytes;
    uint8_t *temp = malloc(128);

    while (rem != 0) {
        switch (mode) {
            case SHA2_MODE_SHA_224:
            case SHA2_MODE_SHA_256: {
                if (rem <= (64 - 8 - 1)) {
					SHA2_CTRL_1_REG = mode << 1 | SHA2_LAST_BIT;

                    sha2_write_block_fill_1(temp, mode, n_bytes, block + cur);

                    rem = 0;
                } else if (rem <= (64 - 1)) {
                    SHA2_CTRL_1_REG = mode << 1;

                    sha2_write_block_fill_2a(temp, mode, n_bytes, block + cur);

                    SHA2_CTRL_1_REG = mode << 1 | SHA2_LAST_BIT;

                    sha2_write_block_fill_2b(temp, mode, n_bytes);

                    rem = 0;
                } else if (rem == 64) {
                    SHA2_CTRL_1_REG = mode << 1;

                    sha2_write_block(mode, block + cur);

                    SHA2_CTRL_1_REG = mode << 1 | SHA2_LAST_BIT;

                    sha2_write_block_fill_3(temp, mode, n_bytes);

                    rem = 0;
                } else {
                    SHA2_CTRL_1_REG = mode << 1;

                    sha2_write_block(mode, block + cur);

                    cur += 64;
                    rem -= 64;
                }

                break;
            }
            case SHA2_MODE_SHA_384:
            case SHA2_MODE_SHA_512: {
                if (rem <= (128 - 16 - 1)) {
                    SHA2_CTRL_1_REG = mode << 1 | SHA2_LAST_BIT;

                    sha2_write_block_fill_1(temp, mode, n_bytes, block + cur);

                    rem = 0;
                } else if (rem <= (128 - 1)) {
                    SHA2_CTRL_1_REG = mode << 1;

                    sha2_write_block_fill_2a(temp, mode, n_bytes, block + cur);

                    SHA2_CTRL_1_REG = mode << 1 | SHA2_LAST_BIT;

                    sha2_write_block_fill_2b(temp, mode, n_bytes);

                    rem = 0;
                } else if (rem == 128) {
                    SHA2_CTRL_1_REG = mode << 1;

                    sha2_write_block(mode, block + cur);

                    SHA2_CTRL_1_REG = mode << 1 | SHA2_LAST_BIT;

                    sha2_write_block_fill_3(temp, mode, n_bytes);

                    rem = 0;
                } else {
                    SHA2_CTRL_1_REG = mode << 1;

                    sha2_write_block(mode, block + cur);

                    cur += 128;
                    rem -= 128;
                }

                break;
            }
            default: {
                break;
            }
        }
    }

    sha2_read_result(mode, result);

    free(temp);
}
