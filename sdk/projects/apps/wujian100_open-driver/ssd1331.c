/*
 * ssd1331.c
 *
 *  Created on: 2016-10-20 12:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>

#include "drv_spi.h"
#include "drv_gpio.h"

#include "fonts.h"
#include "ssd1331.h"

#define abs(x)   ((x)>0?(x):-(x))
#define min(a,b) ((a)<(b)?(a):(b))
#define max(a,b) ((a)>(b)?(a):(b))

#define SPI_DEV_IDX 2

#define LCD_RST_PIN 3
#define LCD_DC_PIN  4
#define LCD_CS_PIN  5

static spi_handle_t spi_handle = NULL;

static gpio_pin_handle_t  dc_pin_handle = NULL;
static gpio_pin_handle_t  cs_pin_handle = NULL;
static gpio_pin_handle_t rst_pin_handle = NULL;

#define SSD1331_PIN_SET() {}

#define SSD1331_RES_SET()   csi_gpio_pin_write(rst_pin_handle, true);
#define SSD1331_RES_CLR()   csi_gpio_pin_write(rst_pin_handle, false);
#define SSD1331_DC_SET()    csi_gpio_pin_write(dc_pin_handle, true);
#define SSD1331_DC_CLR()    csi_gpio_pin_write(dc_pin_handle, false);
#define SSD1331_CS_SET()    csi_gpio_pin_write(cs_pin_handle, true);
#define SSD1331_CS_CLR()    csi_gpio_pin_write(cs_pin_handle, false);

#define SSD1331_WRITE_BYTE(__DATA)  csi_spi_send(spi_handle, &__DATA, 1)

enum ssd1331_panel_value {
    SSD1331_WIDTH  = 96,
    SSD1331_HEIGHT = 64
};

enum ssd1331_data_type {
    SSD1331_CMD  = 0,
    SSD1331_DATA = 1
};

enum ssd1331_fundamental_command_table {
    SET_COLUMN_ADDRESS  = 0x15,
    SET_ROW_ADDRESS     = 0x75,

    SET_CONTRAST_A          = 0x81,
    SET_CONTRAST_B          = 0x82,
    SET_CONTRAST_C          = 0x83,
    SET_MASTER_CURRENT      = 0x87,
    SET_PRECHARGE_SPEED_A   = 0x8A,
    SET_PRECHARGE_SPEED_B   = 0x8B,
    SET_PRECHARGE_SPEED_C   = 0x8C,

    SET_REMAP_COLOR_DEPTH   = 0xA0,
    SET_DISPLAY_START_LINE  = 0xA1,
    SET_DISPLAY_OFFSET      = 0xA2,

    SET_NORMAL_DISPLAY      = 0xA4,
    SET_ENTIRE_DISPLAY_ON   = 0xA5,
    SET_ENTIRE_DISPLAY_OFF  = 0xA6,
    SET_INVERSE_DISPLAY     = 0xA7,

    SET_MULTIPLEX_RATIO     = 0xA8,
    SET_DIM_MODE            = 0xAB,
    SET_MASTER_CONFIG       = 0xAD,

    SET_DISPLAY_ON_DIM      = 0xAC,
    SET_DISPLAY_OFF         = 0xAE,
    SET_DISPLAY_ON_NORMAL   = 0xAF,

    SET_POWER_SAVE_MODE     = 0xB0,
    SET_PHASE_PERIOD_ADJ    = 0xB1,
    SET_DISPLAY_CLOCK_DIV   = 0xB3,
    SET_GRAY_SCALE_TABLE    = 0xB8,
    SET_BUILTIN_LINEAR_LUT  = 0xB9,
    SET_PRECHARGE_LEVEL     = 0xBB,
    SET_VCOMH_VOLTAGE       = 0xBE,

    SET_COMMAND_LOCK    = 0xFD
};

enum ssd1331_graphic_acceleration_command_table {
    DRAW_LINE       = 0x21,
    DRAW_RECTANGLE  = 0x22,
    COPY_WINDOW     = 0x23,
    DIM_WINDOW      = 0x24,
    CLEAR_WINDOW    = 0x25,
    FILL_WINDOW     = 0x26,

    CONTINUOUS_SCROLLING_SETUP  = 0x27,
    DEACTIVATE_SCROLLING        = 0x2E,
    ACTIVATE_SCROLLING          = 0x2F
};

static void ssd1331_write_byte(unsigned char chData, unsigned char chCmd)
{
    if (chCmd == SSD1331_DATA) {
        SSD1331_DC_SET();
    } else {
        SSD1331_DC_CLR();
    }

    SSD1331_CS_CLR();
    SSD1331_WRITE_BYTE(chData);
    SSD1331_CS_SET();
}

void ssd1331_draw_point(unsigned char chXpos, unsigned char chYpos, unsigned int hwColor)
{
    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(SET_COLUMN_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos, SSD1331_CMD);

    ssd1331_write_byte(SET_ROW_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);

    ssd1331_write_byte(hwColor >> 8, SSD1331_DATA);
    ssd1331_write_byte(hwColor, SSD1331_DATA);
}

void ssd1331_draw_line(unsigned char chXpos0, unsigned char chYpos0, unsigned char chXpos1, unsigned char chYpos1, unsigned int hwColor)
{
    if (chXpos0 >= SSD1331_WIDTH || chYpos0 >= SSD1331_HEIGHT || chXpos1 >= SSD1331_WIDTH || chYpos1 >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(DRAW_LINE, SSD1331_CMD);

    ssd1331_write_byte(chXpos0, SSD1331_CMD);
    ssd1331_write_byte(chYpos0, SSD1331_CMD);
    ssd1331_write_byte(chXpos1, SSD1331_CMD);
    ssd1331_write_byte(chYpos1, SSD1331_CMD);

    ssd1331_write_byte(hwColor >> 10, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 5, SSD1331_CMD);
    ssd1331_write_byte(hwColor << 1, SSD1331_CMD);
}

void ssd1331_draw_v_line(unsigned char chXpos, unsigned char chYpos, unsigned char chHeight, unsigned int hwColor)
{
    unsigned int y1 = min(chYpos + chHeight, SSD1331_HEIGHT - 1);

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(DRAW_LINE, SSD1331_CMD);

    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(y1, SSD1331_CMD);

    ssd1331_write_byte(hwColor << 1, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 5, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 11, SSD1331_CMD);
}

void ssd1331_draw_h_line(unsigned char chXpos, unsigned char chYpos, unsigned char chWidth, unsigned int hwColor)
{
    unsigned int x1 = min(chXpos + chWidth, SSD1331_WIDTH- 1);

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(DRAW_LINE, SSD1331_CMD);

    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(x1, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);

    ssd1331_write_byte(hwColor << 1, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 5, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 11, SSD1331_CMD);
}

void ssd1331_draw_rect(unsigned char chXpos, unsigned char chYpos, unsigned char chWidth, unsigned char chHeight, unsigned int hwColor)
{
    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(FILL_WINDOW, SSD1331_CMD);
    ssd1331_write_byte(0x00, SSD1331_CMD);

    ssd1331_write_byte(DRAW_RECTANGLE, SSD1331_CMD);

    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos + chWidth - 1, SSD1331_CMD);
    ssd1331_write_byte(chYpos + chHeight - 1, SSD1331_CMD);

    ssd1331_write_byte(hwColor >> 10, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 5, SSD1331_CMD);
    ssd1331_write_byte(hwColor << 1, SSD1331_CMD);

    ssd1331_write_byte(0x00, SSD1331_CMD);
    ssd1331_write_byte(0x00, SSD1331_CMD);
    ssd1331_write_byte(0x00, SSD1331_CMD);
}

void ssd1331_draw_circle(unsigned char chXpos, unsigned char chYpos, unsigned char chRadius, unsigned int hwColor)
{
    int x = -chRadius, y = 0, err = 2 - 2 * chRadius, e2;

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    do {
        ssd1331_draw_point(chXpos - x, chYpos + y, hwColor);
        ssd1331_draw_point(chXpos + x, chYpos + y, hwColor);
        ssd1331_draw_point(chXpos + x, chYpos - y, hwColor);
        ssd1331_draw_point(chXpos - x, chYpos - y, hwColor);
        e2 = err;
        if (e2 <= y) {
            err += ++y * 2 + 1;
            if(-x == y && e2 <= x) e2 = 0;
        }
        if(e2 > x) err += ++x * 2 + 1;
    } while (x <= 0);
}

void ssd1331_draw_mono_bitmap(unsigned char chXpos, unsigned char chYpos, const unsigned char *pchBmp, unsigned char chWidth, unsigned char chHeight, unsigned int hwForeColor, unsigned int hwBackColor)
{
    unsigned char i, j, byteWidth = (chWidth + 7) / 8;

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(SET_COLUMN_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos + chWidth - 1, SSD1331_CMD);

    ssd1331_write_byte(SET_ROW_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos + chHeight - 1, SSD1331_CMD);

    for (i = 0; i < chHeight; i++) {
        for (j = 0; j < chWidth; j++) {
            if(*(pchBmp + j * byteWidth + i / 8) & (128 >> (i & 7))) {
                ssd1331_write_byte(hwForeColor >> 8, SSD1331_DATA);
                ssd1331_write_byte(hwForeColor, SSD1331_DATA);
            } else {
                ssd1331_write_byte(hwBackColor >> 8, SSD1331_DATA);
                ssd1331_write_byte(hwBackColor, SSD1331_DATA);
            }
        }
    }
}

void ssd1331_draw_64k_bitmap(unsigned char chXpos, unsigned char chYpos, const unsigned char *pchBmp, unsigned char chWidth, unsigned char chHeight)
{
    unsigned char i, j;

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(SET_COLUMN_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos + chWidth - 1, SSD1331_CMD);

    ssd1331_write_byte(SET_ROW_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos + chHeight - 1, SSD1331_CMD);

    for (i = 0; i < chHeight; i++) {
        for (j = 0; j < chWidth; j++) {
            ssd1331_write_byte(*pchBmp++, SSD1331_DATA);
            ssd1331_write_byte(*pchBmp++, SSD1331_DATA);
        }
    }
}

void ssd1331_fill_rect(unsigned char chXpos, unsigned char chYpos, unsigned char chWidth, unsigned char chHeight, unsigned int hwColor)
{
    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(FILL_WINDOW, SSD1331_CMD);
    ssd1331_write_byte(0x01, SSD1331_CMD);

    ssd1331_write_byte(DRAW_RECTANGLE, SSD1331_CMD);

    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos + chWidth - 1, SSD1331_CMD);
    ssd1331_write_byte(chYpos + chHeight - 1, SSD1331_CMD);

    ssd1331_write_byte(hwColor >> 10, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 5, SSD1331_CMD);
    ssd1331_write_byte(hwColor << 1, SSD1331_CMD);

    ssd1331_write_byte(hwColor >> 10, SSD1331_CMD);
    ssd1331_write_byte(hwColor >> 5, SSD1331_CMD);
    ssd1331_write_byte(hwColor << 1, SSD1331_CMD);
}

void ssd1331_fill_gram(unsigned int hwColor)
{
    ssd1331_fill_rect(0x00, 0x00, SSD1331_WIDTH, SSD1331_HEIGHT, hwColor);
}

void ssd1331_clear_rect(unsigned char chXpos, unsigned char chYpos, unsigned char chWidth, unsigned char chHeight)
{
    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    ssd1331_write_byte(CLEAR_WINDOW, SSD1331_CMD);
    ssd1331_write_byte(chXpos, SSD1331_CMD);
    ssd1331_write_byte(chYpos, SSD1331_CMD);
    ssd1331_write_byte(chXpos + chWidth - 1, SSD1331_CMD);
    ssd1331_write_byte(chYpos + chHeight - 1, SSD1331_CMD);
}

void ssd1331_clear_gram(void)
{
    unsigned char i, j;

    for (i = 0; i < SSD1331_HEIGHT; i++) {
        for (j = 0; j < SSD1331_WIDTH; j++) {
            ssd1331_draw_point(j, i, Black);
        }
    }
}

void ssd1331_display_char(unsigned char chXpos, unsigned char chYpos, unsigned char chChr, unsigned char chFontIndex, unsigned int hwForeColor, unsigned int hwBackColor)
{
    unsigned char i, j;
    unsigned char chTemp, chYpos0 = chYpos;

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    for (i = 0; i < fonts_width[chFontIndex] * ((fonts_height[chFontIndex] + 7) / 8); i++) {
        switch (chFontIndex) {
            case FONT_1206:
                chTemp = c_chFont1206[chChr - ' '][i];
                break;
            case FONT_1608:
                chTemp = c_chFont1608[chChr - ' '][i];
                break;
            case FONT_3216:
                chTemp = c_chFont3216[chChr - ' '][i];
                break;
            default:
                chTemp = 0x00;
                break;
        }

        for (j = 0; j < 8; j++) {
            if (chTemp & 0x80) {
                ssd1331_draw_point(chXpos, chYpos, hwForeColor);
            } else {
                ssd1331_draw_point(chXpos, chYpos, hwBackColor);
            }
            chTemp <<= 1;
            chYpos++;

            if ((chYpos - chYpos0) == fonts_height[chFontIndex]) {
                chYpos = chYpos0;
                chXpos++;
                break;
            }
        }
    }
}

static unsigned long _pow(unsigned char m, unsigned char n)
{
    unsigned long result = 1;

    while (n --) result *= m;
    return result;
}

void ssd1331_display_num(unsigned char chXpos, unsigned char chYpos, unsigned long chNum, unsigned char chLen, unsigned char chFontIndex, unsigned int hwForeColor, unsigned int hwBackColor)
{
    unsigned char i;
    unsigned char chTemp, chShow = 0;

    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    for (i = 0; i < chLen; i++) {
        chTemp = (chNum / _pow(10, chLen - i - 1)) % 10;
        if (chShow == 0 && i < (chLen - 1)) {
            if(chTemp == 0) {
                ssd1331_display_char(chXpos + fonts_width[chFontIndex] * i, chYpos, ' ', chFontIndex, hwForeColor, hwBackColor);
                continue;
            } else {
                chShow = 1;
            }
        }
        ssd1331_display_char(chXpos + fonts_width[chFontIndex] * i, chYpos, chTemp + '0', chFontIndex, hwForeColor, hwBackColor);
    }
}

void ssd1331_display_string(unsigned char chXpos, unsigned char chYpos, const char *pchString, unsigned char chFontIndex, unsigned int hwForeColor, unsigned int hwBackColor)
{
    if (chXpos >= SSD1331_WIDTH || chYpos >= SSD1331_HEIGHT) {
        return;
    }

    while (*pchString != '\0') {
        if (chXpos > (SSD1331_WIDTH - fonts_width[chFontIndex])) {
            chXpos = 0;
            chYpos += fonts_height[chFontIndex];
            if (chYpos > (SSD1331_HEIGHT - fonts_height[chFontIndex])) {
                chYpos = chXpos = 0;
                ssd1331_clear_gram();
            }
        }

        ssd1331_display_char(chXpos, chYpos, *pchString, chFontIndex, hwForeColor, hwBackColor);
        chXpos += fonts_width[chFontIndex];
        pchString++;
    }
}

void ssd1331_continuous_scrolling(unsigned char chYpos, unsigned char chHeight, unsigned char chDirection, unsigned char chInterval)
{
    if (chYpos >= SSD1331_WIDTH || (chYpos+chHeight) >= SSD1331_WIDTH) {
        return;
    }

    ssd1331_write_byte(CONTINUOUS_SCROLLING_SETUP, SSD1331_CMD);
    ssd1331_write_byte(chDirection, SSD1331_DATA);
    ssd1331_write_byte(chYpos, SSD1331_DATA);
    ssd1331_write_byte(chHeight, SSD1331_DATA);
    ssd1331_write_byte(0x00, SSD1331_DATA);
    ssd1331_write_byte(chInterval, SSD1331_DATA);

    ssd1331_write_byte(ACTIVATE_SCROLLING, SSD1331_CMD);
}

void ssd1331_deactivate_scrolling(void)
{
    ssd1331_write_byte(DEACTIVATE_SCROLLING, SSD1331_CMD);
}

void ssd1331_show_checkerboard(void)
{
    unsigned char i,j;

    ssd1331_write_byte(SET_COLUMN_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(0x00, SSD1331_CMD);
    ssd1331_write_byte(SSD1331_WIDTH - 1, SSD1331_CMD);

    ssd1331_write_byte(SET_ROW_ADDRESS, SSD1331_CMD);
    ssd1331_write_byte(0x00, SSD1331_CMD);
    ssd1331_write_byte(SSD1331_HEIGHT - 1, SSD1331_CMD);

    for (i=0; i<SSD1331_HEIGHT/2; i++) {
        for (j=0; j<SSD1331_WIDTH/2; j++) {
            ssd1331_write_byte(0xFF, SSD1331_DATA);
            ssd1331_write_byte(0xFF, SSD1331_DATA);
            ssd1331_write_byte(0x00, SSD1331_DATA);
            ssd1331_write_byte(0x00, SSD1331_DATA);
        }
        for (j=0; j<SSD1331_WIDTH/2; j++) {
            ssd1331_write_byte(0x00, SSD1331_DATA);
            ssd1331_write_byte(0x00, SSD1331_DATA);
            ssd1331_write_byte(0xFF, SSD1331_DATA);
            ssd1331_write_byte(0xFF, SSD1331_DATA);
        }
    }
}

void ssd1331_show_rainbow(void)
{
    // White
    ssd1331_fill_rect(0x00, 0x00, 0x0C, SSD1331_HEIGHT, White);

    // Yellow
    ssd1331_fill_rect(0x0C, 0x00, 0x0C, SSD1331_HEIGHT, Yellow);

    // Cyan
    ssd1331_fill_rect(0x18, 0x00, 0x0C, SSD1331_HEIGHT, Cyan);

    // Green
    ssd1331_fill_rect(0x24, 0x00, 0x0C, SSD1331_HEIGHT, Lime);

    // Magenta
    ssd1331_fill_rect(0x30, 0x00, 0x0C, SSD1331_HEIGHT, Magenta);

    // Red
    ssd1331_fill_rect(0x3C, 0x00, 0x0C, SSD1331_HEIGHT, Red);

    // Blue
    ssd1331_fill_rect(0x48, 0x00, 0x0C, SSD1331_HEIGHT, Blue);

    // Black
    ssd1331_fill_rect(0x54, 0x00, 0x0C, SSD1331_HEIGHT, Black);
}

void ssd1331_set_gray_scale_table(void)
{
    ssd1331_write_byte(SET_GRAY_SCALE_TABLE, SSD1331_CMD);  // Set Pulse Width for Gray Scale Table
    ssd1331_write_byte(0x02, SSD1331_DATA);                 // Gray Scale Level 1
    ssd1331_write_byte(0x03, SSD1331_DATA);                 // Gray Scale Level 2
    ssd1331_write_byte(0x04, SSD1331_DATA);                 // Gray Scale Level 3
    ssd1331_write_byte(0x05, SSD1331_DATA);                 // Gray Scale Level 4
    ssd1331_write_byte(0x06, SSD1331_DATA);                 // Gray Scale Level 5
    ssd1331_write_byte(0x07, SSD1331_DATA);                 // Gray Scale Level 6
    ssd1331_write_byte(0x08, SSD1331_DATA);                 // Gray Scale Level 7
    ssd1331_write_byte(0x09, SSD1331_DATA);                 // Gray Scale Level 8
    ssd1331_write_byte(0x0A, SSD1331_DATA);                 // Gray Scale Level 9
    ssd1331_write_byte(0x0B, SSD1331_DATA);                 // Gray Scale Level 10
    ssd1331_write_byte(0x0C, SSD1331_DATA);                 // Gray Scale Level 11
    ssd1331_write_byte(0x0D, SSD1331_DATA);                 // Gray Scale Level 12
    ssd1331_write_byte(0x0E, SSD1331_DATA);                 // Gray Scale Level 13
    ssd1331_write_byte(0x0F, SSD1331_DATA);                 // Gray Scale Level 14
    ssd1331_write_byte(0x10, SSD1331_DATA);                 // Gray Scale Level 15
    ssd1331_write_byte(0x11, SSD1331_DATA);                 // Gray Scale Level 16
    ssd1331_write_byte(0x12, SSD1331_DATA);                 // Gray Scale Level 17
    ssd1331_write_byte(0x13, SSD1331_DATA);                 // Gray Scale Level 18
    ssd1331_write_byte(0x15, SSD1331_DATA);                 // Gray Scale Level 19
    ssd1331_write_byte(0x17, SSD1331_DATA);                 // Gray Scale Level 20
    ssd1331_write_byte(0x19, SSD1331_DATA);                 // Gray Scale Level 21
    ssd1331_write_byte(0x1B, SSD1331_DATA);                 // Gray Scale Level 22
    ssd1331_write_byte(0x1D, SSD1331_DATA);                 // Gray Scale Level 23
    ssd1331_write_byte(0x1F, SSD1331_DATA);                 // Gray Scale Level 24
    ssd1331_write_byte(0x21, SSD1331_DATA);                 // Gray Scale Level 25
    ssd1331_write_byte(0x23, SSD1331_DATA);                 // Gray Scale Level 26
    ssd1331_write_byte(0x25, SSD1331_DATA);                 // Gray Scale Level 27
    ssd1331_write_byte(0x27, SSD1331_DATA);                 // Gray Scale Level 28
    ssd1331_write_byte(0x2A, SSD1331_DATA);                 // Gray Scale Level 29
    ssd1331_write_byte(0x2D, SSD1331_DATA);                 // Gray Scale Level 30
    ssd1331_write_byte(0x30, SSD1331_DATA);                 // Gray Scale Level 31
    ssd1331_write_byte(0x33, SSD1331_DATA);                 // Gray Scale Level 32
    ssd1331_write_byte(0x36, SSD1331_DATA);                 // Gray Scale Level 33
    ssd1331_write_byte(0x39, SSD1331_DATA);                 // Gray Scale Level 34
    ssd1331_write_byte(0x3C, SSD1331_DATA);                 // Gray Scale Level 35
    ssd1331_write_byte(0x3F, SSD1331_DATA);                 // Gray Scale Level 36
    ssd1331_write_byte(0x42, SSD1331_DATA);                 // Gray Scale Level 37
    ssd1331_write_byte(0x45, SSD1331_DATA);                 // Gray Scale Level 38
    ssd1331_write_byte(0x48, SSD1331_DATA);                 // Gray Scale Level 39
    ssd1331_write_byte(0x4C, SSD1331_DATA);                 // Gray Scale Level 40
    ssd1331_write_byte(0x50, SSD1331_DATA);                 // Gray Scale Level 41
    ssd1331_write_byte(0x54, SSD1331_DATA);                 // Gray Scale Level 42
    ssd1331_write_byte(0x58, SSD1331_DATA);                 // Gray Scale Level 43
    ssd1331_write_byte(0x5C, SSD1331_DATA);                 // Gray Scale Level 44
    ssd1331_write_byte(0x60, SSD1331_DATA);                 // Gray Scale Level 45
    ssd1331_write_byte(0x64, SSD1331_DATA);                 // Gray Scale Level 46
    ssd1331_write_byte(0x68, SSD1331_DATA);                 // Gray Scale Level 47
    ssd1331_write_byte(0x6C, SSD1331_DATA);                 // Gray Scale Level 48
    ssd1331_write_byte(0x70, SSD1331_DATA);                 // Gray Scale Level 49
    ssd1331_write_byte(0x74, SSD1331_DATA);                 // Gray Scale Level 50
    ssd1331_write_byte(0x78, SSD1331_DATA);                 // Gray Scale Level 51
    ssd1331_write_byte(0x7D, SSD1331_DATA);                 // Gray Scale Level 52
    ssd1331_write_byte(0x82, SSD1331_DATA);                 // Gray Scale Level 53
    ssd1331_write_byte(0x87, SSD1331_DATA);                 // Gray Scale Level 54
    ssd1331_write_byte(0x8C, SSD1331_DATA);                 // Gray Scale Level 55
    ssd1331_write_byte(0x91, SSD1331_DATA);                 // Gray Scale Level 56
    ssd1331_write_byte(0x96, SSD1331_DATA);                 // Gray Scale Level 57
    ssd1331_write_byte(0x9B, SSD1331_DATA);                 // Gray Scale Level 58
    ssd1331_write_byte(0xA0, SSD1331_DATA);                 // Gray Scale Level 59
    ssd1331_write_byte(0xA5, SSD1331_DATA);                 // Gray Scale Level 60
    ssd1331_write_byte(0xAA, SSD1331_DATA);                 // Gray Scale Level 61
    ssd1331_write_byte(0xAF, SSD1331_DATA);                 // Gray Scale Level 62
    ssd1331_write_byte(0xB4, SSD1331_DATA);                 // Gray Scale Level 63
}

void ssd1331_init(void)
{
    // init dc pin
    dc_pin_handle = csi_gpio_pin_initialize(LCD_DC_PIN, NULL);

    csi_gpio_pin_config_mode(dc_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(dc_pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(dc_pin_handle, true);

    // init cs pin
    cs_pin_handle = csi_gpio_pin_initialize(LCD_CS_PIN, NULL);

    csi_gpio_pin_config_mode(cs_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(cs_pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(cs_pin_handle, true);

    // init rst pin
    rst_pin_handle = csi_gpio_pin_initialize(LCD_RST_PIN, NULL);

    csi_gpio_pin_config_mode(rst_pin_handle, GPIO_MODE_PULLNONE);
    csi_gpio_pin_config_direction(rst_pin_handle, GPIO_DIRECTION_OUTPUT);

    csi_gpio_pin_write(rst_pin_handle, true);

    // init spi device
    spi_handle = csi_spi_initialize(SPI_DEV_IDX, NULL);

    csi_spi_config(spi_handle, 20000000, SPI_MODE_MASTER, SPI_FORMAT_CPOL0_CPHA0, SPI_ORDER_MSB2LSB, SPI_SS_MASTER_SW, 8);
    csi_spi_config_block_mode(spi_handle, 1);

    SSD1331_PIN_SET();
    SSD1331_RES_SET();

    ssd1331_write_byte(SET_DISPLAY_OFF, SSD1331_CMD);           // Display Off

    ssd1331_write_byte(SET_REMAP_COLOR_DEPTH, SSD1331_CMD);     // Set Re-Map / Color Depth
    ssd1331_write_byte(0x72, SSD1331_CMD);                      // Set Horizontal Address Increment
    ssd1331_write_byte(SET_DISPLAY_START_LINE, SSD1331_CMD);    // Set Vertical Scroll by RAM
    ssd1331_write_byte(0x00, SSD1331_CMD);                      // Set Mapping RAM Display Start Line
    ssd1331_write_byte(SET_DISPLAY_OFFSET, SSD1331_CMD);        // Set Vertical Scroll by Row
    ssd1331_write_byte(0x00, SSD1331_CMD);                      // Shift Mapping RAM Counter

    ssd1331_write_byte(SET_NORMAL_DISPLAY, SSD1331_CMD);        // Normal Display Mode

    ssd1331_write_byte(SET_MULTIPLEX_RATIO, SSD1331_CMD);       // Set Multiplex Ratio
    ssd1331_write_byte(0x3F, SSD1331_CMD);                      // 1/128 Duty
    ssd1331_write_byte(SET_MASTER_CONFIG, SSD1331_CMD);         // Master Contrast Configuration
    ssd1331_write_byte(0x8E, SSD1331_CMD);                      // Maximum
    ssd1331_write_byte(SET_POWER_SAVE_MODE, SSD1331_CMD);       // Set Power Saving Mode
    ssd1331_write_byte(0x0B, SSD1331_CMD);                      // Disable Power Saving Mode
    ssd1331_write_byte(SET_PHASE_PERIOD_ADJ, SSD1331_CMD);      // Set Reset (Phase1)/Pre-charge (Phase 2) period
    ssd1331_write_byte(0x31, SSD1331_CMD);                      // 0x31
    ssd1331_write_byte(SET_DISPLAY_CLOCK_DIV, SSD1331_CMD);     // Set Display Clock Divider / Oscillator Frequency
    ssd1331_write_byte(0xF0, SSD1331_CMD);                      // 0xF0

    ssd1331_write_byte(SET_PRECHARGE_SPEED_A, SSD1331_CMD);     // Set Second Pre-charge Speed of Color A
    ssd1331_write_byte(0x64, SSD1331_CMD);                      // 100
    ssd1331_write_byte(SET_PRECHARGE_SPEED_B, SSD1331_CMD);     // Set Second Pre-charge Speed of Color B
    ssd1331_write_byte(0x78, SSD1331_CMD);                      // 120
    ssd1331_write_byte(SET_PRECHARGE_SPEED_C, SSD1331_CMD);     // Set Second Pre-charge Speed of Color C
    ssd1331_write_byte(0x64, SSD1331_CMD);                      // 100

    ssd1331_write_byte(SET_PRECHARGE_LEVEL, SSD1331_CMD);       // Set Pre-charge Level
    ssd1331_write_byte(0x3A, SSD1331_CMD);                      // 0x3A
    ssd1331_write_byte(SET_VCOMH_VOLTAGE, SSD1331_CMD);         // Set COM Deselect Voltage Level
    ssd1331_write_byte(0x3E, SSD1331_CMD);                      // 0.83*VCC
    ssd1331_write_byte(SET_MASTER_CURRENT, SSD1331_CMD);        // Master Contrast Current Control
    ssd1331_write_byte(0x0F, SSD1331_CMD);                      // Maximum

    ssd1331_write_byte(SET_CONTRAST_A, SSD1331_CMD);            // Set Contrast Current for Color A
    ssd1331_write_byte(0x91, SSD1331_CMD);                      // 145 0x91
    ssd1331_write_byte(SET_CONTRAST_B, SSD1331_CMD);            // Set Contrast Current for Color B
    ssd1331_write_byte(0x50, SSD1331_CMD);                      // 80 0x50
    ssd1331_write_byte(SET_CONTRAST_C, SSD1331_CMD);            // Set Contrast Current for Color C
    ssd1331_write_byte(0x7D, SSD1331_CMD);                      // 125 0x7D

    ssd1331_clear_gram();

    ssd1331_write_byte(SET_DISPLAY_ON_NORMAL, SSD1331_CMD);     // Display On
}
