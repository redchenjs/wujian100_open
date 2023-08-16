/*
 * ws28xx.c
 *
 *  Created on: 2023-08-13 22:01
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>
#include <stdbool.h>

#include "ws28xx.h"

// WS28XX Functions
#define WS28XX_IDLE_BIT         (0x80000000)
#define WS28XX_RSTN_BIT         (0x00000001)

#define WS28XX_ADDR_BIT         (0x00000002)
#define WS28XX_SYNC_BIT         (0x00000001)

#define WS28XX_CTRL_0_REG_BASE  (0x40300000UL)
#define WS28XX_CTRL_1_REG_BASE  (0x40300004UL)
#define WS28XX_CTRL_2_REG_BASE  (0x40300008UL)
#define WS28XX_DATA_0_REG_BASE  (0x40300400UL)

#define WS28XX_CTRL_0_REG       (*(volatile uint32_t *)WS28XX_CTRL_0_REG_BASE)
#define WS28XX_CTRL_1_REG       (*(volatile uint32_t *)WS28XX_CTRL_1_REG_BASE)
#define WS28XX_CTRL_2_REG       (*(volatile uint32_t *)WS28XX_CTRL_2_REG_BASE)
#define WS28XX_DATA_0_REG       (*(volatile uint32_t *)WS28XX_DATA_0_REG_BASE)

static uint32_t ws28xx_addr[25] = {
    0x01000000, 0x02000000, 0x03000000, 0x04000000, 0x05000000,
    0x06000000, 0x07000000, 0x08000000, 0x09000000, 0x0a000000,
    0x0b000000, 0x0c000000, 0x0d000000, 0x0e000000, 0x0f000000,
    0x10000000, 0x11000000, 0x12000000, 0x13000000, 0x14000000,
    0x15000000, 0x16000000, 0x17000000, 0x18000000, 0x00000000
};

const uint32_t ws28xx_pattern_wait[25] = {
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x000f0f00,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x000f0f00,
    0x000f0f00, 0x000f0f00, 0x000f0f00, 0x000f0f00, 0x000f0f00,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x000f0f00,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x000f0f00
};

const uint32_t ws28xx_pattern_pass[25] = {
    0x00000000, 0x00000000, 0x000f0000, 0x00000000, 0x00000000,
    0x00000000, 0x000f0000, 0x00000000, 0x000f0000, 0x00000000,
    0x000f0000, 0x00000000, 0x000f0000, 0x00000000, 0x000f0000,
    0x00000000, 0x000f0000, 0x00000000, 0x000f0000, 0x00000000,
    0x00000000, 0x00000000, 0x000f0000, 0x00000000, 0x00000000
};

const uint32_t ws28xx_pattern_fail[25] = {
    0x00000f00, 0x00000000, 0x00000000, 0x00000000, 0x00000f00,
    0x00000000, 0x00000f00, 0x00000000, 0x00000f00, 0x00000000,
    0x00000000, 0x00000000, 0x00000f00, 0x00000000, 0x00000000,
    0x00000000, 0x00000f00, 0x00000000, 0x00000f00, 0x00000000,
    0x00000f00, 0x00000000, 0x00000000, 0x00000000, 0x000f0000
};

const uint32_t ws28xx_pattern_none[25] = {
    0x000f000f, 0x000f000f, 0x000f000f, 0x000f000f, 0x000f000f,
    0x00000000, 0x00000000, 0x00000000, 0x000f000f, 0x00000000,
    0x00000000, 0x00000000, 0x000f000f, 0x00000000, 0x00000000,
    0x00000000, 0x000f000f, 0x00000000, 0x00000000, 0x00000000,
    0x000f000f, 0x00000f0f, 0x000f000f, 0x000f000f, 0x00000f0f
};

static bool init = 0;

void ws28xx_init(void)
{
    WS28XX_CTRL_0_REG = 0x00000000;
    WS28XX_CTRL_1_REG = WS28XX_ADDR_BIT;

    for (uint8_t i = 0; i < sizeof(ws28xx_addr)/sizeof(uint32_t); i++) {
        *(volatile uint32_t *)(WS28XX_DATA_0_REG_BASE + i * 4) = ws28xx_addr[i];
    }

    WS28XX_CTRL_2_REG = 0x0e0e0e04;
    WS28XX_CTRL_1_REG = 0x00000000;
    WS28XX_CTRL_0_REG = WS28XX_RSTN_BIT;

    init = 1;

    ws28xx_clear();
}

void ws28xx_write_pixel(uint8_t addr, uint32_t color)
{
    if (!init) return;

    while (!(WS28XX_CTRL_0_REG & WS28XX_IDLE_BIT));

    *(volatile uint32_t *)(WS28XX_DATA_0_REG_BASE + addr * 4) = color;
}

void ws28xx_write_block(const uint32_t *block)
{
    if (!init) return;

    while (!(WS28XX_CTRL_0_REG & WS28XX_IDLE_BIT));

    for (uint8_t i = 0; i < 25; i++) {
        *(volatile uint32_t *)(WS28XX_DATA_0_REG_BASE + i * 4) = block[i];
    }

    ws28xx_refresh();
}

void ws28xx_clear(void)
{
    if (!init) return;

    while (!(WS28XX_CTRL_0_REG & WS28XX_IDLE_BIT));

    for (uint8_t i = 0; i < 25; i++) {
        *(volatile uint32_t *)(WS28XX_DATA_0_REG_BASE + i * 4) = 0x0000;
    }

    ws28xx_refresh();
}

void ws28xx_refresh(void)
{
    if (!init) return;

    while (!(WS28XX_CTRL_0_REG & WS28XX_IDLE_BIT));

    WS28XX_CTRL_1_REG = WS28XX_SYNC_BIT;

    while (WS28XX_CTRL_1_REG & WS28XX_SYNC_BIT);
}