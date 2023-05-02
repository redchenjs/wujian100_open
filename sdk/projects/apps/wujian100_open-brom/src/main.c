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

#include "csi_core.h"
#include "csi_config.h"

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

int main(void)
{
    int firmware_ok = 0;
    void (*firmware_entry)(void) = (void (*)())(0x80000000);

    pwm_init();
    gpio_init();

    printf("(%u) brom: started.\n", get_timestamp());

    if (firmware_ok) {
        printf("(%u) brom: firmware is signed, loading....\n", get_timestamp());

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

    firmware_entry();

    return 0;
}
