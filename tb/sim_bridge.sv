`timescale 1ns / 1ps

module sim_bridge();
    
    localparam STEP_SYS = 40;
    localparam SIM_LENGTH = 128;

    // input
    logic [31:0]GPIO2_0_tri_o;
    logic [31:0]GPIO_0_tri_i;
    
    logic clk_0;
    logic [1:0]debug_bresp_0;
    logic [1:0]debug_rresp_0;
    logic rbcp_ack_0;
    logic rbcp_act_0;
    logic [31:0]rbcp_addr_0;
    logic [7:0]rbcp_rd_0;
    logic rbcp_re_0;
    logic [7:0]rbcp_wd_0;
    logic rbcp_we_0;
    logic reset;

    design_1_wrapper dut (
        .*
    );



    task clk_gen();
        clk_0 = 0;
        forever #(STEP_SYS/2) clk_0 = ~clk_0;
    endtask
    
    task rst_gen();
        rbcp_act_0 = 0;
        rbcp_addr_0 = 0;
        rbcp_wd_0 = 0;
        rbcp_re_0 = 0;
        rbcp_we_0 = 0;
        reset = 0;
        GPIO_0_tri_i = 0;
        @(posedge clk_0);
        reset = 1;
        repeat(10) @(posedge clk_0);
        reset = 0;
    endtask
    
        
    initial begin
        fork
            clk_gen();
            rst_gen();
        join_none
        repeat(120) @(posedge clk_0)
        @(posedge clk_0);
        rbcp_act_0 <= 1'b1;
        GPIO_0_tri_i = 32'hFFFFFF00;
        repeat(20)@(posedge clk_0);
        rbcp_addr_0 <= 32'd3;
        rbcp_re_0 <= 1;
        @(posedge clk_0);
        rbcp_re_0 <= 0;
        repeat(100) @(posedge clk_0);
        rbcp_addr_0 <= 32'd8;
        rbcp_we_0 <= 1;
        rbcp_wd_0 <= 8'b1111_1111;
        @(posedge clk_0);
        rbcp_we_0 <= 0;

        repeat(100) @(posedge clk_0);
        $finish;
    end
        
endmodule
