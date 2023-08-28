`timescale 1ns / 1ps


module Pipelined_tb();
    reg clk, rst, clk_ssd;
    reg [1:0] led_sel;
    reg [3:0] ssd_sel;
    wire [15:0] leds;
    wire [3:0] anode;
    wire [6:0] LED_out;
    localparam clk_period = 10;
    
    initial begin 
        clk = 1'b0;
        forever #(clk_period/2) clk = ~clk;
    end

    Pipelined UUT(.clk(clk), .rst(rst), .clk_ssd(clk_ssd), 
                    .led_sel(led_sel), .ssd_sel(ssd_sel), .leds(leds), .anode(anode), .led_out(led_out));
    
    initial begin
        rst = 1;
        #clk_period;
        rst = 0;
    end
endmodule
