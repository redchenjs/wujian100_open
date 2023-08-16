/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <time.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "boot.h"

#include "pmu.h"
#include "spi.h"
#include "pwm.h"
#include "beep.h"
#include "gpio.h"

#include "rsa.h"
#include "sha2.h"
#include "ws28xx.h"
#include "ssd1331.h"

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
static bool firmware_verify_sw(void *data, uint32_t data_size, uint8_t *sign, uint32_t sign_size)
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

static bool firmware_verify_hw(void *data, uint32_t data_size, uint8_t *sign, uint32_t sign_size)
{
    uint8_t sign_hash[256] = { 0 };
    uint8_t calc_hash[128] = { 0 };

    // calculate firmware checksum
    sha2_calc_data(SHA2_MODE_SHA_256, data, data_size, (uint32_t *)calc_hash);

    printf("brom: firmware SHA-256 is ");
    for (int i = 0; i < SHA2_WORDS_SHA_256; i++) {
        printf("%08x", ((uint32_t *)calc_hash)[SHA2_WORDS_SHA_256 - 1 - i]);
    }
    printf("\n");

    // decrypto signature checksum
    for (int i = 0; i < 256; i++) {
        sign_hash[i] = sign[255 - i];
    }

    rsa_calc_data((const uint32_t *)sign_hash, (uint32_t *)sign_hash);

    printf("brom: signature SHA-256 is ");
    for (int i = 0; i < SHA2_WORDS_SHA_256; i++) {
        printf("%08x", ((uint32_t *)sign_hash)[SHA2_WORDS_SHA_256 - 1 - i]);
    }
    printf("\n");

    if (!memcmp(sign_hash, calc_hash, SHA2_WORDS_SHA_256 * 4)) {
        return true;
    } else {
        return false;
    }
}

static bool firmware_verify(bool mode, void *data, uint32_t data_size, uint8_t *sign, uint32_t sign_size)
{
    if (mode) {
        return firmware_verify_hw(data, data_size, sign, sign_size);
    } else {
        return firmware_verify_sw(data, data_size, sign, sign_size);
    }
}

static void display_show(int ms, int count, const uint32_t *pattern)
{
    if (count < 0) {
        ws28xx_write_block(pattern);

        while (1) {
            pwm_toggle();
            beep_toggle();
            gpio_toggle();

            mdelay(ms);
        }
    } else {
        ws28xx_write_block(pattern);

        for (int i = count; i > 0; i--) {
            pwm_toggle();
            beep_toggle();
            gpio_toggle();

            mdelay(ms);
        }

        ws28xx_clear();
    }
}

int main(void)
{
    bool mode_flash  = 0;
    bool mode_crypto = 0;

    uint32_t firmware_app0_size = 0;
    uint32_t firmware_app1_size = 0;

    uint8_t firmware_app0_sign[256] = { 0 };
    uint8_t firmware_app1_sign[256] = { 0 };

    boot_init();

    // Boot Mode
    mode_flash  = boot_get_mode_flash();
    mode_crypto = boot_get_mode_crypto();

    // Reset Core 1
    pmu_set_reset(0);

    spi_init();
    pwm_init();
    beep_init();
    gpio_init();

    rsa_init();
    sha2_init();
    ws28xx_init();

    printf("brom: started.\n");

    if (mode_flash) {
        printf("brom: using flash chip 1\n");
    } else {
        printf("brom: using flash chip 0\n");
    }

    if (mode_crypto) {
        printf("brom: using hardware crypto\n");
    } else {
        printf("brom: using software crypto\n");
    }

    ws28xx_write_block(ws28xx_pattern_wait);

    // load firmware 0 size and signature
    spi_flash_read(mode_flash, FIRMWARE_SIZE_APP_0_ADDR, &firmware_app0_size, sizeof(firmware_app0_size));
    spi_flash_read(mode_flash, FIRMWARE_SIGN_APP_0_ADDR, firmware_app0_sign, sizeof(firmware_app0_sign));

    // load firmware 0 data
    if (0 < firmware_app0_size && firmware_app0_size <= FIRMWARE_SIZE_APP_0_MAX) {
        spi_flash_read(mode_flash, FIRMWARE_DATA_APP_0_ADDR, firmware_app0, firmware_app0_size);
    } else {
        printf("brom: firmware 0 has invalid size: %u\n", firmware_app0_size);
        display_show(500, -1, ws28xx_pattern_none);
    }

    printf("brom: firmware 0 loaded, size: %u\n", firmware_app0_size);

    // verify firmware 0 signature
    if (firmware_verify(mode_crypto, firmware_app0, firmware_app0_size, firmware_app0_sign, sizeof(firmware_app0_sign))) {
        printf("brom: firmware 0 is signed.\n");

        // load firmware 1 size and signature
        spi_flash_read(mode_flash, FIRMWARE_SIZE_APP_1_ADDR, &firmware_app1_size, sizeof(firmware_app1_size));
        spi_flash_read(mode_flash, FIRMWARE_SIGN_APP_1_ADDR, firmware_app1_sign, sizeof(firmware_app1_sign));

        // load firmware 1 data
        if (0 < firmware_app1_size && firmware_app1_size <= FIRMWARE_SIZE_APP_1_MAX) {
            spi_flash_read(mode_flash, FIRMWARE_DATA_APP_1_ADDR, firmware_app1, firmware_app1_size);
        } else {
            printf("brom: firmware 1 has invalid size: %u\n", firmware_app1_size);
            display_show(500, -1, ws28xx_pattern_none);
        }

        printf("brom: firmware 1 loaded, size: %u\n", firmware_app1_size);

        // verify firmware 1 signature
        if (firmware_verify(mode_crypto, firmware_app1, firmware_app1_size, firmware_app1_sign, sizeof(firmware_app1_sign))) {
            printf("brom: firmware 1 is signed.\n");
            display_show(50, 20, ws28xx_pattern_pass);
        } else {
            printf("brom: firmware 1 is not signed.\n");
            display_show(250, -1, ws28xx_pattern_fail);
        }
    } else {
        printf("brom: firmware 0 is not signed.\n");
        display_show(250, -1, ws28xx_pattern_fail);
    }

    printf("brom: boot from firmware 0...\n");

    spi_deinit();
    pwm_deinit();
    gpio_deinit();
    board_deinit();

    firmware_entry();

    return 0;
}
