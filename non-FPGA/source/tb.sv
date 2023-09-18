//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for designed pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
`include "top.v"

module testbench;
reg clk_x70;
wire finished_x70;

int clk_count = 0;

// processor module
Processor proc(.*);

initial 
begin
  clk_x70 =0;
  #1000000;
  $display("--------- ERROR - Simulation timeout  ------\n\n");
  $finish;
end

always
begin
  #5 clk_x70 = ~clk_x70;
  if(clk_x70 == 1) begin
    clk_count++;
    $display("\n\n @%0t (%0dth clock)---------------------------------------", $time, clk_count);
  end
end

always @(posedge finished_x70)
begin
  $display("\n\n Finished!!! ALL Instructions have been executed [total clocks: %0d]\n\n", clk_count);
  $finish;
end

endmodule

