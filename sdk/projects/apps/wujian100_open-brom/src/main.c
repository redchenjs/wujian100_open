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

int main(void)
{
    printf("(%u) brom: started.\n", get_timestamp());

    return 0;
}
