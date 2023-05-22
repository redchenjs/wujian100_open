/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "time.h"
#include "syslog.h"

#include "drv_irq.h"
#include "drv_pwm.h"
#include "drv_gpio.h"

// Core Functions
extern void mdelay(uint32_t ms);

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

// Mailbox Functions
#define MAILBOX_IRQ_NUM      (42)
#define MAILBOX_RAM_MAX      (32 * 1024)

#define MBOX_0_CTRL_REG_BASE (0x40010000)
#define MBOX_0_DATA_RAM_BASE (0x40018000)

#define MBOX_1_CTRL_REG_BASE (0x40020000)
#define MBOX_1_DATA_RAM_BASE (0x40028000)

#define MBOX_INTR_BIT        (0x80000000)
#define MBOX_RESP_BIT        (0x40000000)
#define MBOX_FLAG_BIT        (0x20000000)

#define MBOX_L_CTRL_REG_BASE (MBOX_0_CTRL_REG_BASE)
#define MBOX_L_DATA_RAM_BASE (MBOX_0_DATA_RAM_BASE)

#define MBOX_R_CTRL_REG_BASE (MBOX_1_CTRL_REG_BASE)
#define MBOX_R_DATA_RAM_BASE (MBOX_1_DATA_RAM_BASE)

#define MBOX_L_CTRL_REG      (*(volatile uint32_t *)MBOX_L_CTRL_REG_BASE)
#define MBOX_R_CTRL_REG      (*(volatile uint32_t *)MBOX_R_CTRL_REG_BASE)

uint8_t mail_id = 0;

bool mail_acked = false;
bool mail_pending = false;

void mailbox_irq_handler(void)
{
    if (MBOX_L_CTRL_REG & MBOX_RESP_BIT) {
        mail_acked = true;
    } else {
        mail_pending = true;
    }

    MBOX_L_CTRL_REG &=~MBOX_INTR_BIT;
}

void mailbox_init(void)
{
    drv_irq_register(MAILBOX_IRQ_NUM, mailbox_irq_handler);
    drv_irq_enable(MAILBOX_IRQ_NUM);
}

int mailbox_read_ack(void)
{
    uint8_t id = MBOX_L_CTRL_REG & 0xff;

    mail_acked = false;

    MBOX_L_CTRL_REG &=~MBOX_FLAG_BIT;

    return id;
}

int mailbox_read_message(uint8_t *id, void *buff, uint32_t buff_size)
{
    uint16_t size = (MBOX_L_CTRL_REG & 0x7fff00) >> 8;

    if (size < buff_size) {
        return -1;
    }

    *id = MBOX_L_CTRL_REG & 0xff;

    memcpy(buff, (void *)MBOX_L_DATA_RAM_BASE, size);

    mail_pending = false;

    MBOX_L_CTRL_REG &=~MBOX_FLAG_BIT;

    return size;
}

int mailbox_send_ack(uint8_t id)
{
    if (MBOX_R_CTRL_REG & MBOX_FLAG_BIT) {
        return -1;
    }

    MBOX_R_CTRL_REG = id | MBOX_FLAG_BIT | MBOX_RESP_BIT | MBOX_INTR_BIT;

    return 0;
}

int mailbox_send_message(uint8_t id, const void *buff, uint32_t len)
{
    if (MBOX_R_CTRL_REG & MBOX_FLAG_BIT) {
        return -1;
    }

    if (len > MAILBOX_RAM_MAX) {
        return -2;
    }

    memcpy((void *)MBOX_R_DATA_RAM_BASE, buff, len);

    MBOX_R_CTRL_REG = id | (len << 8) | MBOX_FLAG_BIT | MBOX_INTR_BIT;

    return len;
}

// IOPMP Functions
#define PMP_CTRL_0_REG_BASE (0x40100000)
#define PMP_CTRL_1_REG_BASE (0x40100004)

#define PMP_CONF_0_0_BASE_REG_BASE (0x40100010)
#define PMP_CONF_0_0_MASK_REG_BASE (0x40100014)
#define PMP_CONF_0_1_BASE_REG_BASE (0x40100018)
#define PMP_CONF_0_1_MASK_REG_BASE (0x4010001C)
#define PMP_CONF_0_2_BASE_REG_BASE (0x40100020)
#define PMP_CONF_0_2_MASK_REG_BASE (0x40100024)
#define PMP_CONF_0_3_BASE_REG_BASE (0x40100028)
#define PMP_CONF_0_3_MASK_REG_BASE (0x4010002C)
#define PMP_CONF_0_4_BASE_REG_BASE (0x40100030)
#define PMP_CONF_0_4_MASK_REG_BASE (0x40100034)
#define PMP_CONF_0_5_BASE_REG_BASE (0x40100038)
#define PMP_CONF_0_5_MASK_REG_BASE (0x4010003C)
#define PMP_CONF_0_6_BASE_REG_BASE (0x40100040)
#define PMP_CONF_0_6_MASK_REG_BASE (0x40100044)
#define PMP_CONF_0_7_BASE_REG_BASE (0x40100048)
#define PMP_CONF_0_7_MASK_REG_BASE (0x4010004C)

#define PMP_CONF_1_0_BASE_REG_BASE (0x40100050)
#define PMP_CONF_1_0_MASK_REG_BASE (0x40100054)
#define PMP_CONF_1_1_BASE_REG_BASE (0x40100058)
#define PMP_CONF_1_1_MASK_REG_BASE (0x4010005C)
#define PMP_CONF_1_2_BASE_REG_BASE (0x40100060)
#define PMP_CONF_1_2_MASK_REG_BASE (0x40100064)
#define PMP_CONF_1_3_BASE_REG_BASE (0x40100068)
#define PMP_CONF_1_3_MASK_REG_BASE (0x4010006C)
#define PMP_CONF_1_4_BASE_REG_BASE (0x40100070)
#define PMP_CONF_1_4_MASK_REG_BASE (0x40100074)
#define PMP_CONF_1_5_BASE_REG_BASE (0x40100078)
#define PMP_CONF_1_5_MASK_REG_BASE (0x4010007C)
#define PMP_CONF_1_6_BASE_REG_BASE (0x40100080)
#define PMP_CONF_1_6_MASK_REG_BASE (0x40100084)
#define PMP_CONF_1_7_BASE_REG_BASE (0x40100088)
#define PMP_CONF_1_7_MASK_REG_BASE (0x4010008C)

#define PMP_CTRL_0_REG        (*(volatile uint32_t *)PMP_CTRL_0_REG_BASE)
#define PMP_CTRL_1_REG        (*(volatile uint32_t *)PMP_CTRL_1_REG_BASE)

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

typedef struct {
    uint32_t rsvd :16;
    uint32_t hit  :8;
    uint32_t en   :8;
} __attribute__((packed)) pmp_ctrl_t;

typedef struct {
    uint32_t mask;
    uint32_t base;
} __attribute__((packed)) pmp_conf_t;

void pmp_init(void)
{
    PMP_CONF_0_0_BASE_REG = 0x20000000;
    PMP_CONF_0_0_MASK_REG = 0xffff0000;
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

    PMP_CONF_1_0_BASE_REG = 0x20020000;
    PMP_CONF_1_0_MASK_REG = 0xffff0000;
    PMP_CONF_1_1_BASE_REG = 0x00000000;
    PMP_CONF_1_1_MASK_REG = 0x00000000;
    PMP_CONF_1_2_BASE_REG = 0x00000000;
    PMP_CONF_1_2_MASK_REG = 0x00000000;
    PMP_CONF_1_3_BASE_REG = 0x00000000;
    PMP_CONF_1_3_MASK_REG = 0x00000000;
    PMP_CONF_1_4_BASE_REG = 0x00000000;
    PMP_CONF_1_4_MASK_REG = 0x00000000;
    PMP_CONF_1_5_BASE_REG = 0x00000000;
    PMP_CONF_1_5_MASK_REG = 0x00000000;
    PMP_CONF_1_6_BASE_REG = 0x00000000;
    PMP_CONF_1_6_MASK_REG = 0x00000000;
    PMP_CONF_1_7_BASE_REG = 0x00000000;
    PMP_CONF_1_7_MASK_REG = 0x00000000;

    PMP_CTRL_0_REG = 0x01;
    PMP_CTRL_1_REG = 0x01;
}

uint8_t pmp_get_hit(uint8_t idx)
{
    if (idx) {
        return PMP_CTRL_1_REG >> 8;
    } else {
        return PMP_CTRL_0_REG >> 8;
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
    uint8_t mail_id = 0;
    uint8_t mail_buff[1024] = {0};

    pwm_init();
    pmp_init();
    mailbox_init();

    printf("app0: started.\n");

    pmu_set_reset(1);

    printf("app0: start core 1...\n");

    do {
        printf("app0: loop count: %d\n", loop_count++);

        pwm_test();

        if (mail_acked) {
            printf("app0: mail %u is acked by remote core\n", mailbox_read_ack());

            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u\n", loop_count);

            mailbox_send_message(loop_count, mail_buff, strlen((char *)mail_buff));

            printf("app0: mail %u is sent to remote core\n", loop_count);
        }

        if (mail_pending) {
            mailbox_read_message(&mail_id, mail_buff, sizeof(mail_buff));

            printf("app0: mail %u is received: %s\n", mail_id, (char *)mail_buff);

            mailbox_send_ack(mail_id);

            printf("app0: mail %u is acked\n", mail_id);
        }

        printf("app0: iopmp port 0 status: %02x\n", pmp_get_hit(0));
        printf("app0: iopmp port 1 status: %02x\n", pmp_get_hit(1));

        mdelay(1000);
    } while (1);

    return 0;
}
