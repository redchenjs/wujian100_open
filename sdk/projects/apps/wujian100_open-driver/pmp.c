/*
 * pmp.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>
#include <stdbool.h>

// IOPMP Functions
#define PMP_RESET_BIT              (0x00000001)

#define PMP_ERR_W_BIT              (0x00000002)
#define PMP_ERR_R_BIT              (0x00000001)

#define PMP_CTRL_0_REG_BASE        (0x40100000UL)
#define PMP_CTRL_1_REG_BASE        (0x40100004UL)

#define PMP_STAT_0_REG_BASE        (0x40100008UL)
#define PMP_STAT_1_REG_BASE        (0x4010000CUL)

#define PMP_DUMP_0_W_REG_BASE      (0x40100010UL)
#define PMP_DUMP_0_R_REG_BASE      (0x40100014UL)

#define PMP_DUMP_1_W_REG_BASE      (0x40100018UL)
#define PMP_DUMP_1_R_REG_BASE      (0x4010001CUL)

#define PMP_CONF_0_0_BASE_REG_BASE (0x40100020UL)
#define PMP_CONF_0_0_MASK_REG_BASE (0x40100024UL)
#define PMP_CONF_0_1_BASE_REG_BASE (0x40100028UL)
#define PMP_CONF_0_1_MASK_REG_BASE (0x4010002CUL)
#define PMP_CONF_0_2_BASE_REG_BASE (0x40100030UL)
#define PMP_CONF_0_2_MASK_REG_BASE (0x40100034UL)
#define PMP_CONF_0_3_BASE_REG_BASE (0x40100038UL)
#define PMP_CONF_0_3_MASK_REG_BASE (0x4010003CUL)
#define PMP_CONF_0_4_BASE_REG_BASE (0x40100040UL)
#define PMP_CONF_0_4_MASK_REG_BASE (0x40100044UL)
#define PMP_CONF_0_5_BASE_REG_BASE (0x40100048UL)
#define PMP_CONF_0_5_MASK_REG_BASE (0x4010004CUL)
#define PMP_CONF_0_6_BASE_REG_BASE (0x40100050UL)
#define PMP_CONF_0_6_MASK_REG_BASE (0x40100054UL)
#define PMP_CONF_0_7_BASE_REG_BASE (0x40100058UL)
#define PMP_CONF_0_7_MASK_REG_BASE (0x4010005CUL)

#define PMP_CONF_1_0_BASE_REG_BASE (0x40100060UL)
#define PMP_CONF_1_0_MASK_REG_BASE (0x40100064UL)
#define PMP_CONF_1_1_BASE_REG_BASE (0x40100068UL)
#define PMP_CONF_1_1_MASK_REG_BASE (0x4010006CUL)
#define PMP_CONF_1_2_BASE_REG_BASE (0x40100070UL)
#define PMP_CONF_1_2_MASK_REG_BASE (0x40100074UL)
#define PMP_CONF_1_3_BASE_REG_BASE (0x40100078UL)
#define PMP_CONF_1_3_MASK_REG_BASE (0x4010007CUL)
#define PMP_CONF_1_4_BASE_REG_BASE (0x40100080UL)
#define PMP_CONF_1_4_MASK_REG_BASE (0x40100084UL)
#define PMP_CONF_1_5_BASE_REG_BASE (0x40100088UL)
#define PMP_CONF_1_5_MASK_REG_BASE (0x4010008CUL)
#define PMP_CONF_1_6_BASE_REG_BASE (0x40100090UL)
#define PMP_CONF_1_6_MASK_REG_BASE (0x40100094UL)
#define PMP_CONF_1_7_BASE_REG_BASE (0x40100098UL)
#define PMP_CONF_1_7_MASK_REG_BASE (0x4010009CUL)

#define PMP_CTRL_0_REG        (*(volatile uint32_t *)PMP_CTRL_0_REG_BASE)
#define PMP_CTRL_1_REG        (*(volatile uint32_t *)PMP_CTRL_1_REG_BASE)

#define PMP_STAT_0_REG        (*(volatile uint32_t *)PMP_STAT_0_REG_BASE)
#define PMP_STAT_1_REG        (*(volatile uint32_t *)PMP_STAT_1_REG_BASE)

#define PMP_DUMP_0_W_REG      (*(volatile uint32_t *)PMP_DUMP_0_W_REG_BASE)
#define PMP_DUMP_0_R_REG      (*(volatile uint32_t *)PMP_DUMP_0_R_REG_BASE)

#define PMP_DUMP_1_W_REG      (*(volatile uint32_t *)PMP_DUMP_1_W_REG_BASE)
#define PMP_DUMP_1_R_REG      (*(volatile uint32_t *)PMP_DUMP_1_R_REG_BASE)

#define PMP_CONF_0_0_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_0_BASE_REG_BASE)
#define PMP_CONF_0_0_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_0_MASK_REG_BASE)
#define PMP_CONF_0_1_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_1_BASE_REG_BASE)
#define PMP_CONF_0_1_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_1_MASK_REG_BASE)
#define PMP_CONF_0_2_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_2_BASE_REG_BASE)
#define PMP_CONF_0_2_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_2_MASK_REG_BASE)
#define PMP_CONF_0_3_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_3_BASE_REG_BASE)
#define PMP_CONF_0_3_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_3_MASK_REG_BASE)
#define PMP_CONF_0_4_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_4_BASE_REG_BASE)
#define PMP_CONF_0_4_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_4_MASK_REG_BASE)
#define PMP_CONF_0_5_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_5_BASE_REG_BASE)
#define PMP_CONF_0_5_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_5_MASK_REG_BASE)
#define PMP_CONF_0_6_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_6_BASE_REG_BASE)
#define PMP_CONF_0_6_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_6_MASK_REG_BASE)
#define PMP_CONF_0_7_BASE_REG (*(volatile uint32_t *)PMP_CONF_0_7_BASE_REG_BASE)
#define PMP_CONF_0_7_MASK_REG (*(volatile uint32_t *)PMP_CONF_0_7_MASK_REG_BASE)

#define PMP_CONF_1_0_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_0_BASE_REG_BASE)
#define PMP_CONF_1_0_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_0_MASK_REG_BASE)
#define PMP_CONF_1_1_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_1_BASE_REG_BASE)
#define PMP_CONF_1_1_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_1_MASK_REG_BASE)
#define PMP_CONF_1_2_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_2_BASE_REG_BASE)
#define PMP_CONF_1_2_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_2_MASK_REG_BASE)
#define PMP_CONF_1_3_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_3_BASE_REG_BASE)
#define PMP_CONF_1_3_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_3_MASK_REG_BASE)
#define PMP_CONF_1_4_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_4_BASE_REG_BASE)
#define PMP_CONF_1_4_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_4_MASK_REG_BASE)
#define PMP_CONF_1_5_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_5_BASE_REG_BASE)
#define PMP_CONF_1_5_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_5_MASK_REG_BASE)
#define PMP_CONF_1_6_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_6_BASE_REG_BASE)
#define PMP_CONF_1_6_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_6_MASK_REG_BASE)
#define PMP_CONF_1_7_BASE_REG (*(volatile uint32_t *)PMP_CONF_1_7_BASE_REG_BASE)
#define PMP_CONF_1_7_MASK_REG (*(volatile uint32_t *)PMP_CONF_1_7_MASK_REG_BASE)

void pmp_init(void)
{
    PMP_CTRL_0_REG = PMP_RESET_BIT;
    PMP_CTRL_1_REG = PMP_RESET_BIT;

    PMP_CONF_0_0_BASE_REG = 0x20000000; // IRAM-APP1
    PMP_CONF_0_0_MASK_REG = 0xFFFF0000; // 0x20000000 - 0x2000FFFF
    PMP_CONF_0_1_BASE_REG = 0x00000000;
    PMP_CONF_0_1_MASK_REG = 0x00000000;
    PMP_CONF_0_2_BASE_REG = 0x00000000;
    PMP_CONF_0_2_MASK_REG = 0x00000000;
    PMP_CONF_0_3_BASE_REG = 0x00000000;
    PMP_CONF_0_3_MASK_REG = 0x00000000;
    PMP_CONF_0_4_BASE_REG = 0x00000000;
    PMP_CONF_0_4_MASK_REG = 0x00000000;
    PMP_CONF_0_5_BASE_REG = 0x00000000;
    PMP_CONF_0_5_MASK_REG = 0x00000000;
    PMP_CONF_0_6_BASE_REG = 0x00000000;
    PMP_CONF_0_6_MASK_REG = 0x00000000;
    PMP_CONF_0_7_BASE_REG = 0x00000000;
    PMP_CONF_0_7_MASK_REG = 0x00000000;

    PMP_CONF_1_0_BASE_REG = 0x20020000; // SRAM-APP1
    PMP_CONF_1_0_MASK_REG = 0xFFFF0000; // 0x20020000 - 0x2002FFFF
    PMP_CONF_1_1_BASE_REG = 0x40010000; // MAILBOX_0
    PMP_CONF_1_1_MASK_REG = 0xFFFF0000; // 0x40010000 - 0x4001FFFF
    PMP_CONF_1_2_BASE_REG = 0x40020000; // MAILBOX_1
    PMP_CONF_1_2_MASK_REG = 0xFFFF0000; // 0x40020000 - 0x4002FFFF
    PMP_CONF_1_3_BASE_REG = 0x40300000; // WS28XX
    PMP_CONF_1_3_MASK_REG = 0xFFFFF000; // 0x40300000 - 0x40300FFF
    PMP_CONF_1_4_BASE_REG = 0x60000000; // TIM_2
    PMP_CONF_1_4_MASK_REG = 0xFFFFFFE0; // 0x60000000 - 0x6000001F
    PMP_CONF_1_5_BASE_REG = 0x60018000; // GPIO
    PMP_CONF_1_5_MASK_REG = 0xFFFFF000; // 0x60018000 - 0x60018FFF
    PMP_CONF_1_6_BASE_REG = 0x60028000; // USI_1
    PMP_CONF_1_6_MASK_REG = 0xFFFFF000; // 0x60028000 - 0x60028FFF
    PMP_CONF_1_7_BASE_REG = 0x00000000;
    PMP_CONF_1_7_MASK_REG = 0x00000000;

    PMP_CTRL_0_REG = 0x01010000;
    PMP_CTRL_1_REG = 0x7f7f0000;
}

bool pmp_get_err_wr(uint8_t idx)
{
    if (idx) {
        return PMP_STAT_1_REG & PMP_ERR_W_BIT;
    } else {
        return PMP_STAT_0_REG & PMP_ERR_W_BIT;
    }
}

bool pmp_get_err_rd(uint8_t idx)
{
    if (idx) {
        return PMP_STAT_1_REG & PMP_ERR_R_BIT;
    } else {
        return PMP_STAT_0_REG & PMP_ERR_R_BIT;
    }
}

uint8_t pmp_get_hit_wr(uint8_t idx)
{
    if (idx) {
        return PMP_STAT_1_REG >> 24;
    } else {
        return PMP_STAT_0_REG >> 24;
    }
}

uint8_t pmp_get_hit_rd(uint8_t idx)
{
    if (idx) {
        return PMP_STAT_1_REG >> 16;
    } else {
        return PMP_STAT_0_REG >> 16;
    }
}

uint32_t pmp_get_dump_wr(uint8_t idx)
{
    if (idx) {
        return PMP_DUMP_1_W_REG;
    } else {
        return PMP_DUMP_0_W_REG;
    }
}

uint32_t pmp_get_dump_rd(uint8_t idx)
{
    if (idx) {
        return PMP_DUMP_1_R_REG;
    } else {
        return PMP_DUMP_0_R_REG;
    }
}
