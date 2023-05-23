/*
 * pmu.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>

// PMU Functions
#define PMU_CTRL_REG_BASE (0x60030000)
#define PMU_RST_N_BIT     (0x00000001)

#define PMU_CTRL_REG      (*(volatile uint32_t *)PMU_CTRL_REG_BASE)

void pmu_set_reset(int val)
{
    if (val) {
        PMU_CTRL_REG |= PMU_RST_N_BIT;
    } else {
        PMU_CTRL_REG &=~PMU_RST_N_BIT;
    }
}
