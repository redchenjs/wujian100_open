/*
 * pwm.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#include "pwm.h"
#include "drv_pwm.h"

// PWM Functions
#define PWM_TEST_CH 0

#define PWM_INIT_PULSE  2499
#define PWM_INIT_PERIOD 2500

static uint32_t pwm_pulse  = 0;
static uint32_t pwm_period = 0;

static pwm_handle_t pwm_handle = NULL;

void pwm_init(void)
{
    pwm_handle = csi_pwm_initialize(PWM_TEST_CH);

    pwm_config(PWM_INIT_PERIOD, PWM_INIT_PULSE);
    
    csi_pwm_start(pwm_handle, PWM_TEST_CH);
}

void pwm_config(uint32_t period, uint32_t pulse)
{
    pwm_pulse  = pulse;
    pwm_period = period;

    csi_pwm_config(pwm_handle, PWM_TEST_CH, pwm_period, pwm_pulse);
}

void pwm_toggle(void)
{
    static int state = 0;

    if (pwm_handle) {
        state = !state;

        if (state) {
            csi_pwm_config(pwm_handle, PWM_TEST_CH, pwm_period, 1);
        } else {
            csi_pwm_config(pwm_handle, PWM_TEST_CH, pwm_period, 2499);
        }
    }
}

void pwm_deinit(void)
{
    csi_pwm_stop(pwm_handle, PWM_TEST_CH);
    csi_pwm_uninitialize(pwm_handle);
}
