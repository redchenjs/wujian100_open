/*
 * boot.h
 *
 *  Created on: 2023-08-15 21:52
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_BOOT_H_
#define INC_DRIVER_BOOT_H_

#include <stdint.h>
#include <stdbool.h>

extern void boot_init(void);

extern bool boot_get_mode_flash(void);
extern bool boot_get_mode_crypto(void);

#endif /* INC_DRIVER_BOOT_H_ */
