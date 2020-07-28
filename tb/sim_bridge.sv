`timescale 1ns / 1ps

module sim_bridge();
    
    localparam STEP_SYS = 40;
    localparam SIM_LENGTH = 128;

    // input
    
    
    logic [31:0]GPIO_0_tri_o;
    logic [31:0]GPIO_1_tri_i;
    logic clk;
    logic rbcp_ack;
    logic rbcp_act;
    logic [31:0]rbcp_addr;
    logic [7:0]rbcp_rd;
    logic rbcp_re;
    logic [7:0]rbcp_wd;
    logic rbcp_we;
    logic rst;
    logic aux_reset_in;
    
    adapter_test_wrapper dut (
        .*
    );



    task clk_gen();
        clk = 0;
        forever #(STEP_SYS/2) clk = ~clk;
    endtask
    
    task rst_gen();
        rbcp_act = 0;
        rbcp_addr = 0;
        rbcp_wd = 0;
        rbcp_re = 0;
        rbcp_we = 0;
        rst = 1;
        aux_reset_in = 1;
        GPIO_1_tri_i = 0;
        @(posedge clk);
        rst = 0;
        repeat(10) @(posedge clk);
        rst = 1;
    endtask
    
    task rbcp_read(input integer addr);
        rbcp_addr <= addr;
        rbcp_re <= 1;
        @(posedge clk);
        rbcp_re <= 0;
        wait(rbcp_ack);
        @(posedge clk);
    endtask
    
    task rbcp_write(input integer addr, input [7:0] val);
        rbcp_addr <= addr;
        rbcp_we <= 1;
        rbcp_wd <= val;
        @(posedge clk);
        rbcp_we <= 0;
        wait(rbcp_ack);
        @(posedge clk);
    endtask
        
    initial begin
        fork
            clk_gen();
            rst_gen();
        join_none
        repeat(50) @(posedge clk)
        @(posedge clk);
        rbcp_act <= 1'b1;

        // read test
        GPIO_1_tri_i = 32'h11223344;
        repeat(20)@(posedge clk);
        
        rbcp_read(32'd8);
        rbcp_read(32'd9);
        rbcp_read(32'd10);
        rbcp_read(32'd11);
        
        GPIO_1_tri_i = 32'h55_66_77_88;
        repeat(20)@(posedge clk);
        
        rbcp_read(32'd8);
        rbcp_read(32'd9);
        rbcp_read(32'd10);
        rbcp_read(32'd11);
        
        // write test
        rbcp_write(32'd0, 8'h11);
        rbcp_write(32'd1, 8'h22);
        rbcp_write(32'd2, 8'h33);
        rbcp_write(32'd3, 8'h44);
        

        // noise
        rbcp_write(32'd4, 8'hAA);

        // twice
        rbcp_write(32'd0, 8'h55);
        rbcp_write(32'd1, 8'h66);
        rbcp_write(32'd2, 8'h77);
        rbcp_write(32'd3, 8'h88);
                
        repeat(100) @(posedge clk);

        $finish;
    end
endmodule
