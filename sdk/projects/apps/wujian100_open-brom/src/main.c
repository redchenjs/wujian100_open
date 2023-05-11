/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#include "time.h"
#include "syslog.h"

#include "drv_pwm.h"
#include "drv_gpio.h"
#include "drv_usart.h"

#include "mbedtls/md.h"
#include "mbedtls/rsa.h"
#include "mbedtls/platform.h"

// Global Variables
const void (*firmware_entry)(void) = (const void (*)())(0x80000000);

const char public_key_n[] = "A89D653A84AA19B57B44D6D447877F9A8EA6A824C6BEF3B51D9D4D2952A0E7F3ED8F8B2F55CFD8E7E6BAE65E16DC4C43BBE00E631AE4289E583902261485C953E2042DEEBDAF2F54B6DE9FF321C612A87A9F46EA30FA264846E79167BB22CC4090830FF16A56EAC4B236CBB7B6D2880B3BE1B1263EF1D85BC9C006CFE592C6995B6914ECF38B5B0AB5325847B10C8523B91BA1F01FF2EAC4F8602DC40F17465393CB2C8933FFE43687FC93A69B9D5CA824AC6A203F8375164102E82F2B060FFB8FA0E5B4DDBF971F39A5A2588F4DB38BCC709C709A86634A40D4BA116239A14343E6EEE7E08123208B381C751140EBAA2FCD52F5077721F32114898342202CB7";
const char public_key_e[] = "010001";

const unsigned char data_buf[] = {
    0x64, 0x65, 0x61, 0x64, 0x62, 0x65, 0x65, 0x66, 0x0a
};

const unsigned char sign_buf[] = {
    0x40, 0xCE, 0x18, 0x97, 0x0A, 0xF0, 0x1C, 0x49, 0xF9, 0x79, 0x45, 0xC6, 0xA4, 0xCB, 0xA8, 0xE9,
    0xB4, 0x71, 0x09, 0xB2, 0x7A, 0xC1, 0x60, 0x9A, 0xC2, 0xA5, 0x1C, 0x1A, 0x89, 0x7D, 0xBB, 0xA5,
    0xBE, 0x81, 0x2A, 0x0E, 0x69, 0x41, 0x42, 0x44, 0x24, 0xFB, 0xBD, 0x30, 0x94, 0x96, 0x80, 0x8F,
    0xB9, 0x04, 0xC1, 0xED, 0xA1, 0x42, 0x33, 0x33, 0xD2, 0xB6, 0xE2, 0x43, 0xB5, 0xBC, 0xEB, 0x2C,
    0xDE, 0xF3, 0x08, 0x99, 0x2D, 0xB9, 0x59, 0x8B, 0xB8, 0xB9, 0xB2, 0x56, 0x8D, 0x5A, 0x51, 0x68,
    0x09, 0xB3, 0xF3, 0xBE, 0x01, 0xA2, 0x6B, 0xBC, 0xC7, 0xF7, 0x44, 0x37, 0x73, 0xCA, 0xA5, 0xA0,
    0x20, 0x50, 0xEC, 0xBE, 0xF3, 0xE6, 0xC3, 0x21, 0x2E, 0xC7, 0x66, 0xBA, 0x50, 0xB1, 0x6F, 0xFF,
    0x73, 0x1F, 0xF1, 0x63, 0x13, 0x10, 0x11, 0x3B, 0x7A, 0x6D, 0x13, 0x2E, 0xF6, 0x5D, 0xB4, 0x51,
    0x2B, 0x8B, 0x60, 0x2A, 0x63, 0x09, 0x0C, 0xA3, 0x89, 0xD1, 0x5E, 0x6B, 0x40, 0x93, 0x62, 0xAA,
    0x2A, 0x51, 0xCA, 0xF7, 0x92, 0x23, 0xFD, 0x03, 0x50, 0x8C, 0xA7, 0xBB, 0x0B, 0xAD, 0xB1, 0x6A,
    0x11, 0x66, 0xCA, 0xA1, 0x1F, 0xEE, 0xC6, 0x8C, 0x74, 0xEA, 0x2B, 0x56, 0xF8, 0x1C, 0x69, 0x44,
    0xE8, 0xA0, 0xD3, 0xF5, 0x20, 0xAA, 0x7C, 0x71, 0xB0, 0x27, 0x4E, 0xE8, 0x81, 0x72, 0xD1, 0xD8,
    0xD6, 0x45, 0x46, 0xCD, 0xD6, 0xB5, 0x80, 0xE9, 0x60, 0x1A, 0x66, 0x1C, 0x1B, 0x43, 0x20, 0xFA,
    0x4A, 0xEA, 0x9D, 0x68, 0x50, 0x2A, 0x08, 0xB7, 0xCA, 0x3D, 0x60, 0x6D, 0xC5, 0xEF, 0x0E, 0x28,
    0x16, 0xA4, 0xE4, 0xF7, 0xB5, 0xCE, 0xAB, 0x89, 0x56, 0xA4, 0xE4, 0x12, 0xFE, 0xD8, 0xB7, 0x81,
    0x95, 0x26, 0x8D, 0x6C, 0x9F, 0xC4, 0xFE, 0x49, 0xA3, 0xEF, 0xC4, 0x3E, 0x50, 0xD5, 0x62, 0xFC,
};

// Core Functions
void delay_ms(int x)
{
    for (int i = x; i > 0; i--) {
        for (int j = 5000; j > 0; j--) {
            asm("nop");
        }
    }
}

uint32_t get_timestamp(void)
{
    struct timespec tp = {0};
    
    clock_gettime(CLOCK_MONOTONIC, &tp);
    
    return tp.tv_nsec / 1000;
}

void board_deinit(void)
{
    extern usart_handle_t console_handle;
    csi_usart_uninitialize(console_handle);

    clock_timer_stop();
    clock_timer_uninit();
}

// PWM Functions
#define PWM_TEST_CH 0

pwm_handle_t pwm_handle = NULL;

void pwm_init(void)
{
    pwm_handle = csi_pwm_initialize(PWM_TEST_CH);

    csi_pwm_config(pwm_handle, PWM_TEST_CH, 2500, 0);
}

void pwm_test(void)
{
    static int state = 0;

    if (pwm_handle) {
        state = !state;

        if (state) {
            csi_pwm_start(pwm_handle, PWM_TEST_CH);
        } else {
            csi_pwm_stop(pwm_handle, PWM_TEST_CH);
        }
    }
}

void pwm_deinit(void)
{
    csi_pwm_stop(pwm_handle, PWM_TEST_CH);
    csi_pwm_uninitialize(pwm_handle);
}

// GPIO Functions
#define GPIO_TEST_PIN 0

gpio_pin_handle_t pin_handle = NULL;

void gpio_init(void)
{
    pin_handle = csi_gpio_pin_initialize(GPIO_TEST_PIN, NULL);

    csi_gpio_pin_config_mode(pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(pin_handle, 0);
}

void gpio_toggle(void)
{
    static int state = 0;

    if (pin_handle) {
        state = !state;
        csi_gpio_pin_write(pin_handle, state);
    }
}

void gpio_deinit(void)
{
    csi_gpio_pin_write(pin_handle, 0);
    csi_gpio_pin_uninitialize(pin_handle);
}

// RSA / SHA-256 Signature
bool firmware_verify(void)
{
    mbedtls_rsa_context rsa;
    unsigned char hash[32] = {0};

    mbedtls_rsa_init(&rsa);

    mbedtls_printf("\n  . Reading public key from Boot ROM");

    if (mbedtls_mpi_read_string(&rsa.MBEDTLS_PRIVATE(N), 16, public_key_n) != 0 ||
        mbedtls_mpi_read_string(&rsa.MBEDTLS_PRIVATE(E), 16, public_key_e) != 0) {
        mbedtls_printf("\n  ! FAILED (Invalid RSA public key data)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    rsa.MBEDTLS_PRIVATE(len) = (mbedtls_mpi_bitlen(&rsa.MBEDTLS_PRIVATE(N)) + 7) >> 3;
    if (sizeof(sign_buf) != rsa.MBEDTLS_PRIVATE(len)) {
        mbedtls_printf("\n  ! FAILED (Invalid RSA signature format)\n\n", rsa.MBEDTLS_PRIVATE(len));
        mbedtls_rsa_free(&rsa);

        return false;
    }

    mbedtls_printf("\n  . Verifying the RSA/SHA-256 signature");

    if (mbedtls_md(mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), data_buf, sizeof(data_buf), hash) != 0) {
        mbedtls_printf("\n  ! FAILED (Unable to generate message-digest checksum)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    if (mbedtls_rsa_pkcs1_verify(&rsa, MBEDTLS_MD_SHA256, 32, hash, sign_buf) != 0) {
        mbedtls_printf("\n  ! FAILED (the signature is not valid)\n\n");
        mbedtls_rsa_free(&rsa);

        return false;
    }

    mbedtls_printf("\n  . OK (the signature is valid)\n\n");
    mbedtls_rsa_free(&rsa);

    return true;
}

int main(void)
{
    pwm_init();
    gpio_init();

    printf("(%u) brom: started.\n", get_timestamp());

    if (firmware_verify()) {
        printf("(%u) brom: firmware is signed, booting....\n", get_timestamp());

        for (int i = 20; i > 0; i--) {
            pwm_test();
            gpio_toggle();

            delay_ms(50);
        }
    } else {
        printf("(%u) brom: firmware is not signed.\n", get_timestamp());

        while (1) {
            pwm_test();
            gpio_toggle();

            delay_ms(200);
        }
    }

    pwm_deinit();
    gpio_deinit();
    board_deinit();

    firmware_entry();

    return 0;
}
