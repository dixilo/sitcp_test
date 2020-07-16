`timescale 1ns / 1ps

module system(
    input wire ext_reset_in,
    input wire clk_in1_p,
    input wire clk_in1_n,

    // phy signals
    input wire phy_clk_p,
    input wire phy_clk_n,
    input wire phy_rst_n,
    input wire phy_rxp,
    input wire phy_rxn,
    output wire phy_txp,
    output wire phy_txn

    // MDIO
//    input wire ext_mdio_i,
//    output wire ext_mdio_o,
//    output wire ext_mdio_t,

    );

    //////////////// Clock definitions
    // 250 
    wire sys_clk; // 250 MHz
    wire sys_rst;
    // 125
    wire clk_125; // 125 MHz
    wire rst_125; // 125 MHz

    //////////////// GMII wires
    // gmii
    wire [7:0] gmii_txd;
    wire gmii_tx_en;
    wire gmii_tx_er;
    wire [7:0] gmii_rxd;
    wire gmii_rx_dv;
    wire gmii_rx_er;

    wire dcm_locked;

    // Clocking wizard
    clk_wiz_0 clk_wiz_inst (
        .clk_in1_p(clk_in1_p),
        .clk_in1_n(clk_in1_n),	
        .reset(ext_reset_in),
        .locked(dcm_locked),
        .clk_out1(sys_clk)
    );

    // reset generator
    proc_sys_reset_0 sys_rst_inst (
        .slowest_sync_clk(sys_clk),
        .ext_reset_in(ext_reset_in),
        .mb_debug_sys_rst(1'b0),
        .dcm_locked(dcm_locked),
        .mb_reset(),
        .bus_struct_reset(),
        .peripheral_reset(sys_rst),
        .interconnect_aresetn(),
        .peripheral_aresetn()
    );

    wire an_interrupt;
    wire [15:0] an_adv_config_vector;
    wire an_adv_config_val;
    wire an_restart_config;
    wire [15:0] pcspma_an_config_vector;
    wire mmcm_locked_out;

    assign an_adv_config_vector[15]    = 1'b1;    // SGMII link status
    assign an_adv_config_vector[14]    = 1'b1;    // SGMII Acknowledge
    assign an_adv_config_vector[13:12] = 2'b01;   // full duplex
    assign an_adv_config_vector[11:10] = 2'b10;   // SGMII speed
    assign an_adv_config_vector[9]     = 1'b0;    // reserved
    assign an_adv_config_vector[8:7]   = 2'b00;   // pause frames - SGMII reserved
    assign an_adv_config_vector[6]     = 1'b0;    // reserved
    assign an_adv_config_vector[5]     = 1'b0;    // full duplex - SGMII reserved
    assign an_adv_config_vector[4:1]   = 4'b0000; // reserved
    assign an_adv_config_vector[0]     = 1'b1;    // SGMII

    wire [15:0] status_vector;
    wire [1:0] pcspma_status_speed = status_vector[11:10];

    gig_ethernet_pcs_pma gepp_inst (
        .txn(phy_txn),                     // output wire txn
        .txp(phy_txp),                     // output wire txp
        .rxn(phy_rxn),                     // input wire rxn
        .rxp(phy_rxp),                     // input wire rxp

        .mmcm_locked_out(mmcm_locked_out), // output wire mmcm_locked_out
        .sgmii_clk_r(),                    // output wire sgmii_clk_r
        .sgmii_clk_f(),                    // output wire sgmii_clk_f
        .sgmii_clk_en(),                   // output wire sgmii_clk_en
        .clk125_out(clk_125),              // output wire clk125_out
        .clk625_out(),                     // output wire clk625_out
        .clk312_out(),                     // output wire clk312_out
        .rst_125_out(rst_125),             // output wire rst_125_out
        .refclk625_n(phy_clk_n),           // input wire refclk625_n
        .refclk625_p(phy_clk_p),           // input wire refclk625_p
        .gmii_txd(gmii_txd),               // input wire [7 : 0] gmii_txd
        .gmii_tx_en(gmii_tx_en),           // input wire gmii_tx_en
        .gmii_tx_er(gmii_tx_er),           // input wire gmii_tx_er
        .gmii_rxd(gmii_rxd),               // output wire [7 : 0] gmii_rxd
        .gmii_rx_dv(gmii_rx_dv),           // output wire gmii_rx_dv
        .gmii_rx_er(gmii_rx_er),           // output wire gmii_rx_er
        .gmii_isolate(),                   // output wire gmii_isolate
        .configuration_vector(5'b10000),   // auto-negotiation enable
        .an_interrupt(an_interrupt),       // output wire an_interrupt
        .an_adv_config_vector(an_adv_config_vector),  // input wire [15 : 0] an_adv_config_vector
        .an_restart_config(1'b0),          // input wire an_restart_config
        .speed_is_10_100(speed_is_10_100), // input wire speed_is_10_100
        .speed_is_100(speed_is_100),       // input wire speed_is_100
        .status_vector(status_vector),     // output wire [15 : 0] status_vector
        .reset(sys_rst),                   // input wire reset
        .signal_detect(1'b1),              // input wire signal_detect
        .idelay_rdy_out()                  // output wire idelay_rdy_out
    );

    wire eeprom_cs;
    wire eeprom_sk;
    wire eeprom_di;
    wire eeprom_do;

    wire tcp_open_ack;
    wire tcp_error;
    wire tcp_close_req;
    wire tcp_close_ack;

    wire tcp_tx_full;
    wire tcp_tx_wr;
    wire [7:0] tcp_txd;

    assign tcp_close_ack = tcp_close_req;

    wire rbcp_act;
    wire [31:0] rbcp_addr;
    wire [7:0] rbcp_wd;
    wire rbcp_we;
    wire rbcp_re;
    wire rbcp_ack;
    wire [7:0] rbcp_rd;

    WRAP_SiTCP_GMII_XCKU_32K sitcp_inst(
        .CLK(sys_clk),
        .RST(sys_rst),
        // Configuration parameters
        .FORCE_DEFAULTn(), //: Load default parameters
        .EXT_IP_ADDR(32'd0),    // in: IP address[31:0]
        .EXT_TCP_PORT(16'd0),   // in: TCP port #[15:0]
        .EXT_RBCP_PORT(16'd0),  // in: RBCP port #[15:0]
        .PHY_ADDR(5'b00111),    // in: PHY-device MIF address[4:0]
        // EEPROM
        .EEPROM_CS(eeprom_cs),  // out: Chip select
        .EEPROM_SK(eeprom_sk),  // out: Serial data clock
        .EEPROM_DI(eeprom_di),  // out: Serial write data
        .EEPROM_DO(eeprom_do),  // in : Serial read data
        // user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        .USR_REG_X3C(),         // out: Stored at 0xFFFF_FF3C
        .USR_REG_X3D(),         // out: Stored at 0xFFFF_FF3D
        .USR_REG_X3E(),         // out: Stored at 0xFFFF_FF3E
        .USR_REG_X3F(),         // out: Stored at 0xFFFF_FF3F
        // MII interface
        .GMII_RSTn(phy_rst_n),  // out: PHY reset
        .GMII_1000M(1'b1),      // in : GMII mode (0:MII, 1:GMII)
        // TX
        .GMII_TX_CLK(clk_125),  // in : Tx clock
        .GMII_TX_EN(gmii_tx_en),// out: Tx enable
        .GMII_TXD(gmii_txd),    // out: Tx data[7:0]
        .GMII_TX_ER(gmii_tx_er),// out: TX error
        // RX
        .GMII_RX_CLK(clk_125),  // in : Rx clock
        .GMII_RX_DV(gmii_rx_dv),// in : Rx data valid
        .GMII_RXD(gmii_rxd),    // in : Rx data[7:0]
        .GMII_RX_ER(gmii_rx_er),// in : Rx error
        .GMII_CRS(1'b0),        // in : Carrier sense
        .GMII_COL(1'b0),        // in : Collision detected
        // Management IF
        .GMII_MDC(),            // out: Clock for MDIO
        .GMII_MDIO_IN(1'b1),    // in : Data
        .GMII_MDIO_OUT(),       // out: Data
        .GMII_MDIO_OE(),        // out: MDIO output enable
        // User I/F
        .SiTCP_RST(),           // out: Reset for SiTCP and related circuits
        // TCP connection control
        .TCP_OPEN_REQ(1'b0),          // in : Reserved input, shoud be 0
        .TCP_OPEN_ACK(tcp_open_ack),  // out: Acknowledge for open (=Socket busy)
        .TCP_ERROR(tcp_error),        // out	: TCP error, its active period is equal to MSL
        .TCP_CLOSE_REQ(tcp_close_req),// out	: Connection close request
        .TCP_CLOSE_ACK(tcp_close_ack),// in	: Acknowledge for closing
        // FIFO I/F
        .TCP_RX_WC(),             // in : Rx FIFO write count[15:0] (Unused bits should be set 1)
        .TCP_RX_WR(),             // out: Write enable
        .TCP_RX_DATA(),           // out: Write data[7:0]
        .TCP_TX_FULL(tcp_tx_full),// out: Almost full flag
        .TCP_TX_WR(tcp_tx_wr),    // in : Write enable
        .TCP_TX_DATA(tcp_txd),    // in : Write data[7:0]
        // RBCP
        .RBCP_ACT(rbcp_act),      // out: RBCP active
        .RBCP_ADDR(rbcp_addr),    // out: Address[31:0]
        .RBCP_WD(rbcp_wd),        // out: Data[7:0]
        .RBCP_WE(rbcp_we),        // out: Write enable
        .RBCP_RE(rbcp_re),        // out: Read enable
        .RBCP_ACK(rbcp_ack),      // in : Access acknowledge
        .RBCP_RD(rbcp_rd)         // in : Read data[7:0]
    );

endmodule
