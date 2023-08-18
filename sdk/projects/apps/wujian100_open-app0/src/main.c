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

#include "pmu.h"
#include "pmp.h"
#include "pwm.h"
#include "mbox.h"

#include "fonts.h"
#include "ssd1331.h"

// Core Functions
extern void mdelay(uint32_t ms);

int main(void)
{
    bool send_msg = false;
    bool send_ack = false;

    uint8_t send_msg_id = 0;
    uint8_t send_ack_id = 0;

    uint8_t loop = 100;
    uint8_t mail_id = 0;
    int16_t mail_len = 0;
    uint8_t mail_buff[1024] = {0};

    pmu_set_reset(0);

    pmp_init();
    pwm_init();
    mbox_init(0);

    ssd1331_init();
    ssd1331_show_rainbow();

    printf("app0: started.\n");

    // Release Core 1 Reset
    pmu_set_reset(1);

    printf("app0: start core 1...\n");

    snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u", loop);

    // Send Mail to Core 1
    if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
        printf("app0: mail %u is sent to remote core\n", loop);
    } else {
        send_msg_id = loop;
        send_msg = true;
    }

    do {
        printf("app0: loop count: %d\n", loop++);

        pwm_toggle();

        // TX Mail ID
        snprintf((char *)mail_buff, sizeof(mail_buff), "%03u", send_msg_id);

        ssd1331_display_string(0, 0, (char *)mail_buff, FONT_3216, Lime, Black);

        // RX Mail ID
        snprintf((char *)mail_buff, sizeof(mail_buff), "%03u", send_ack_id);

        ssd1331_display_string(48, 32, (char *)mail_buff, FONT_3216, Yellow, Black);

        // Check for Mail Response
        if (mbox_check_acked()) {
            mbox_read_ack(&mail_id);

            printf("app0: mail %u is acked by remote core\n", mail_id);

            send_msg_id = loop;
            send_msg = true;
        }

        // Send Mail
        if (send_msg) {
            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u", send_msg_id);

            if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
                printf("app0: mail %u is sent to remote core\n", send_msg_id);

                send_msg = false;
            }
        }

        // Check for Pending Mail
        if (mbox_check_pending()) {
            if ((mail_len = mbox_read_message(&mail_id, mail_buff, sizeof(mail_buff))) >= 0) {
                mail_buff[mail_len] = 0x00;

                printf("app0: mail %u is received: %s\n", mail_id, (char *)mail_buff);

                send_ack_id = mail_id;
                send_ack = true;
            }
        }

        // Send Mail Response
        if (send_ack) {
            if (mbox_send_ack(send_ack_id) >= 0) {
                printf("app0: mail %u is acked\n", send_ack_id);

                send_ack = false;
            }
        }

        // Check IOPMP read violation (I-BUS)
        if (pmp_get_err_rd(0)) {
            printf("app0: iopmp port 0 access violation reading address 0x%08x\n", pmp_get_dump_rd(0));
        }

        // Check IOPMP write violation (I-BUS)
        if (pmp_get_err_wr(0)) {
            printf("app0: iopmp port 0 access violation writing address 0x%08x\n", pmp_get_dump_wr(0));
        }

        // Check IOPMP read violation (D-BUS)
        if (pmp_get_err_rd(1)) {
            printf("app0: iopmp port 1 access violation reading address 0x%08x\n", pmp_get_dump_rd(1));
        }

        // Check IOPMP write violation (D-BUS)
        if (pmp_get_err_wr(1)) {
            printf("app0: iopmp port 1 access violation writing address 0x%08x\n", pmp_get_dump_wr(1));
        }

        mdelay(1000);
    } while (1);

    return 0;
}
