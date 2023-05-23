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

#include "pmu.h"
#include "spi.h"
#include "pwm.h"
#include "pmp.h"
#include "mbox.h"

// Core Functions
extern void mdelay(uint32_t ms);

int main(void)
{
    int loop_count = 100;
    uint8_t mail_id = 0;
    uint8_t mail_buff[1024] = {0};

    pmu_set_reset(0);

    pwm_init();
    pmp_init();
    mailbox_init(0);

    printf("app0: started.\n");

    pmu_set_reset(1);

    printf("app0: start core 1...\n");

    snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u", loop_count);

    while (mailbox_send_message(loop_count, mail_buff, strlen((char *)mail_buff)) < 0) {
        mdelay(625);
    }

    printf("app0: mail %u is sent to remote core\n", loop_count);

    do {
        loop_count++;
        loop_count %= 256;

        printf("app0: loop count: %d\n", loop_count);

        pwm_test();

        if (mailbox_check_acked()) {
            printf("app0: mail %u is acked by remote core\n", mailbox_read_ack());

            snprintf((char *)mail_buff, sizeof(mail_buff), "Hello from core 0! The message id is %u", loop_count);

            while (mailbox_send_message(loop_count, mail_buff, strlen((char *)mail_buff)) < 0) {
                mdelay(625);
            }

            printf("app0: mail %u is sent to remote core\n", loop_count);
        }

        if (mailbox_check_pending()) {
            mailbox_read_message(&mail_id, mail_buff, sizeof(mail_buff));

            printf("app0: mail %u is received: %s\n", mail_id, (char *)mail_buff);

            while (mailbox_send_ack(mail_id) < 0) {
                mdelay(625);
            }

            printf("app0: mail %u is acked\n", mail_id);
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
