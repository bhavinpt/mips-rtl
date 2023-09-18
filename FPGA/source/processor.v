//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Top Level module of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


//`include "fetch.v"
//`include "decode.v"
//`include "execute.v"
//`include "memory.v"

module Processor(input wire clk,
                 input wire reset,
                 output wire done,
                 output wire [31:0] mem_word_0);
    
    // FETCH
    wire [3:0] instr_type_IF;
    wire has_rs;
    wire has_rt;
    wire [4:0] rs;
    wire [4:0] rt;
    wire has_rd;
    wire [4:0] rd;
    wire has_imm;
    wire [31:0] imm;
    wire done_IF;
    
    // DECODE
    wire [3:0] instr_type_ID;
    wire wb_en;
    wire [4:0] wb_addr;
    wire [31:0] wb_data;
    wire [31:0] source_1_read;
    wire [31:0] source_2_read;
    wire [4:0] wb_tgt_ID;
    wire [4:0] sourceA;
    wire [4:0] sourceB;
    wire [31:0]A;
    wire [31:0]B;
    wire [15:0] sw_offset;
    wire done_ID;
    
    // EXECUTE
    wire [3:0] instr_type_EX;
    wire [4:0] wb_tgt_EX;
    wire [31:0] result;
    wire [15:0] sw_addr;
    wire done_EX;
    
    // MEM
    wire done_MEM;
    
    
    
    // stage - 1 : Instruct Fetch
    Instruction_Fetch IF(
    // inputs
    .clk(clk),
    .reset(reset),
    
    //outputs
    .instr_type_IF(instr_type_IF),
    .has_imm(has_imm),
    .has_rs(has_rs),
    .has_rt(has_rt),
    .has_rd(has_rd),
    .imm(imm),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .done(done_IF)
    );
    
    Instruction_Decode ID(
    // stage - 2 : inst Decode
    //inputs
    .clk(clk),
    .reset(reset),
    .done_in_ID(done_IF),
    .done_in_WB(done_MEM),
    .wb_en(wb_en),
    .wb_addr(wb_addr),
    .wb_data(wb_data),
    
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .imm(imm),
    
    .has_rs(has_rs),
    .has_rt(has_rt),
    .has_rd(has_rd),
    .has_imm(has_imm),
    .instr_type_IF(instr_type_IF),
    
    //outputs
    .A(A),
    .B(B),
    .sourceA(sourceA),
    .sourceB(sourceB),
    .wb_tgt_ID(wb_tgt_ID),
    .instr_type_ID(instr_type_ID),
    .sw_offset(sw_offset),
    .done_ID(done_ID),
    .done_WB(done)
    );
    
    
    // stage - 3 : Execute
    Execute EX(
    //inputs
    .clk(clk),
    .reset(reset),
    .done_in(done_ID),
    .instr_type_ID(instr_type_ID),
    .wb_tgt_ID(wb_tgt_ID),
    .A(A),
    .B(B),
    .sourceA(sourceA),
    .sourceB(sourceB),
    .sw_offset(sw_offset),
    
    // outputs
    .instr_type_EX(instr_type_EX),
    .wb_tgt_EX(wb_tgt_EX),
    .result(result),
    .sw_addr(sw_addr),
    .done_out(done_EX)
    );
    
    // stage - 4 : Memory
    Memory MEM(
    // inputs
    .clk(clk),
    .reset(reset),
    .done_in(done_EX),
    .instr_type_EX(instr_type_EX),
    .wb_tgt_EX(wb_tgt_EX),
    .result(result),
    .sw_addr(sw_addr),
    
    // outputs
    .wb_en(wb_en),
    .wb_addr(wb_addr),
    .wb_data(wb_data),
    .mem_word_0(mem_word_0),
    .done_out(done_MEM)
    );
    
    initial
    begin
        $dumpfile("waves.vcd");
        $dumpvars(0);
    end
    
    
    
endmodule
