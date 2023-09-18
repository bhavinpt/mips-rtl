//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Top Level module of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"

module Processor(input wire clk_x70, output reg finished_x70);
wire [31:0] instruction_x70;

wire [2:0] inst_type_x70;
wire [2:0] inst_type_fwd_x70;
wire [2:0] inst_type_fwd2_x70;
wire has_imm_x70;
wire has_source_1_x70;
wire has_source_2_x70;
wire has_target_x70;
wire has_j_x70;
wire [31:0] imm_x70;
wire [31:0] imm_fwd_x70;
wire [4:0] source_1_x70;
wire [4:0] source_2_x70;
wire [4:0] target_x70;
wire [4:0] target_fwd_x70;
wire [4:0] target_fwd2_x70;
wire [25:0] Joffset_x70;
wire [25:0] Joffset_fwd_x70;

reg  reg_write_en_x70;
reg [4:0] reg_write_dest_x70;
reg [31:0] reg_write_data_x70;
reg [31:0] source_1_read_x70;
reg [31:0] source_2_read_x70;
reg [31:0] target_read_x70;
reg [4:0] sourceA_x70;
reg [4:0] sourceB_x70;

reg [31:0]A_x70;
reg [31:0]B_x70;
reg [31:0] result_x70;
reg predicted_x70;
reg stall_x70;

reg [31:0] wb_fwd_tapout_value_x70;
reg [4:0] wb_fwd_tapout_target_x70;
reg [31:0] mw_fwd_tapout_value_x70;
reg [4:0] mw_fwd_tapout_target_x70;
wire signed [25:0] pc_inc;

// stage - 1 : Instructin Fetch
Instruction_Fetch IF(
  // inputs
  .clk_x70(clk_x70), //clk1
  .pc_inc_x70(pc_inc),
  .prev_stalled_x70(stall_x70),

  //outputs
  .instruction_x70(instruction_x70),
  .inst_type_x70(inst_type_x70),
  .has_imm_x70(has_imm_x70),
  .has_source_1_x70(has_source_1_x70),
  .has_source_2_x70(has_source_2_x70),
  .has_target_x70(has_target_x70),
  .has_j_x70(has_j_x70),
  .imm_x70(imm_x70),
  .source_1_x70(source_1_x70),
  .source_2_x70(source_2_x70),
  .target_x70(target_x70),
  .Joffset_x70(Joffset_x70),
  .predicted_x70(predicted_x70),
  .finished_x70(finished_x70)
);

Instruction_Decode ID(
  // stage - 2 : instruction_x70 Decode
  //inputs
  .read_clk_x70(clk_x70), //clk2
  .reg_read_addr_1_x70(source_1_x70),
  .reg_read_addr_2_x70(source_2_x70),
  .inst_type_x70(inst_type_x70),
  .has_imm_x70(has_imm_x70),
  .imm_x70(imm_x70),
  
  //forward
  .inst_type_fwd_x70(inst_type_fwd_x70),
  .imm_fwd_x70(imm_fwd_x70),
  .Joffset_x70(Joffset_x70),
  .Joffset_fwd_x70(Joffset_fwd_x70),
  .target_x70(target_x70),
  .target_fwd_x70(target_fwd_x70),

  //outputs
  .reg_read_data_1_x70(source_1_read_x70), // unused
  .reg_read_data_2_x70(source_2_read_x70), // unused
  .A_x70(A_x70),
  .B_x70(B_x70),
  .sourceA_x70(sourceA_x70),
  .sourceB_x70(sourceB_x70),

  // stage - 5 : mem writeback 
  //inputs
  .writeback_clk_x70(clk_x70), //clk5
  .reg_write_en_x70(reg_write_en_x70),
  .reg_write_dest_x70(reg_write_dest_x70),
  .reg_write_data_x70(reg_write_data_x70),
  //outputs
  .wb_fwd_tapout_target_x70(wb_fwd_tapout_target_x70), 
  .wb_fwd_tapout_value_x70(wb_fwd_tapout_value_x70)
);

// stage - 3 : Execute
Execute EX(
  //inputs
  .clk_x70(clk_x70), //clk3
  .A_x70(A_x70),
  .B_x70(B_x70),
  .sourceA_x70(sourceA_x70),
  .sourceB_x70(sourceB_x70),
  .inst_type_x70(inst_type_fwd_x70),
  .imm_x70(imm_fwd_x70),
  .Joffset_x70(Joffset_fwd_x70),
  .predicted_x70(predicted_x70),
  .mw_fwd_tapout_target_x70(mw_fwd_tapout_target_x70), 
  .mw_fwd_tapout_value_x70(mw_fwd_tapout_value_x70),
  .wb_fwd_tapout_target_x70(wb_fwd_tapout_target_x70), 
  .wb_fwd_tapout_value_x70(wb_fwd_tapout_value_x70),

  //forward
  .inst_type_fwd_x70(inst_type_fwd2_x70),
  .target_x70(target_fwd_x70),
  .target_fwd_x70(target_fwd2_x70),

  //outputs
  .pc_inc_x70(pc_inc),
  .result_x70(result_x70),
  .stall_x70(stall_x70)
);


// stage - 4 : Memory
Memory MEM(
  // inputs
  .mem_clk_x70(clk_x70), //clk4
  .inst_type_x70(inst_type_fwd2_x70), 
  .target_x70(target_fwd2_x70),
  .result_x70(result_x70),

  // outputs
  .reg_write_en_x70(reg_write_en_x70),
  .reg_write_dest_x70(reg_write_dest_x70),
  .reg_write_data_x70(reg_write_data_x70),
  .mw_fwd_tapout_target_x70(mw_fwd_tapout_target_x70), 
  .mw_fwd_tapout_value_x70(mw_fwd_tapout_value_x70)
);




initial 
begin
  $dumpfile("waves.vcd"); $dumpvars;
end



endmodule
