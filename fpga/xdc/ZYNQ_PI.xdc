create_clock -period 20 [get_ports {PL_CLK_50M}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {PL_CLK_32K}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {EXT_JTAG_TCK_0}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {EXT_JTAG_TCK_1}]

set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {PL_CLK_50M}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {PL_CLK_32K}]

set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {EXT_KEY_1}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {EXT_KEY_2}]

set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports {EXT_LED_1}]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {EXT_LED_2}]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports {EXT_LED_3}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {EXT_LED_4}]

set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {EXT_FLASH_NSS}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {EXT_FLASH_SCK}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {EXT_FLASH_SDI}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {EXT_FLASH_SDO}]

set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {EXT_MCU_NRST_0}]

set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {EXT_JTAG_TCK_0}]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {EXT_JTAG_TMS_0}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {EXT_UART_TXD_0}]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {EXT_UART_RXD_0}]

set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {EXT_MCU_NRST_1}]

set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33} [get_ports {EXT_JTAG_TCK_1}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33} [get_ports {EXT_JTAG_TMS_1}]
set_property -dict {PACKAGE_PIN U9  IOSTANDARD LVCMOS33} [get_ports {EXT_UART_TXD_1}]
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS33} [get_ports {EXT_UART_RXD_1}]
