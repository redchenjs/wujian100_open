create_generated_clock -name CLK_CORE_HS [get_pins design_1_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]

# create_clock -name CLK_CORE_HS   -period    20 [get_ports {PL_CLK_50M}]
create_clock -name CLK_CORE_LS   -period 30517 [get_ports {PL_CLK_32K}]
create_clock -name CLK_JTAG_CK_0 -period   500 [get_ports {EXT_JTAG_TCK_0}]
create_clock -name CLK_JTAG_CK_1 -period   500 [get_ports {EXT_JTAG_TCK_1}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {PL_CLK_32K}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {EXT_JTAG_TCK_0}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {EXT_JTAG_TCK_1}]

# set_clock_groups -asynchronous -group [get_clocks CLK_CORE_HS] -group [get_clocks CLK_CORE_LS]
# set_clock_groups -asynchronous -group [get_clocks CLK_CORE_HS] -group [get_clocks CLK_JTAG_CK_0]
# set_clock_groups -asynchronous -group [get_clocks CLK_CORE_HS] -group [get_clocks CLK_JTAG_CK_1]

set_property -dict {PACKAGE_PIN AE5 IOSTANDARD DIFF_SSTL12} [get_ports {PL_CLK_200M_P}]
set_property -dict {PACKAGE_PIN AF5 IOSTANDARD DIFF_SSTL12} [get_ports {PL_CLK_200M_N}]

set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS18} [get_ports {PL_CLK_32K}]

set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS18} [get_ports {EXT_SW_0}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS18} [get_ports {EXT_SW_1}]

set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_1}]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_2}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_3}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_4}]

set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_1}]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_2}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_3}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_4}]

set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_BEEP}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_WS2812}]

set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_SPI_NSS_0}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_SPI_NSS_1}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_SPI_SCK}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_SPI_SDI}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_SPI_SDO}]

set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_LCD_RST}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_LCD_DC}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_LCD_CS}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_LCD_BL}]

set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_JTAG_TCK_0}]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_JTAG_TMS_0}]
set_property -dict {PACKAGE_PIN F7 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_UART_TXD_0}]
set_property -dict {PACKAGE_PIN G8 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_UART_RXD_0}]

set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS18 PULLDOWN true} [get_ports {EXT_JTAG_TCK_1}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_JTAG_TMS_1}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_UART_TXD_1}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS18 PULLUP   true} [get_ports {EXT_UART_RXD_1}]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
