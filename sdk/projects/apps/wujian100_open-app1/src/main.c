/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "gpio.h"
#include "mbox.h"

#include "ws28xx.h"

// Core Functions
extern void mdelay(uint32_t ms);

int main(void)
{
    bool send_msg = false;
    bool send_ack = false;

    uint8_t send_msg_id = 0;
    uint8_t send_ack_id = 0;

    uint8_t loop = 197;
    uint8_t mail_id = 0;
    int16_t mail_len = 0;
    uint8_t mail_buff[1024] = {0};

    gpio_init();
    mbox_init(1);

    ws28xx_init();

    printf("app1: started.\n");

    snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u", loop);

    if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
        printf("app1: mail %u is sent to remote core\n", loop);
    } else {
        send_msg_id = loop;
        send_msg = true;
    }

    do {
        printf("app1: loop count: %d\n", loop++);

        gpio_toggle();

        if (loop % 6) {
            ws28xx_write_block(ws28xx_pattern_show[loop % 6 - 1]);
        } else {
            ws28xx_clear();
        }

        if (mbox_check_acked()) {
            mbox_read_ack(&mail_id);

            printf("app1: mail %u is acked by remote core\n", mail_id);

            send_msg_id = loop;
            send_msg = true;
        }

        if (send_msg) {
            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 1! The message id is %u", send_msg_id);

            if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
                printf("app1: mail %u is sent to remote core\n", send_msg_id);

                send_msg = false;
            }
        }

        if (mbox_check_pending()) {
            if ((mail_len = mbox_read_message(&mail_id, mail_buff, sizeof(mail_buff))) >= 0) {
                mail_buff[mail_len] = 0x00;

                printf("app1: mail %u is received: %s\n", mail_id, (char *)mail_buff);

                send_ack_id = mail_id;
                send_ack = true;
            }
        }

        if (send_ack) {
            if (mbox_send_ack(send_ack_id) >= 0) {
                printf("app1: mail %u is acked\n", send_ack_id);

                send_ack = false;
            }
        }

        mdelay(1000);
    } while (1);

    return 0;
}
