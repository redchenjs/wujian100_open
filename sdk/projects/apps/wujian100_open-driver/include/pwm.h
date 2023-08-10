/*
 * pwm.h
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#ifndef INC_DRIVER_PWM_H_
#define INC_DRIVER_PWM_H_

#include <stdint.h>

extern void pwm_init(void);
extern void pwm_config(uint32_t period, uint32_t pulse);
extern void pwm_toggle(void);
extern void pwm_deinit(void);

#endif /* INC_DRIVER_PWM_H_ */
