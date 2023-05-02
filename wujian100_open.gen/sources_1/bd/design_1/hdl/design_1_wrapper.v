//Copyright 1986-2023 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2.2 (win64) Build 3788238 Tue Feb 21 20:00:34 MST 2023
//Date        : Mon May  1 21:11:08 2023
//Host        : ThinPC running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    EXT_FLASH_NSS,
    EXT_FLASH_SCK,
    EXT_FLASH_SDI,
    EXT_FLASH_SDO,
    EXT_JTAG_TCK_0,
    EXT_JTAG_TCK_1,
    EXT_JTAG_TMS_0,
    EXT_JTAG_TMS_1,
    EXT_KEY_1,
    EXT_KEY_2,
    EXT_LED_1,
    EXT_LED_2,
    EXT_LED_3,
    EXT_LED_4,
    EXT_MCU_NRST_0,
    EXT_MCU_NRST_1,
    EXT_UART_RXD_0,
    EXT_UART_RXD_1,
    EXT_UART_TXD_0,
    EXT_UART_TXD_1,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    PL_CLK_32K,
    PL_CLK_50M);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout EXT_FLASH_NSS;
  inout EXT_FLASH_SCK;
  inout EXT_FLASH_SDI;
  inout EXT_FLASH_SDO;
  inout EXT_JTAG_TCK_0;
  inout EXT_JTAG_TCK_1;
  inout EXT_JTAG_TMS_0;
  inout EXT_JTAG_TMS_1;
  input EXT_KEY_1;
  input EXT_KEY_2;
  output [0:0]EXT_LED_1;
  inout EXT_LED_2;
  output [0:0]EXT_LED_3;
  inout EXT_LED_4;
  input EXT_MCU_NRST_0;
  input EXT_MCU_NRST_1;
  inout EXT_UART_RXD_0;
  inout EXT_UART_RXD_1;
  inout EXT_UART_TXD_0;
  inout EXT_UART_TXD_1;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input PL_CLK_32K;
  input PL_CLK_50M;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire EXT_FLASH_NSS;
  wire EXT_FLASH_SCK;
  wire EXT_FLASH_SDI;
  wire EXT_FLASH_SDO;
  wire EXT_JTAG_TCK_0;
  wire EXT_JTAG_TCK_1;
  wire EXT_JTAG_TMS_0;
  wire EXT_JTAG_TMS_1;
  wire EXT_KEY_1;
  wire EXT_KEY_2;
  wire [0:0]EXT_LED_1;
  wire EXT_LED_2;
  wire [0:0]EXT_LED_3;
  wire EXT_LED_4;
  wire EXT_MCU_NRST_0;
  wire EXT_MCU_NRST_1;
  wire EXT_UART_RXD_0;
  wire EXT_UART_RXD_1;
  wire EXT_UART_TXD_0;
  wire EXT_UART_TXD_1;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire PL_CLK_32K;
  wire PL_CLK_50M;

  design_1 design_1_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .EXT_FLASH_NSS(EXT_FLASH_NSS),
        .EXT_FLASH_SCK(EXT_FLASH_SCK),
        .EXT_FLASH_SDI(EXT_FLASH_SDI),
        .EXT_FLASH_SDO(EXT_FLASH_SDO),
        .EXT_JTAG_TCK_0(EXT_JTAG_TCK_0),
        .EXT_JTAG_TCK_1(EXT_JTAG_TCK_1),
        .EXT_JTAG_TMS_0(EXT_JTAG_TMS_0),
        .EXT_JTAG_TMS_1(EXT_JTAG_TMS_1),
        .EXT_KEY_1(EXT_KEY_1),
        .EXT_KEY_2(EXT_KEY_2),
        .EXT_LED_1(EXT_LED_1),
        .EXT_LED_2(EXT_LED_2),
        .EXT_LED_3(EXT_LED_3),
        .EXT_LED_4(EXT_LED_4),
        .EXT_MCU_NRST_0(EXT_MCU_NRST_0),
        .EXT_MCU_NRST_1(EXT_MCU_NRST_1),
        .EXT_UART_RXD_0(EXT_UART_RXD_0),
        .EXT_UART_RXD_1(EXT_UART_RXD_1),
        .EXT_UART_TXD_0(EXT_UART_TXD_0),
        .EXT_UART_TXD_1(EXT_UART_TXD_1),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .PL_CLK_32K(PL_CLK_32K),
        .PL_CLK_50M(PL_CLK_50M));
endmodule