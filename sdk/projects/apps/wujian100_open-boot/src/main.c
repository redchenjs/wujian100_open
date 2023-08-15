/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <time.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#include "pmu.h"
#include "spi.h"
#include "pwm.h"
#include "beep.h"
#include "gpio.h"

#include "sha2.h"
#include "ws28xx.h"

#include "drv_usart.h"

#include "mbedtls/md.h"
#include "mbedtls/rsa.h"
#include "mbedtls/platform.h"

// Global Variables
#define FIRMWARE_SIZE_APP_0_MAX  (64 * 1024)
#define FIRMWARE_SIZE_APP_1_MAX  (64 * 1024)

#define FIRMWARE_LOAD_APP_0_ADDR (0x10000000)

#define FIRMWARE_DATA_APP_0_ADDR (0x00000000)
#define FIRMWARE_SIZE_APP_0_ADDR (0x000FFEFC)
#define FIRMWARE_SIGN_APP_0_ADDR (0x000FFF00)

#define FIRMWARE_LOAD_APP_1_ADDR (0x20000000)

#define FIRMWARE_DATA_APP_1_ADDR (0x00100000)
#define FIRMWARE_SIZE_APP_1_ADDR (0x001FFEFC)
#define FIRMWARE_SIGN_APP_1_ADDR (0x001FFF00)

uint8_t firmware_app0[FIRMWARE_SIZE_APP_0_MAX] __attribute__((section(".iram_app0")));
uint8_t firmware_app1[FIRMWARE_SIZE_APP_1_MAX] __attribute__((section(".iram_app1")));

const void (*firmware_entry)(void) = (const void (*)())(FIRMWARE_LOAD_APP_0_ADDR);

const char pubkey_n[] = "DC1B56F36E933EC234545C4715370B14CAE00EA9376E9F65DE2C1361F116F05A4C2FF556FF0052F8E2D3434FF5E843A6B246449DE6C8F04C7CA821EFFBAA1DBCC7A1B903A05B7671BB6D0FD8639D492C5B74C2C91510E3B006B227CBF14A694C21A98A4B1A2474613ECD29405863716CF3DF5D3160ED0B992A25B35626E67FF1AA9242ED3A1F7EAD7C638B26DBE3624B6712055E101C07761FA6EFE38D915006F52BB4D76E52F13EAD7D04B046FB4ACFC02A57E02CF28CC1AFC3D22B572669A99EE7D357B840BC8BFA4EB1BBAD287824D93AC259D59EBBAA798ED0F026E5A0E05392683A68B16964160DF9366AF79B0AA8D95FA996E636022E584863A3F4E0D1";
const char pubkey_e[] = "010001";

uint32_t data_blk_0[16] = {
    0x0a112001, 0x00000080, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x20000000
};

uint32_t data_blk_1[16] = {
    0x0a112001, 0x00000080, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x20020000
};

// Core Functions
extern void mdelay(uint32_t ms);

static void board_deinit(void)
{
    extern usart_handle_t console_handle;
    csi_usart_uninitialize(console_handle);

    clock_timer_stop();
    clock_timer_uninit();
}

// RSA / SHA-256 Signature
static bool firmware_verify(void *data, uint32_t data_size, uint8_t *sign, uint32_t sign_size)
{
    mbedtls_rsa_context rsa;
    unsigned char hash[32] = {0};

    mbedtls_rsa_init(&rsa);

    mbedtls_printf("\n  . Reading public key from Boot ROM");

    if (mbedtls_mpi_read_string(&rsa.MBEDTLS_PRIVATE(N), 16, pubkey_n) != 0 ||
        mbedtls_mpi_read_string(&rsa.MBEDTLS_PRIVATE(E), 16, pubkey_e) != 0) {
        mbedtls_printf("\n  ! FAILED (Invalid RSA public key data)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    rsa.MBEDTLS_PRIVATE(len) = (mbedtls_mpi_bitlen(&rsa.MBEDTLS_PRIVATE(N)) + 7) >> 3;
    if (sign_size != rsa.MBEDTLS_PRIVATE(len)) {
        mbedtls_printf("\n  ! FAILED (Invalid RSA signature format)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    mbedtls_printf("\n  . Verifying the RSA/SHA-256 signature");

    if (mbedtls_md(mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), data, data_size, hash) != 0) {
        mbedtls_printf("\n  ! FAILED (Unable to generate message-digest checksum)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    if (mbedtls_rsa_pkcs1_verify(&rsa, MBEDTLS_MD_SHA256, 32, hash, sign) != 0) {
        mbedtls_printf("\n  ! FAILED (the signature is not valid)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    mbedtls_printf("\n  . OK (the signature is valid)\n\n");
    mbedtls_rsa_free(&rsa);

    return true;
}

static void led_blink(int ms, int count)
{
    if (count < 0) {
        while (1) {
            pwm_toggle();
            beep_toggle();
            gpio_toggle();

            mdelay(ms);
        }
    } else {
        for (int i = count; i > 0; i--) {
            pwm_toggle();
            beep_toggle();
            gpio_toggle();

            mdelay(ms);
        }
    }
}

int main(void)
{
    uint32_t firmware_app0_size = 0;
    uint32_t firmware_app1_size = 0;
    uint8_t firmware_app0_sign[256] = { 0 };
    uint8_t firmware_app1_sign[256] = { 0 };
	uint8_t result[64] = { 0 };

    pmu_set_reset(0);

    spi_init();
    pwm_init();
    beep_init();
    gpio_init();
    ws28xx_init();

    ws28xx_write_block(ws28xx_pattern_wait);

	sha2_init();

	sha2_calc_data(SHA2_MODE_SHA_256, (uint8_t *)data_blk_0, 4, (uint32_t *)result);

    printf("brom: started.\n");

    // load firmware 0 size and sign
    spi_flash_read(FIRMWARE_SIZE_APP_0_ADDR, &firmware_app0_size, sizeof(firmware_app0_size));
    spi_flash_read(FIRMWARE_SIGN_APP_0_ADDR, firmware_app0_sign, sizeof(firmware_app0_sign));
    // load firmware 0 data
    if (0 < firmware_app0_size && firmware_app0_size <= FIRMWARE_SIZE_APP_0_MAX) {
        spi_flash_read(FIRMWARE_DATA_APP_0_ADDR, firmware_app0, firmware_app0_size);
    } else {
        printf("brom: firmware 0 has invalid size: %u\n", firmware_app0_size);

        led_blink(500, -1);
    }

    printf("brom: firmware 0 loaded, size: %u\n", firmware_app0_size);

    if (firmware_verify(firmware_app0, firmware_app0_size, firmware_app0_sign, sizeof(firmware_app0_sign))) {
        printf("brom: firmware 0 is signed.\n");

        // load firmware 1 size and sign
        spi_flash_read(FIRMWARE_SIZE_APP_1_ADDR, &firmware_app1_size, sizeof(firmware_app1_size));
        spi_flash_read(FIRMWARE_SIGN_APP_1_ADDR, firmware_app1_sign, sizeof(firmware_app1_sign));
        // load firmware 1 data
        if (0 < firmware_app1_size && firmware_app1_size <= FIRMWARE_SIZE_APP_1_MAX) {
            spi_flash_read(FIRMWARE_DATA_APP_1_ADDR, firmware_app1, firmware_app1_size);
        } else {
            printf("brom: firmware 1 has invalid size: %u\n", firmware_app1_size);

            led_blink(500, -1);
        }

        printf("brom: firmware 1 loaded, size: %u\n", firmware_app1_size);

        if (firmware_verify(firmware_app0, firmware_app0_size, firmware_app0_sign, sizeof(firmware_app1_sign))) {
            printf("brom: firmware 1 is signed.\n");

            led_blink(50, 20);
        } else {
            printf("brom: firmware 1 is not signed.\n");

            led_blink(250, -1);
        }
    } else {
        printf("brom: firmware 0 is not signed.\n");

        led_blink(250, -1);
    }

    printf("brom: boot from firmware 0...\n");

    pwm_deinit();
    gpio_deinit();
    board_deinit();

    firmware_entry();

    return 0;
}
