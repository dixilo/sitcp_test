# reset
set_property -dict  {PACKAGE_PIN  J23   IOSTANDARD  LVCMOS18}  [get_ports phy_rst_n]

# clock
set_property PACKAGE_PIN P26 [get_ports phy_clk_p]
set_property PACKAGE_PIN N26 [get_ports phy_clk_n]

set_property IOSTANDARD LVDS_25 [get_ports phy_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports phy_clk_n]
create_clock -name phy_clk_p -period 1.600 [get_ports phy_clk_p]
