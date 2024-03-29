/*
 * Copyright (C) 2017-2019 Alibaba Group Holding Limited
 */


/******************************************************************************
 * @file     pin.h
 * @brief    header File for pin definition
 * @version  V1.0
 * @date     02. June 2019
 ******************************************************************************/
#ifndef _PIN_H_
#define _PIN_H_

#include <stdint.h>
#include "pin_name.h"
#include "pinmux.h"

#ifdef __cplusplus
extern "C" {
#endif

#define CLOCK_GETTIME_USE_TIMER_ID 2
#define UART_TXD0       1
#define UART_RXD0       2

#define CONSOLE_TXD     PAD_UART2_SIN
#define CONSOLE_RXD     PAD_UART2_SOUT
#define CONSOLE_IDX     1

/* example pin manager */
#define EXAMPLE_USART_IDX       0
#define EXAMPLE_PIN_USART_TX    PAD_UART0_SIN
#define EXAMPLE_PIN_USART_RX    PAD_UART0_SOUT
#define EXAMPLE_PIN_USART_TX_FUNC   0
#define EXAMPLE_PIN_USART_RX_FUNC   0

#define EXAMPLE_GPIO_PIN    PA1
#define EXAMPLE_BOARD_GPIO_PIN_NAME "A1"
#define EXAMPLE_GPIO_PIN_FUNC   0

#define EXAMPLE_SPI_IDX                 1
#define EXAMPLE_PIN_SPI_MOSI            0
#define EXAMPLE_PIN_SPI_MISO            0
#define EXAMPLE_PIN_SPI_CS              0
#define EXAMPLE_PIN_SPI_SCK             0
#define EXAMPLE_PIN_SPI_MOSI_FUNC       0
#define EXAMPLE_PIN_SPI_MISO_FUNC       0
#define EXAMPLE_PIN_SPI_CS_FUNC         0
#define EXAMPLE_PIN_SPI_SCK_FUNC        0

#define EXAMPLE_IIC_IDX                 0
#define EXAMPLE_PIN_IIC_SDA             0
#define EXAMPLE_PIN_IIC_SCL             0
#define EXAMPLE_PIN_IIC_SDA_FUNC        0
#define EXAMPLE_PIN_IIC_SCL_FUNC        0

/* tests pin manager */
#define TEST_USART_IDX       0
#define TEST_PIN_USART_TX    PAD_UART0_SIN
#define TEST_PIN_USART_RX    PAD_UART0_SOUT
#define TEST_PIN_USART_TX_FUNC      0
#define TEST_PIN_USART_RX_FUNC      0

#define TEST_GPIO_PIN    PA0
#define TEST_BOARD_GPIO_PIN_NAME "A0"
#define TEST_GPIO_PIN_FUNC   0

#define TEST_SPI_IDX                    0
#define TEST_PIN_SPI_MISO               0
#define TEST_PIN_SPI_MOSI               0
#define TEST_PIN_SPI_CS                 0
#define TEST_PIN_SPI_SCK                0
#define TEST_PIN_SPI_MISO_FUNC          0
#define TEST_PIN_SPI_MOSI_FUNC          0
#define TEST_PIN_SPI_CS_FUNC            0
#define TEST_PIN_SPI_SCK_FUNC           0

#define TEST_IIC_IDX                    0
#define TEST_PIN_IIC_SDA                0
#define TEST_PIN_IIC_SCL                0
#define TEST_PIN_IIC_SDA_FUNC           0
#define TEST_PIN_IIC_SCL_FUNC           0

#define UART_TXD2       3
#define UART_RXD2       4

#define UART_TXD3       5
#define UART_RXD3       6

#define UART_PINs  { {PA0, PA1},\
        {PA10, PA11},\
        {PA23, PA22},\
        {PA26, PA27} }

#define GPIO_EXAMPLE_PORT   PORTB
#define GPIO_EXAMPLE_PIN    PA1
#define CTS_GPIO_TEST_PORT  PORTA
#define CTS_GPIO_TEST_PIN   PA0
#define EXAMPLE_BOARD_GPIO_PIN_NAME "A1"
#define CTS_BOARD_GPIO_PIN_NAME     "A0"
#define SENSOR_UART_DIR     PA3

#define EXAMPLE_PWM_IDX                 0
#define EXAMPLE_PWM_CH_IDX              0
#define EXAMPLE_PWM_CH                  0
#define EXAMPLE_PWM_CH_FUNC             0

#define TEST_PWM_IDX                 0
#define TEST_PWM_CH                  0
#define TEST_PWM_CH0                 0
#define TEST_PWM_CH0_FUNC            0
#define TEST_PWM_CH1                 0
#define TEST_PWM_CH1_FUNC            0
#define TEST_PWM_CH2                 0
#define TEST_PWM_CH2_FUNC            0
#define TEST_PWM_CH3                 0
#define TEST_PWM_CH3_FUNC            0
#define TEST_PWM_CH4                 0
#define TEST_PWM_CH4_FUNC            0
#define TEST_PWM_CH5                 0
#define TEST_PWM_CH5_FUNC            0

#define PIN_FUNC_GPIO                0

#ifdef __cplusplus
}
#endif

#endif /* _PIN_H_ */

