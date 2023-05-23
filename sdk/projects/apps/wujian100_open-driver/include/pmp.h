/*
 * pmp.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_PMP_H_
#define INC_DRIVER_PMP_H_

#include <stdint.h>
#include <stdbool.h>

extern void pmp_init(void);

extern bool pmp_get_err(uint8_t idx);
extern uint8_t pmp_get_hit(uint8_t idx);

extern uint32_t pmp_get_dump(uint8_t idx);

#endif /* INC_DRIVER_PMP_H_ */
