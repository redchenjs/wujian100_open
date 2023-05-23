/*
 * mbox.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_MBOX_H_
#define INC_DRIVER_MBOX_H_

#include <stdint.h>
#include <stdbool.h>

extern void mbox_init(uint8_t core_id);

extern bool mbox_check_acked(void);
extern bool mbox_check_pending(void);

extern int mbox_read_ack(void);
extern int mbox_read_message(uint8_t *id, void *buff, uint32_t buff_size);

extern int mbox_send_ack(uint8_t id);
extern int mbox_send_message(uint8_t id, const void *buff, uint32_t len);

#endif /* INC_DRIVER_MBOX_H_ */
