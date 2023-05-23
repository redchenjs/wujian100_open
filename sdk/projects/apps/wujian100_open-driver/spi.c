/*
 * spi.c
 *
 *  Created on: 2023-04-29 09:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#include "drv_spi.h"
#include "drv_gpio.h"

// SPI Flash Functions
#define SPI_DEV_IDX 2
#define SPI_NSS_PIN 1

spi_handle_t spi_handle = NULL;
gpio_pin_handle_t spi_nss_pin_handle = NULL;

void spi_init(void)
{
    // init spi nss pin
    spi_nss_pin_handle = csi_gpio_pin_initialize(SPI_NSS_PIN, NULL);

    csi_gpio_pin_config_mode(spi_nss_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(spi_nss_pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(spi_nss_pin_handle, true);

    // init spi device
    spi_handle = csi_spi_initialize(SPI_DEV_IDX, NULL);

    csi_spi_config(spi_handle, 1000000, SPI_MODE_MASTER, SPI_FORMAT_CPOL0_CPHA0, SPI_ORDER_MSB2LSB, SPI_SS_MASTER_SW, 8);
    csi_spi_config_block_mode(spi_handle, 1);
}

int32_t spi_flash_read(uint32_t addr, void *data, uint32_t len)
{
    uint8_t command[4] = { 0x00 };

    command[0] = 0x03;
    command[1] = (addr >> 16) & 0xff;
    command[2] = (addr >> 8) & 0xff;
    command[3] = addr & 0xff;

    // set spi nss to active
    csi_gpio_pin_write(spi_nss_pin_handle, false);

    // send read data command
    csi_spi_send(spi_handle, command, 4);

    // read data to buffer
    csi_spi_receive(spi_handle, (uint8_t *)data, len);

    // set spi nss to inactive
    csi_gpio_pin_write(spi_nss_pin_handle, true);

    return len;
}
