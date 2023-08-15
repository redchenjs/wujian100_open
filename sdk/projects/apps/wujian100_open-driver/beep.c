/*
 * beep.c
 *
 *  Created on: 2023-08-07 15:31
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>

#include "drv_gpio.h"

// BEEP Functions
#define BEEP_TEST_PIN 7

static gpio_pin_handle_t pin_handle = NULL;

void beep_init(void)
{
    pin_handle = csi_gpio_pin_initialize(BEEP_TEST_PIN, NULL);

    csi_gpio_pin_config_mode(pin_handle, GPIO_MODE_PULLDOWN);
    csi_gpio_pin_config_direction(pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(pin_handle, 0);
}

void beep_toggle(void)
{
    static int state = 0;

    if (pin_handle) {
        state = !state;
        csi_gpio_pin_write(pin_handle, state);
    }
}

void beep_deinit(void)
{
    csi_gpio_pin_write(pin_handle, 0);
    csi_gpio_pin_uninitialize(pin_handle);
}
