# SiTCP test on KCU105

## Utility
source ./util.tcl

## Device setting (KCU105)
set p_device "xcku040-ffva1156-2-e"
set p_board "xilinx.com:kcu105:part0:1.5"

set project_name "sitcp_test"

create_project -force $project_name ./${project_name} -part $p_device
set_property board_part $p_board [current_project]

## Add sources
### Verilog
add_files {\
    ./src/system.v \
    ../SiTCP_Netlist_for_Kintex_UltraScale/TIMER.v \
    ../SiTCP_Netlist_for_Kintex_UltraScale/WRAP_SiTCP_GMII_XCKU_32K.V \
    ../SiTCP_Netlist_for_Kintex_UltraScale/SiTCP_XCKU_32K_BBT_V110.edf \
    ../SiTCP_Netlist_for_Kintex_UltraScale/SiTCP_XCKU_32K_BBT_V110.V \
}

### Constraints
add_files -fileset constrs_1 -norecurse ../SiTCP_Netlist_for_Kintex_UltraScale/EDF_SiTCP_constraints.xdc

## IP core generation
### System reset
create_ip -vlnv [latest_ip proc_sys_reset] -module_name proc_sys_reset_0
set_property -dict [list CONFIG.RESET_BOARD_INTERFACE {reset}] [get_ips proc_sys_reset_0]

### MMCM
create_ip -vlnv [latest_ip clk_wiz] -module_name clk_wiz_0
set_property -dict [list \
    CONFIG.CLK_IN1_BOARD_INTERFACE {default_sysclk_300} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.PRIM_IN_FREQ {300.000} \
    CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
    CONFIG.MMCM_DIVCLK_DIVIDE {3} \
    CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.000} \
    CONFIG.CLKOUT1_JITTER {109.006}] [get_ips clk_wiz_0]


### Gig ethernet PCS PMA
create_ip -vlnv [latest_ip gig_ethernet_pcs_pma] -module_name gig_ethernet_pcs_pma
set_property -dict [list \
    CONFIG.ETHERNET_BOARD_INTERFACE {sgmii_lvds} \
    CONFIG.DIFFCLK_BOARD_INTERFACE {sgmii_phyclk} \
    CONFIG.Standard {SGMII} \
    CONFIG.Physical_Interface {LVDS} \
    CONFIG.Management_Interface {true} \
    CONFIG.Ext_Management_Interface {true} \
    CONFIG.MDIO_BOARD_INTERFACE {mdio_mdc} \
    CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
    CONFIG.LvdsRefClk {625} \
    CONFIG.GT_Location {X0Y11}] [get_ips gig_ethernet_pcs_pma]



# set project_system_dir "./${project_name}/${project_name}.srcs/sources_1/bd/system"

# set_property synth_checkpoint_mode None [get_files  $project_system_dir/system.bd]
# generate_target {synthesis implementation} [get_files  $project_system_dir/system.bd]
# make_wrapper -files [get_files $project_system_dir/system.bd] -top

# import_files -force -norecurse -fileset sources_1 $project_system_dir/hdl/system_wrapper.v
# set_property top system_wrapper [current_fileset]


# # Run
# ## Synthesis

# launch_runs synth_1
# wait_on_run synth_1
# open_run synth_1
# report_timing_summary -file timing_synth.log

# # ## Implementation
# set_property strategy Performance_Retiming [get_runs impl_1]
# launch_runs impl_1 -to_step write_bitstream
# wait_on_run impl_1
# open_run impl_1
# report_timing_summary -file timing_impl.log
