/*
 * ws28xx.h
 *
 *  Created on: 2023-08-13 22:01
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_WS28XX_H_
#define INC_DRIVER_WS28XX_H_

#include <stdint.h>
#include <stdbool.h>

extern const uint32_t ws28xx_pattern_wait[];
extern const uint32_t ws28xx_pattern_pass[];
extern const uint32_t ws28xx_pattern_fail[];
extern const uint32_t ws28xx_pattern_none[];

extern void ws28xx_init(void);

extern void ws28xx_write_pixel(uint8_t addr, uint32_t color);
extern void ws28xx_write_block(const uint32_t *block);

extern void ws28xx_clear(void);
extern void ws28xx_refresh(void);

#endif /* INC_DRIVER_WS28XX_H_ */
