/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "gpio.h"
#include "mbox.h"

// Core Functions
extern void mdelay(uint32_t ms);

int main(void)
{
    uint8_t loop = 200;
    uint8_t mail_id = 0;
    uint8_t mail_buff[1024] = {0};

    gpio_init();
    mbox_init(1);

    printf("app1: started.\n");

    snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u", loop);

    if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
        printf("app1: mail %u is sent to remote core\n", loop);
    }

    do {
        printf("app1: loop count: %d\n", loop++);

        gpio_toggle();

        if (mbox_check_acked()) {
            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u", loop);

            if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
                printf("app1: mail %u is acked by remote core\n", mbox_read_ack());
                printf("app1: mail %u is sent to remote core\n", loop);
            }
        }

        if (mbox_check_pending()) {
            if (mbox_send_ack(mail_id) >= 0) {
                mbox_read_message(&mail_id, mail_buff, sizeof(mail_buff));

                printf("app1: mail %u is received: %s\n", mail_id, (char *)mail_buff);
                printf("app1: mail %u is acked\n", mail_id);
            }
        }

        mdelay(1000);
    } while (1);

    return 0;
}
