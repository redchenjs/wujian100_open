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

#define MBOX_L_CTRL_REG_BASE (MBOX_1_CTRL_REG_BASE)
#define MBOX_L_DATA_RAM_BASE (MBOX_1_DATA_RAM_BASE)

#define MBOX_R_CTRL_REG_BASE (MBOX_0_CTRL_REG_BASE)
#define MBOX_R_DATA_RAM_BASE (MBOX_0_DATA_RAM_BASE)

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

    MBOX_L_CTRL_REG &=~MBOX_FULL_BIT;

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

    MBOX_L_CTRL_REG &=~MBOX_FULL_BIT;

    return size;
}

int mailbox_send_ack(uint8_t id)
{
    if (MBOX_R_CTRL_REG & MBOX_FULL_BIT) {
        return -1;
    }

    MBOX_R_CTRL_REG = id | MBOX_FULL_BIT | MBOX_RESP_BIT | MBOX_INTR_BIT;

    return 0;
}

int mailbox_send_message(uint8_t id, const void *buff, uint32_t len)
{
    if (MBOX_R_CTRL_REG & MBOX_FULL_BIT) {
        return -1;
    }
    
    if (len > MAILBOX_RAM_MAX) {
        return -2;
    }

    memcpy((void *)MBOX_R_DATA_RAM_BASE, buff, len);

    MBOX_R_CTRL_REG = id | (len << 8) | MBOX_FLAG_BIT | MBOX_INTR_BIT;
    
    return len;
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

    gpio_init();
    mailbox_init();

    printf("app1: started.\n");

    do {
        printf("app1: loop count: %d\n", loop_count++);

        gpio_toggle();

        if (mail_acked) {
            printf("app1: mail %u is acked by remote core\n", mailbox_read_ack());

            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u\n", loop_count);

            mailbox_send_message(loop_count, mail_buff, strlen((char *)mail_buff));

            printf("app1: mail %u is sent to remote core\n", loop_count);
        }

        if (mail_pending) {
            mailbox_read_message(&mail_id, mail_buff, sizeof(mail_buff));

            printf("app1: mail %u is received: %s\n", mail_id, (char *)mail_buff);

            mailbox_send_ack(mail_id);

            printf("app1: mail %u is acked\n", mail_id);
        }

        mdelay(1000);
    } while (1);

    return 0;
}
