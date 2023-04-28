set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PAD_JTAG_TCLK_0]

set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {PAD_MCURST_0}]

set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {PAD_JTAG_TCLK_0}]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {PAD_JTAG_TMS_0}]

set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {PAD_USI0_NSS_0}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {PAD_USI0_SCLK_0}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {PAD_USI0_SD0_0}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {PAD_USI0_SD1_0}]

set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {PAD_USI1_SD0_0}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {PAD_USI1_SD1_0}]

set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {PAD_USI2_SD0_0}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {PAD_USI2_SD1_0}]
