`timescale 1ns / 1ps

module system(
    input wire ext_reset_in,
    input wire clk_in1_p,
    input wire clk_in1_n
    );

    wire sys_clk; // 250 MHz
    wire sys_rst;

    // Clocking wizard
    clk_wiz_0 clk_wiz_inst (
        .clk_in1_p(clk_in1_p),
        .clk_in1_n(clk_in1_n),	
        .reset(ext_reset_in),
        .locked(),
        .clk_out1(sys_clk)
    );

    // reset generator
    proc_sys_reset_0 sys_rst_inst (
        .slowest_sync_clk(sys_clk),
        .ext_reset_in(ext_reset_in),
        .aux_reset_in(),
        .mb_debug_sys_rst(),
        .dcm_locked(),
        .mb_reset(),
        .bus_struct_reset(),
        .peripheral_reset(sys_rst),
        .interconnect_aresetn(),
        .peripheral_aresetn()
    );

    gig_ethernet_pcs_pma gepp_inst (
        .txn(txn),                                    // output wire txn
        .txp(txp),                                    // output wire txp
        .rxn(rxn),                                    // input wire rxn
        .rxp(rxp),                                    // input wire rxp
        .mmcm_locked_out(mmcm_locked_out),            // output wire mmcm_locked_out
        .sgmii_clk_r(sgmii_clk_r),                    // output wire sgmii_clk_r
        .sgmii_clk_f(sgmii_clk_f),                    // output wire sgmii_clk_f
        .sgmii_clk_en(sgmii_clk_en),                  // output wire sgmii_clk_en
        .clk125_out(clk125_out),                      // output wire clk125_out
        .clk625_out(clk625_out),                      // output wire clk625_out
        .clk312_out(clk312_out),                      // output wire clk312_out
        .rst_125_out(rst_125_out),                    // output wire rst_125_out
        .refclk625_n(refclk625_n),                    // input wire refclk625_n
        .refclk625_p(refclk625_p),                    // input wire refclk625_p
        .gmii_txd(gmii_txd),                          // input wire [7 : 0] gmii_txd
        .gmii_tx_en(gmii_tx_en),                      // input wire gmii_tx_en
        .gmii_tx_er(gmii_tx_er),                      // input wire gmii_tx_er
        .gmii_rxd(gmii_rxd),                          // output wire [7 : 0] gmii_rxd
        .gmii_rx_dv(gmii_rx_dv),                      // output wire gmii_rx_dv
        .gmii_rx_er(gmii_rx_er),                      // output wire gmii_rx_er
        .gmii_isolate(gmii_isolate),                  // output wire gmii_isolate
        .mdc(mdc),                                    // input wire mdc
        .mdio_i(mdio_i),                              // input wire mdio_i
        .mdio_o(mdio_o),                              // output wire mdio_o
        .mdio_t(mdio_t),                              // output wire mdio_t
        .ext_mdc(ext_mdc),                            // output wire ext_mdc
        .ext_mdio_i(ext_mdio_i),                      // input wire ext_mdio_i
        .mdio_t_in(mdio_t_in),                        // input wire mdio_t_in
        .ext_mdio_o(ext_mdio_o),                      // output wire ext_mdio_o
        .ext_mdio_t(ext_mdio_t),                      // output wire ext_mdio_t
        .phyaddr(phyaddr),                            // input wire [4 : 0] phyaddr
        .configuration_vector(configuration_vector),  // input wire [4 : 0] configuration_vector
        .configuration_valid(configuration_valid),    // input wire configuration_valid
        .an_interrupt(an_interrupt),                  // output wire an_interrupt
        .an_adv_config_vector(an_adv_config_vector),  // input wire [15 : 0] an_adv_config_vector
        .an_adv_config_val(an_adv_config_val),        // input wire an_adv_config_val
        .an_restart_config(an_restart_config),        // input wire an_restart_config
        .speed_is_10_100(speed_is_10_100),            // input wire speed_is_10_100
        .speed_is_100(speed_is_100),                  // input wire speed_is_100
        .status_vector(status_vector),                // output wire [15 : 0] status_vector
        .reset(reset),                                // input wire reset
        .signal_detect(signal_detect),                // input wire signal_detect
        .idelay_rdy_out(idelay_rdy_out)              // output wire idelay_rdy_out
    );

    WRAP_SiTCP_GMII_XCKU_32K sitcp_inst(
        .CLK(sys_clk),
        .RST(sys_rst),
    // Configuration parameters
        FORCE_DEFAULTn		,	// in	: Load default parameters
        EXT_IP_ADDR			,	// in	: IP address[31:0]
        EXT_TCP_PORT		,	// in	: TCP port #[15:0]
        EXT_RBCP_PORT		,	// in	: RBCP port #[15:0]
        PHY_ADDR			,	// in	: PHY-device MIF address[4:0]
    // EEPROM
        EEPROM_CS			,	// out	: Chip select
        EEPROM_SK			,	// out	: Serial data clock
        EEPROM_DI			,	// out	: Serial write data
        EEPROM_DO			,	// in	: Serial read data
        // user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        USR_REG_X3C			,	// out	: Stored at 0xFFFF_FF3C
        USR_REG_X3D			,	// out	: Stored at 0xFFFF_FF3D
        USR_REG_X3E			,	// out	: Stored at 0xFFFF_FF3E
        USR_REG_X3F			,	// out	: Stored at 0xFFFF_FF3F
    // MII interface
        GMII_RSTn			,	// out	: PHY reset
        GMII_1000M			,	// in	: GMII mode (0:MII, 1:GMII)
        // TX
        GMII_TX_CLK			,	// in	: Tx clock
        GMII_TX_EN			,	// out	: Tx enable
        GMII_TXD			,	// out	: Tx data[7:0]
        GMII_TX_ER			,	// out	: TX error
        // RX
        GMII_RX_CLK			,	// in	: Rx clock
        GMII_RX_DV			,	// in	: Rx data valid
        GMII_RXD			,	// in	: Rx data[7:0]
        GMII_RX_ER			,	// in	: Rx error
        GMII_CRS			,	// in	: Carrier sense
        GMII_COL			,	// in	: Collision detected
        // Management IF
        GMII_MDC			,	// out	: Clock for MDIO
        GMII_MDIO_IN		,	// in	: Data
        GMII_MDIO_OUT		,	// out	: Data
        GMII_MDIO_OE		,	// out	: MDIO output enable
    // User I/F
        SiTCP_RST			,	// out	: Reset for SiTCP and related circuits
        // TCP connection control
        TCP_OPEN_REQ		,	// in	: Reserved input, shoud be 0
        TCP_OPEN_ACK		,	// out	: Acknowledge for open (=Socket busy)
        TCP_ERROR			,	// out	: TCP error, its active period is equal to MSL
        TCP_CLOSE_REQ		,	// out	: Connection close request
        TCP_CLOSE_ACK		,	// in	: Acknowledge for closing
        // FIFO I/F
        TCP_RX_WC			,	// in	: Rx FIFO write count[15:0] (Unused bits should be set 1)
        TCP_RX_WR			,	// out	: Write enable
        TCP_RX_DATA			,	// out	: Write data[7:0]
        TCP_TX_FULL			,	// out	: Almost full flag
        TCP_TX_WR			,	// in	: Write enable
        TCP_TX_DATA			,	// in	: Write data[7:0]
        // RBCP
        RBCP_ACT			,	// out	: RBCP active
        RBCP_ADDR			,	// out	: Address[31:0]
        RBCP_WD				,	// out	: Data[7:0]
        RBCP_WE				,	// out	: Write enable
        RBCP_RE				,	// out	: Read enable
        RBCP_ACK			,	// in	: Access acknowledge
        RBCP_RD					// in	: Read data[7:0]
    );
endmodule
