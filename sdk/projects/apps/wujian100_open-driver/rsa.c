/*
 * rsa.c
 *
 *  Created on: 2023-08-15 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

// RSA Functions
#define RSA_START_REG 	(*(volatile uint32_t *)0x78000000UL)
#define RSA_FINISH_REG  (*(volatile uint32_t *)0x78000004UL)
#define RSA_DATA_REG 	(*(volatile uint32_t *)0x78000010UL)

void rsa_init(void) { }

void rsa_calc_data(const uint32_t *input, uint32_t *result)
{
    for (int i = 0; i < 64; i++) {
        RSA_DATA_REG = input[i];
    }

    RSA_START_REG = 0xffff;

    while (RSA_FINISH_REG == 0);

    for (int i = 0; i < 64; i++) {
        result[i] = RSA_DATA_REG;
    }
}
