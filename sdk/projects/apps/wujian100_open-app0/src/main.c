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

int main(void)
{
    int loop_count = 1;

    printf("(%u) app0: started.\n", get_timestamp());

    pwm_init();

    printf("(%u) app0: start core 1...\n", get_timestamp());

    reset_set_value(1);

    do {
        printf("(%u) app0: loop count: %d\n", get_timestamp(), loop_count++);

        pwm_test();

        delay_ms(1000);
    } while (1);

    return 0;
}
