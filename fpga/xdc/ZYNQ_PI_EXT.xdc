create_generated_clock -name CLK_CORE_HS [get_pins design_1_i/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]

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

set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {PL_CLK_50M}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports {PL_CLK_32K}]

set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_1}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_2}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_3}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS18} [get_ports {EXT_KEY_4}]

set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_1}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_2}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_3}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS18} [get_ports {EXT_LED_4}]

set_property -dict {PACKAGE_PIN W9  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_BEEP}]
set_property -dict {PACKAGE_PIN Y8  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_WS2812}]

set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_SPI_NSS_0}]
set_property -dict {PACKAGE_PIN U9  IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_SPI_NSS_1}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_SPI_SCK}]
set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_SPI_SDI}]
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_SPI_SDO}]

set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_LCD_RST}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_LCD_DC}]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_LCD_CS}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_LCD_BL}]

set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_JTAG_TCK_0}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_JTAG_TMS_0}]
set_property -dict {PACKAGE_PIN W6  IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_UART_TXD_0}]
set_property -dict {PACKAGE_PIN V6  IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_UART_RXD_0}]

set_property -dict {PACKAGE_PIN T5  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {EXT_JTAG_TCK_1}]
set_property -dict {PACKAGE_PIN V8  IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_JTAG_TMS_1}]
set_property -dict {PACKAGE_PIN U5  IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_UART_TXD_1}]
set_property -dict {PACKAGE_PIN W8  IOSTANDARD LVCMOS33 PULLUP   true} [get_ports {EXT_UART_RXD_1}]
