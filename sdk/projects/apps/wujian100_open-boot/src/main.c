/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#include <time.h>
#include <syslog.h>

#include "drv_pwm.h"
#include "drv_spi.h"
#include "drv_gpio.h"
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

// Reset Functions
#define RESET_CTRL_REG_BASE (0x60030000)

void reset_set_value(int val)
{
    if (val) {
        *(uint32_t *)RESET_CTRL_REG_BASE = 0x00000001;
    } else {
        *(uint32_t *)RESET_CTRL_REG_BASE = 0x00000000;
    }
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

// SPI Flash Functions
#define SPI_DEV_IDX 2
#define SPI_NSS_PIN 1

spi_handle_t spi_handle = NULL;
gpio_pin_handle_t spi_nss_pin_handle = NULL;

void spi_init(void)
{
    // init spi nss pin
    spi_nss_pin_handle = csi_gpio_pin_initialize(SPI_NSS_PIN, NULL);

    csi_gpio_pin_config_mode(spi_nss_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(spi_nss_pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(spi_nss_pin_handle, true);

    // init spi device
    spi_handle = csi_spi_initialize(SPI_DEV_IDX, NULL);

    csi_spi_config(spi_handle, 1000000, SPI_MODE_MASTER, SPI_FORMAT_CPOL0_CPHA0, SPI_ORDER_MSB2LSB, SPI_SS_MASTER_SW, 8);
    csi_spi_config_block_mode(spi_handle, 1);
}

int32_t spi_flash_read(spi_handle_t handle, uint32_t addr, void *data, uint32_t len)
{
    uint8_t command[4] = { 0x00 };

    command[0] = 0x03;
    command[1] = (addr >> 16) & 0xff;
    command[2] = (addr >> 8) & 0xff;
    command[3] = addr & 0xff;

    // set spi nss to active
    csi_gpio_pin_write(spi_nss_pin_handle, false);

    // send read data command
    csi_spi_send(handle, command, 4);

    // read data to buffer
    csi_spi_receive(handle, (uint8_t *)data, len);

    // set spi nss to inactive
    csi_gpio_pin_write(spi_nss_pin_handle, true);

    return len;
}

// RSA / SHA-256 Signature
bool firmware_verify(void *data, uint32_t data_size, uint8_t *sign, uint32_t sign_size)
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

int main(void)
{
    uint32_t firmware_app0_size = 0;
    uint32_t firmware_app1_size = 0;
    uint8_t firmware_app0_sign[256] = { 0 };
    uint8_t firmware_app1_sign[256] = { 0 };

    reset_set_value(0);

    spi_init();
    pwm_init();
    gpio_init();

    printf("brom: started.\n");

    // load firmware 0 size and sign
    spi_flash_read(spi_handle, FIRMWARE_SIZE_APP_0_ADDR, &firmware_app0_size, sizeof(firmware_app0_size));
    spi_flash_read(spi_handle, FIRMWARE_SIGN_APP_0_ADDR, firmware_app0_sign, sizeof(firmware_app0_sign));
    // load firmware 0 data
    spi_flash_read(spi_handle, FIRMWARE_DATA_APP_0_ADDR, firmware_app0, firmware_app0_size);

    printf("brom: firmware 0 loaded, size: %u\n", firmware_app0_size);

    // load firmware 1 size and sign
    spi_flash_read(spi_handle, FIRMWARE_SIZE_APP_1_ADDR, &firmware_app1_size, sizeof(firmware_app1_size));
    spi_flash_read(spi_handle, FIRMWARE_SIGN_APP_1_ADDR, firmware_app1_sign, sizeof(firmware_app1_sign));
    // load firmware 1 data
    spi_flash_read(spi_handle, FIRMWARE_DATA_APP_1_ADDR, firmware_app1, firmware_app1_size);

    printf("brom: firmware 1 loaded, size: %u\n", firmware_app1_size);

    if (firmware_verify(firmware_app0, firmware_app0_size, firmware_app0_sign, sizeof(firmware_app0_sign))) {
        printf("brom: firmware 0 is signed.\n");

        if (firmware_verify(firmware_app0, firmware_app0_size, firmware_app0_sign, sizeof(firmware_app1_sign))) {
            printf("brom: firmware 1 is signed.\n");

            for (int i = 20; i > 0; i--) {
                pwm_test();
                gpio_toggle();

                delay_ms(50);
            }
        } else {
            printf("brom: firmware 1 is not signed.\n");

            while (1) {
                pwm_test();
                gpio_toggle();

                delay_ms(400);
            }
        }
    } else {
        printf("brom: firmware 0 is not signed.\n");

        while (1) {
            pwm_test();
            gpio_toggle();

            delay_ms(200);
        }
    }

    printf("brom: boot from firmware 0...\n");

    pwm_deinit();
    gpio_deinit();
    board_deinit();

    firmware_entry();

    return 0;
}
