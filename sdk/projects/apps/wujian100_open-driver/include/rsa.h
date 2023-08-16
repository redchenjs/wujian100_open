/*
 * rsa.h
 *
 *  Created on: 2023-08-15 21:52
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_RSA_H_
#define INC_DRIVER_RSA_H_

#include <stdint.h>
#include <stdbool.h>

extern void rsa_init(void);

extern void rsa_calc_data(const uint32_t *input, uint32_t *result);

#endif /* INC_DRIVER_RSA_H_ */
