//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for designed pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


//`timescale 1ns / 1ps
// `include "top.v"

module testbench;
  reg clk;
  reg resetn;

  wire done;
  wire [6:0] seg;
  wire [3:0] an;
  wire dp;
  
  int clk_count;

  top dut(
    .clk(clk),
    .resetn(resetn),
    .done(done),
    .seg(seg),
    .an(an),
    .dp(dp)
  );




  initial 
  begin
    clk =0;
    resetn = 1;

    #20 resetn = 0;
    #20 resetn = 1;
    
    
    $display("----------- Sim Started ------------");
    //#1000000;
    //$display("--------- ERROR - Simulation timeout  ------\n\n");
    //$finish;
  end

  always
  begin
    #5 clk = ~clk;
    //if(clk) begin
    //  clk_count++;
    //  $display("\n\n @%0t (%0dth clock)---------------------------------------", $time, clk_count);
    //end
  end

  always @(posedge done)
  begin
    $display("\n\n Finished!!! ALL Instructions have been executed [total clocks: %0d]\n\n", clk_count);

    repeat(10) @(posedge clk);
    $finish;
  end

endmodule

