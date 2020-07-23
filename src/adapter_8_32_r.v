`timescale 1ns / 1ps

module adapter_8_32_r(
    input wire clk,
    input wire rst,

    // S AXI
    input  wire [31:0] s_axi_araddr, // read address
    input  wire [2:0]  s_axi_arprot, // read channel protection type
    input  wire        s_axi_arvalid,// read address valid
    output wire        s_axi_arready,// read address ready
    output wire [31:0] s_axi_rdata,  // read data
    output wire        s_axi_rvalid, // read valid
    input  wire        s_axi_rready, // read ready
    output wire [1:0]  s_axi_rresp,  // read response

    // M AXI
    output wire [31:0] m_axi_araddr, // read address
    output wire [2:0]  m_axi_arprot, // read channel protection type
    output wire        m_axi_arvalid,// read address valid
    input  wire        m_axi_arready,// read address ready
    input  wire [31:0] m_axi_rdata,  // read data
    input  wire        m_axi_rvalid, // read valid
    output wire        m_axi_rready, // read ready
    input  wire [1:0]  m_axi_rresp   // read response
);

    /*********************
        SLAVE INTERFACE
    *********************/
    wire m_busy;
    reg s_arready_buf;
    reg s_araddr_buf;

    wire ar_acc = ~s_arready_buf && s_axi_arvalid && ~m_busy;

    always @(posedge clk) begin
        if (rst) begin
            s_arready_buf <= 1'b0;
            s_araddr_buf <= 32'b0;
        end else begin
            if (ar_acc) begin
                s_arready_buf <= 1'b1;
                s_araddr_buf <= s_axi_araddr;
            end else begin
                s_arready_buf <= 1'b0;
            end
        end
    end

    wire addr_change = ar_acc && (s_araddr_buf != s_axi_araddr);

    reg s_rvalid_buf;
    reg [1:0] s_rresp_buf;

    wire r_acc = s_arready_buf && s_axi_arvalid && ~s_rvalid_buf;

    always @(posedge clk) begin
        if (rst) begin
            s_rvalid_buf <= 1'b0;
            s_rresp_buf <= 2'b0;
        end else begin
            if (r_acc) begin
                s_rvalid_buf <= 1'b1;
                s_rresp_buf <= 2'b0;
            end else if (s_rvalid_buf && s_axi_rready) begin
                s_rvalid_buf <= 1'b0;
            end
        end
    end
    assign s_axi_rvalid = s_rvalid_buf;

    /*********************
        MASTER INTERFACE
    *********************/

    // arvalid
    reg m_arvalid_buf;
    always @(posedge clk) begin
        if (rst) begin
            m_arvalid_buf <= 1'b0;
        end else begin
            if (addr_change) begin
                m_arvalid_buf <= 1'b1;
            end else if (m_arvalid_buf && m_axi_arready) begin
                m_arvalid_buf <= 1'b0;
            end
        end
    end
    assign m_axi_arvalid = m_arvalid_buf;

    /////////////////////////////////// Read data handling
    reg [31:0] m_rdata_buf;
    always @(posedge clk) begin
        if (rst) begin
            m_rdata_buf <= 32'b0;
        end else begin
            if (m_axi_rvalid) begin
                m_rdata_buf <= m_axi_rdata;
            end
        end
    end
    assign s_axi_rdata = m_rdata_buf;

    /////////////////////////////////// Read response handling
    reg m_rready_buf;
    always @(posedge clk) begin
        if (rst) begin
            m_rready_buf <= 1'b0;
        end else begin
            if (m_axi_rvalid && ~m_rready_buf) begin
                m_rready_buf <= 1'b1;
            end else if (m_rready_buf) begin
                m_rready_buf <= 1'b0;
            end else begin
                m_rready_buf <= m_rready_buf;
            end
        end
    end
    assign m_axi_rready = m_rready_buf;

    /////////////////////////////////// Protection type
    assign m_axi_arprot = 3'b000;

    /////////////////////////////////// m_busy
    reg m_busy_buf;
    always @(posedge clk) begin
        if (rst) begin
            m_busy_buf <= 1'b0;
        end else begin
            if (addr_change) begin
                m_busy_buf <= 1'b1;
            end else if (m_rready_buf) begin
                m_busy_buf <= 1'b0;
            end
        end
    end
    assign m_busy = m_busy_buf;

endmodule
