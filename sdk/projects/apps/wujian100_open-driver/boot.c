/*
 * boot.c
 *
 *  Created on: 2023-08-15 22:26
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#include "drv_gpio.h"

// GPIO Functions
#define BOOT_FLASH_PIN  8
#define BOOT_CRYPTO_PIN 9

static gpio_pin_handle_t flash_pin_handle  = NULL;
static gpio_pin_handle_t crypto_pin_handle = NULL;

static bool mode_flash  = false;
static bool mode_crypto = false;

void boot_init(void)
{
    // FLASH
    flash_pin_handle = csi_gpio_pin_initialize(BOOT_FLASH_PIN, NULL);

    csi_gpio_pin_config_mode(flash_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(flash_pin_handle, GPIO_DIRECTION_INPUT);

    // CRYPTO
    crypto_pin_handle = csi_gpio_pin_initialize(BOOT_CRYPTO_PIN, NULL);

    csi_gpio_pin_config_mode(crypto_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(crypto_pin_handle, GPIO_DIRECTION_INPUT);

    csi_gpio_pin_read(flash_pin_handle, &mode_flash);
    csi_gpio_pin_read(crypto_pin_handle, &mode_crypto);
}

bool boot_get_mode_flash(void)
{
    return mode_flash;
}

bool boot_get_mode_crypto(void)
{
    return mode_crypto;
}
