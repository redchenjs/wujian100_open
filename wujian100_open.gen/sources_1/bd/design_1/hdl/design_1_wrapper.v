//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.1.1 (win64) Build 3900603 Fri Jun 16 19:31:24 MDT 2023
//Date        : Thu Aug 17 16:22:22 2023
//Host        : ThinkBook running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (EXT_BEEP,
    EXT_JTAG_TCK_0,
    EXT_JTAG_TCK_1,
    EXT_JTAG_TMS_0,
    EXT_JTAG_TMS_1,
    EXT_KEY_1,
    EXT_KEY_2,
    EXT_KEY_3,
    EXT_KEY_4,
    EXT_LCD_BL,
    EXT_LCD_CS,
    EXT_LCD_DC,
    EXT_LCD_RST,
    EXT_LED_1,
    EXT_LED_2,
    EXT_LED_3,
    EXT_LED_4,
    EXT_SPI_NSS_0,
    EXT_SPI_NSS_1,
    EXT_SPI_SCK,
    EXT_SPI_SDI,
    EXT_SPI_SDO,
    EXT_SW_0,
    EXT_SW_1,
    EXT_UART_RXD_0,
    EXT_UART_RXD_1,
    EXT_UART_TXD_0,
    EXT_UART_TXD_1,
    EXT_WS2812,
    PL_CLK_200M_N,
    PL_CLK_200M_P,
    PL_CLK_32K);
  inout EXT_BEEP;
  inout EXT_JTAG_TCK_0;
  inout EXT_JTAG_TCK_1;
  inout EXT_JTAG_TMS_0;
  inout EXT_JTAG_TMS_1;
  input EXT_KEY_1;
  input EXT_KEY_2;
  input EXT_KEY_3;
  input EXT_KEY_4;
  inout EXT_LCD_BL;
  inout EXT_LCD_CS;
  inout EXT_LCD_DC;
  inout EXT_LCD_RST;
  output EXT_LED_1;
  inout EXT_LED_2;
  output EXT_LED_3;
  inout EXT_LED_4;
  inout EXT_SPI_NSS_0;
  inout EXT_SPI_NSS_1;
  inout EXT_SPI_SCK;
  inout EXT_SPI_SDI;
  inout EXT_SPI_SDO;
  inout EXT_SW_0;
  inout EXT_SW_1;
  inout EXT_UART_RXD_0;
  inout EXT_UART_RXD_1;
  inout EXT_UART_TXD_0;
  inout EXT_UART_TXD_1;
  output EXT_WS2812;
  input PL_CLK_200M_N;
  input PL_CLK_200M_P;
  input PL_CLK_32K;

  wire EXT_BEEP;
  wire EXT_JTAG_TCK_0;
  wire EXT_JTAG_TCK_1;
  wire EXT_JTAG_TMS_0;
  wire EXT_JTAG_TMS_1;
  wire EXT_KEY_1;
  wire EXT_KEY_2;
  wire EXT_KEY_3;
  wire EXT_KEY_4;
  wire EXT_LCD_BL;
  wire EXT_LCD_CS;
  wire EXT_LCD_DC;
  wire EXT_LCD_RST;
  wire EXT_LED_1;
  wire EXT_LED_2;
  wire EXT_LED_3;
  wire EXT_LED_4;
  wire EXT_SPI_NSS_0;
  wire EXT_SPI_NSS_1;
  wire EXT_SPI_SCK;
  wire EXT_SPI_SDI;
  wire EXT_SPI_SDO;
  wire EXT_SW_0;
  wire EXT_SW_1;
  wire EXT_UART_RXD_0;
  wire EXT_UART_RXD_1;
  wire EXT_UART_TXD_0;
  wire EXT_UART_TXD_1;
  wire EXT_WS2812;
  wire PL_CLK_200M_N;
  wire PL_CLK_200M_P;
  wire PL_CLK_32K;

  design_1 design_1_i
       (.EXT_BEEP(EXT_BEEP),
        .EXT_JTAG_TCK_0(EXT_JTAG_TCK_0),
        .EXT_JTAG_TCK_1(EXT_JTAG_TCK_1),
        .EXT_JTAG_TMS_0(EXT_JTAG_TMS_0),
        .EXT_JTAG_TMS_1(EXT_JTAG_TMS_1),
        .EXT_KEY_1(EXT_KEY_1),
        .EXT_KEY_2(EXT_KEY_2),
        .EXT_KEY_3(EXT_KEY_3),
        .EXT_KEY_4(EXT_KEY_4),
        .EXT_LCD_BL(EXT_LCD_BL),
        .EXT_LCD_CS(EXT_LCD_CS),
        .EXT_LCD_DC(EXT_LCD_DC),
        .EXT_LCD_RST(EXT_LCD_RST),
        .EXT_LED_1(EXT_LED_1),
        .EXT_LED_2(EXT_LED_2),
        .EXT_LED_3(EXT_LED_3),
        .EXT_LED_4(EXT_LED_4),
        .EXT_SPI_NSS_0(EXT_SPI_NSS_0),
        .EXT_SPI_NSS_1(EXT_SPI_NSS_1),
        .EXT_SPI_SCK(EXT_SPI_SCK),
        .EXT_SPI_SDI(EXT_SPI_SDI),
        .EXT_SPI_SDO(EXT_SPI_SDO),
        .EXT_SW_0(EXT_SW_0),
        .EXT_SW_1(EXT_SW_1),
        .EXT_UART_RXD_0(EXT_UART_RXD_0),
        .EXT_UART_RXD_1(EXT_UART_RXD_1),
        .EXT_UART_TXD_0(EXT_UART_TXD_0),
        .EXT_UART_TXD_1(EXT_UART_TXD_1),
        .EXT_WS2812(EXT_WS2812),
        .PL_CLK_200M_N(PL_CLK_200M_N),
        .PL_CLK_200M_P(PL_CLK_200M_P),
        .PL_CLK_32K(PL_CLK_32K));
endmodule
