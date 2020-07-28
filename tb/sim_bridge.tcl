source ../util.tcl

## Device setting (KCU105)
set p_device "xcku040-ffva1156-2-e"
set p_board "xilinx.com:kcu105:part0:1.5"

set project_name "tb_bridge"
set project_system_dir "./tb_bridge/$project_name.srcs/sources_1/bd/adapter_test"

create_project -force $project_name ./${project_name} -part $p_device
set_property board_part $p_board [current_project]

## Add sources
### Verilog
add_files {\
    ../src/adapter_8_32.v \
    ../src/adapter_8_32_r.v \
    ../src/adapter_8_32_w.v \
    ../src/rbcp_bridge.v \
}

## IP integrator
create_bd_design "adapter_test"

### rbcp bridge
create_bd_cell -type module -reference rbcp_bridge rbcp_bridge

### adapter
create_bd_cell -type module -reference adapter_8_32 adapter_8_32

### reset
create_bd_cell -type ip -vlnv [latest_ip proc_sys_reset] proc_sys_reset



### gpio
create_bd_cell -type ip -vlnv [latest_ip axi_gpio] axi_gpio
set_property -dict [list \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1}\
    ] [get_bd_cells axi_gpio]

### interconnect
create_bd_cell -type ip -vlnv [latest_ip axi_interconnect] axi_interconnect
set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells axi_interconnect]

### connection
make_bd_pins_external -name "clk" [get_bd_pins rbcp_bridge/clk]
make_bd_pins_external -name "rst" [get_bd_pins proc_sys_reset/ext_reset_in]
make_bd_pins_external -name "aux_reset_in" [get_bd_pins proc_sys_reset/aux_reset_in]


#### reset generator
connect_bd_net [get_bd_ports clk] [get_bd_pins proc_sys_reset/slowest_sync_clk]

#### rbcp
make_bd_pins_external -name "rbcp_act" [get_bd_pins rbcp_bridge/rbcp_act]
make_bd_pins_external -name "rbcp_addr" [get_bd_pins rbcp_bridge/rbcp_addr]
make_bd_pins_external -name "rbcp_wd" [get_bd_pins rbcp_bridge/rbcp_wd]
make_bd_pins_external -name "rbcp_we" [get_bd_pins rbcp_bridge/rbcp_we]
make_bd_pins_external -name "rbcp_re" [get_bd_pins rbcp_bridge/rbcp_re]
make_bd_pins_external -name "rbcp_rd" [get_bd_pins rbcp_bridge/rbcp_rd]
make_bd_pins_external -name "rbcp_ack" [get_bd_pins rbcp_bridge/rbcp_ack]
connect_bd_net [get_bd_pins proc_sys_reset/peripheral_reset] [get_bd_pins rbcp_bridge/rst]


#### adapter
connect_bd_intf_net [get_bd_intf_pins rbcp_bridge/m_axi] [get_bd_intf_pins adapter_8_32/s_axi]
connect_bd_net [get_bd_ports clk] [get_bd_pins adapter_8_32/clk]
connect_bd_net [get_bd_pins adapter_8_32/rst] [get_bd_pins proc_sys_reset/peripheral_reset]


#### interconnect
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_interconnect/ACLK]
connect_bd_net [get_bd_pins proc_sys_reset/interconnect_aresetn] [get_bd_pins axi_interconnect/ARESETN]

connect_bd_intf_net [get_bd_intf_pins adapter_8_32/m_axi] -boundary_type upper [get_bd_intf_pins axi_interconnect/S00_AXI]
connect_bd_net [get_bd_pins proc_sys_reset/peripheral_aresetn] [get_bd_pins axi_interconnect/S00_ARESETN]
connect_bd_net [get_bd_pins axi_interconnect/M00_ARESETN] [get_bd_pins proc_sys_reset/peripheral_aresetn]
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_interconnect/S00_ACLK]
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_interconnect/M00_ACLK]

#### gpio
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect/M00_AXI] [get_bd_intf_pins axi_gpio/S_AXI]
connect_bd_net [get_bd_pins axi_gpio/s_axi_aresetn] [get_bd_pins proc_sys_reset/peripheral_aresetn]
connect_bd_net [get_bd_ports clk] [get_bd_pins axi_gpio/s_axi_aclk]
make_bd_intf_pins_external -name GPIO_0 [get_bd_intf_pins axi_gpio/GPIO]
make_bd_intf_pins_external -name GPIO_1 [get_bd_intf_pins axi_gpio/GPIO2]

assign_bd_address
save_bd_design
validate_bd_design


## File
set_property synth_checkpoint_mode None [get_files  $project_system_dir/adapter_test.bd]
generate_target {synthesis implementation} [get_files  $project_system_dir/adapter_test.bd]
make_wrapper -files [get_files $project_system_dir/adapter_test.bd] -top
import_files -force -norecurse -fileset sources_1 $project_system_dir/hdl/adapter_test_wrapper.v


## Simulation
add_files -fileset sim_1 -norecurse C:/Users/kucmb/jsuzuki/fpga_projects/sitcp_test/tb/sim_bridge.sv
