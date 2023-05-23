/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <time.h>
#include <syslog.h>

#include "mbox.h"
#include "gpio.h"

// Core Functions
extern void mdelay(uint32_t ms);

int main(void)
{
    int loop_count = 200;
    uint8_t mail_id = 0;
    uint8_t mail_buff[1024] = {0};

    gpio_init();
    mailbox_init(1);

    printf("app1: started.\n");

    snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u", loop_count);

    while (mailbox_send_message(loop_count, mail_buff, strlen((char *)mail_buff)) < 0) {
        mdelay(625);
    }

    printf("app1: mail %u is sent to remote core\n", loop_count);

    do {
        loop_count++;
        loop_count %= 256;

        printf("app1: loop count: %d\n", loop_count);

        gpio_toggle();

        if (mailbox_check_acked()) {
            printf("app1: mail %u is acked by remote core\n", mailbox_read_ack());

            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u", loop_count);

            while (mailbox_send_message(loop_count, mail_buff, strlen((char *)mail_buff)) < 0) {
                mdelay(625);
            }

            printf("app1: mail %u is sent to remote core\n", loop_count);
        }

        if (mailbox_check_pending()) {
            mailbox_read_message(&mail_id, mail_buff, sizeof(mail_buff));

            printf("app1: mail %u is received: %s\n", mail_id, (char *)mail_buff);

            while (mailbox_send_ack(mail_id) < 0) {
                mdelay(625);
            }

            printf("app1: mail %u is acked\n", mail_id);
        }

        mdelay(1000);
    } while (1);

    return 0;
}
