/*
 * main.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "pmu.h"
#include "pmp.h"
#include "pwm.h"
#include "mbox.h"

// Core Functions
extern void mdelay(uint32_t ms);

int main(void)
{
    uint8_t loop = 100;
    uint8_t mail_id = 0;
    uint8_t mail_buff[1024] = {0};

    pmu_set_reset(0);

    pmp_init();
    pwm_init();
    mbox_init(0);

    printf("app0: started.\n");

    pmu_set_reset(1);

    printf("app0: start core 1...\n");

    snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u", loop);

    if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
        printf("app0: mail %u is sent to remote core\n", loop);
    }

    do {
        printf("app0: loop count: %d\n", loop++);

        pwm_test();

        if (mbox_check_acked()) {
            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u", loop);

            if (mbox_send_message(loop, mail_buff, strlen((char *)mail_buff)) >= 0) {
                printf("app0: mail %u is acked by remote core\n", mbox_read_ack());
                printf("app0: mail %u is sent to remote core\n", loop);
            }
        }

        if (mbox_check_pending()) {
            if (mbox_send_ack(mail_id) >= 0) {
                mbox_read_message(&mail_id, mail_buff, sizeof(mail_buff));

                printf("app0: mail %u is received: %s\n", mail_id, (char *)mail_buff);
                printf("app0: mail %u is acked\n", mail_id);
            }
        }

        if (pmp_get_err(0)) {
            printf("app0: iopmp port 0 hit: 0x%02x\n", pmp_get_hit(0));
            printf("app0: iopmp port 0 err: 0x%08x\n", pmp_get_dump(0));
        }

        if (pmp_get_err(1)) {
            printf("app0: iopmp port 1 hit: 0x%02x\n", pmp_get_hit(1));
            printf("app0: iopmp port 1 err: 0x%08x\n", pmp_get_dump(1));
        }

        mdelay(1000);
    } while (1);

    return 0;
}
