/*
 * spi.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_SPI_H_
#define INC_DRIVER_SPI_H_

#include <stdint.h>

extern void spi_init(void);

extern int32_t spi_flash_read(uint32_t addr, void *data, uint32_t len);

#endif /* INC_DRIVER_SPI_H_ */
