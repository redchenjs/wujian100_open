/*
 * mbox.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include "drv_irq.h"

// Mailbox Functions
#define MAILBOX_IRQ_NUM      (42)
#define MAILBOX_RAM_MAX      (32 * 1024)

#define MBOX_0_CTRL_REG_BASE (0x40010000)
#define MBOX_0_DATA_RAM_BASE (0x40018000)

#define MBOX_1_CTRL_REG_BASE (0x40020000)
#define MBOX_1_DATA_RAM_BASE (0x40028000)

#define MBOX_INTR_BIT        (0x80000000)
#define MBOX_RESP_BIT        (0x40000000)
#define MBOX_FULL_BIT        (0x20000000)

volatile uint32_t *MBOX_L_CTRL_REG_BASE = NULL;
volatile uint32_t *MBOX_L_DATA_RAM_BASE = NULL;

volatile uint32_t *MBOX_R_CTRL_REG_BASE = NULL;
volatile uint32_t *MBOX_R_DATA_RAM_BASE = NULL;

#define MBOX_L_CTRL_REG      (*(volatile uint32_t *)MBOX_L_CTRL_REG_BASE)
#define MBOX_R_CTRL_REG      (*(volatile uint32_t *)MBOX_R_CTRL_REG_BASE)

uint8_t mail_id = 0;

bool mail_acked = false;
bool mail_pending = false;

void mbox_irq_handler(void)
{
    if (MBOX_L_CTRL_REG & MBOX_RESP_BIT) {
        mail_acked = true;
    } else {
        mail_pending = true;
    }

    MBOX_L_CTRL_REG &=~MBOX_INTR_BIT;
}

void mbox_init(uint8_t core_id)
{
    if (core_id == 0) {
        MBOX_L_CTRL_REG_BASE = (volatile uint32_t *)MBOX_0_CTRL_REG_BASE;
        MBOX_L_DATA_RAM_BASE = (volatile uint32_t *)MBOX_0_DATA_RAM_BASE;

        MBOX_R_CTRL_REG_BASE = (volatile uint32_t *)MBOX_1_CTRL_REG_BASE;
        MBOX_R_DATA_RAM_BASE = (volatile uint32_t *)MBOX_1_DATA_RAM_BASE;
    } else {
        MBOX_L_CTRL_REG_BASE = (volatile uint32_t *)MBOX_1_CTRL_REG_BASE;
        MBOX_L_DATA_RAM_BASE = (volatile uint32_t *)MBOX_1_DATA_RAM_BASE;

        MBOX_R_CTRL_REG_BASE = (volatile uint32_t *)MBOX_0_CTRL_REG_BASE;
        MBOX_R_DATA_RAM_BASE = (volatile uint32_t *)MBOX_0_DATA_RAM_BASE;
    }

    MBOX_L_CTRL_REG = 0x00000000;

    drv_irq_register(MAILBOX_IRQ_NUM, mbox_irq_handler);
    drv_irq_enable(MAILBOX_IRQ_NUM);
}

bool mbox_check_acked(void)
{
    return mail_acked;
}

bool mbox_check_pending(void)
{
    return mail_pending;
}

int mbox_read_ack(void)
{
    uint8_t id = MBOX_L_CTRL_REG & 0xff;

    mail_acked = false;

    MBOX_L_CTRL_REG &=~MBOX_FULL_BIT;

    return id;
}

int mbox_read_message(uint8_t *id, void *buff, uint32_t buff_size)
{
    uint16_t size = (MBOX_L_CTRL_REG & 0x7fff00) >> 8;

    if (size > buff_size) {
        return -1;
    }

    *id = MBOX_L_CTRL_REG & 0xff;

    memcpy(buff, (void *)MBOX_L_DATA_RAM_BASE, size);

    mail_pending = false;

    MBOX_L_CTRL_REG &=~MBOX_FULL_BIT;

    return size;
}

int mbox_send_ack(uint8_t id)
{
    if (MBOX_R_CTRL_REG & MBOX_FULL_BIT) {
        return -1;
    }

    MBOX_R_CTRL_REG = id | MBOX_FULL_BIT | MBOX_RESP_BIT | MBOX_INTR_BIT;

    return 0;
}

int mbox_send_message(uint8_t id, const void *buff, uint32_t len)
{
    if (MBOX_R_CTRL_REG & MBOX_FULL_BIT) {
        return -1;
    }

    if (len > MAILBOX_RAM_MAX) {
        return -2;
    }

    memcpy((void *)MBOX_R_DATA_RAM_BASE, buff, len);

    MBOX_R_CTRL_REG = id | (len << 8) | MBOX_FULL_BIT | MBOX_INTR_BIT;

    return len;
}
