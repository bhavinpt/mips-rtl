//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Fetch stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


`define TOTAL_Instr 14

// instruction_x70 decode
module Instruction_Fetch(
  input wire clk_x70,
  input wire signed [25:0] pc_inc_x70,
  input wire prev_stalled_x70,
  output reg[31:0] instruction_x70,
  output reg[2:0] inst_type_x70,
  output reg has_imm_x70,
  output reg has_source_1_x70,
  output reg has_source_2_x70,
  output reg has_target_x70,
  output reg has_j_x70,
  output reg signed [31:0] imm_x70,
  output reg [4:0] source_1_x70,
  output reg [4:0] source_2_x70,
  output reg [4:0] target_x70,
  output reg signed [25:0] Joffset_x70,
  output reg predicted_x70,
  output reg finished_x70
);
// only the first 2^8 are supported instead of 2^32 due to hadware limitation
reg [31:0] memory [256];
reg [7:0] supported_addr;
reg signed [31:0] pc;
reg signed [31:0] pc_rollback;
reg signed [31:0] next_branch_pc;
reg signed [31:0] next_jump_pc;

reg [1:0] predictor_2b;
reg prev_inst_branch;
reg prev_inst_jump;
reg [10*8:0] inst_name;

reg [4:0] prev_load_target_reg;
reg prev_inst_load; 
reg [3:0] pipe_clean;

initial
begin
  $readmemb("./test.prog", memory,0,13);
  pc = 0;
  finished_x70 = 0;
  predictor_2b = 0;
  prev_inst_branch = 0;
  prev_inst_jump = 0;
  prev_inst_load = 0;
  pipe_clean = 4;
end


always @(posedge clk_x70)
begin

  // done executing all instructions
  if(pc > (`TOTAL_Instr - 1) * 4)
  begin
    if(pipe_clean > 0) begin
      pipe_clean -= 1;
    end
    else begin
      finished_x70 = 1; 
      instruction_x70 = 0;
      inst_type_x70 = 0;
      has_imm_x70 = 0;
      has_source_1_x70 = 0;
      has_source_2_x70 = 0;
      has_target_x70 = 0;
      has_j_x70 = 0;
      imm_x70 = 0;
      source_1_x70 = 0;
      source_2_x70 = 0;
      target_x70 = 0;
      Joffset_x70 = 0;
    end
  end

  else
  begin
    // add jump offset
    if(pc_inc_x70 != 0)
      pc = pc + pc_inc_x70;


    ///////////// stall ////////////
    if(prev_stalled_x70) begin // handle stalls when branch predictor fails
      pc = pc_rollback;

      $write("STALL Detected : prev_2b_predictor: %2b, ", predictor_2b);

      // update 2-bit predictor
      if (predictor_2b > 2'b01)
	predictor_2b -= 1;
      else
	predictor_2b += 1;

      $display("new_2b_predictor : %2b", predictor_2b);

    end


    ///////////// Jump /////////////
    if(prev_inst_jump) begin // or jump
      pc = next_jump_pc;
      prev_inst_jump = 0;
    end

    // read instruction_x70
    supported_addr = pc[9:2];
    instruction_x70 =  memory[supported_addr];
    imm_x70 =  $signed(instruction_x70[15:0]); // will it work with signed ? 
    Joffset_x70 = instruction_x70[26:0]; 

    // run jump 
    if(instruction_x70[31:26] == 6'b000010) begin // J
	next_jump_pc = pc + (imm_x70 << 2) + 4; // make the jump 
	prev_inst_jump = 1;
    end

    ///////////// Branch /////////////
    if(prev_inst_branch) begin 
      pc = next_branch_pc;
      prev_inst_branch = 0;
    end

    // read instruction_x70
    supported_addr = pc[9:2];
    instruction_x70 =  memory[supported_addr];
    imm_x70 =  $signed(instruction_x70[15:0]); // will it work with signed ? 
    Joffset_x70 = instruction_x70[26:0]; 

    // run branch predictor
    if(instruction_x70[31:26] == 6'b000100) begin // BEQ
      predicted_x70 = (predictor_2b > 2'b01) ? 1 : 0;
      if(predicted_x70) begin // taken
	pc_rollback = pc + 4; // continue from next inst. after wrong prediction
	next_branch_pc = pc + (imm_x70 << 2) + 4; // make the jump 
      end
      else begin // not-taken
	pc_rollback = pc + (imm_x70 << 2) + 4; // continue from jumped inst. after wrong prediction
	next_branch_pc = pc + 4; // read again
      end
      prev_inst_branch = 1;
      $display("PREDICTED_x70: taken=%d", predicted_x70);
    end 


    ///////////// Final /////////////
    // read again
    supported_addr = pc[9:2];
    instruction_x70 =  memory[supported_addr]; 
    imm_x70 =  $signed(instruction_x70[15:0]); // will it work with signed ? 
    Joffset_x70 = instruction_x70[26:0];

    // decode instruction_x70
    casex({instruction_x70[31:26] , instruction_x70 [5:0]}) 
      'b000000_100001 : // ADDU
      begin
	has_imm_x70 = 0;
	has_source_1_x70 = 1;
	has_source_2_x70 = 1;
	has_target_x70 = 1;
	has_j_x70 = 0;
	inst_type_x70 = 1;
	source_1_x70 = instruction_x70[25:21];
	source_2_x70 = instruction_x70[20:16];
	target_x70 = instruction_x70[15:11];
	inst_name = "ADDU";
      end
      'b001001_xxxxxx : // ADDIU
      begin
	has_imm_x70 = 1;
	has_source_1_x70 = 1;
	has_source_2_x70 = 0;
	has_target_x70 = 1;
	has_j_x70 = 0;
	inst_type_x70 = 2;
	source_1_x70 = instruction_x70[25:21];
	target_x70 = instruction_x70[20:16];
	inst_name = "ADDIU";
      end
      'b000000_011000 : // MUL
      begin
	has_imm_x70 = 0;
	has_source_1_x70 = 1;
	has_source_2_x70 = 1;
	has_target_x70 = 1;
	has_j_x70 = 0;
	inst_type_x70 = 3;
	source_1_x70 = instruction_x70[25:21];
	source_2_x70 = instruction_x70[20:16];
	target_x70 = instruction_x70[15:11];
	inst_name = "MUL";
      end
      'b100011_xxxxxx : // LW
      begin
	has_imm_x70 = 1;
	has_source_1_x70 = 1;
	has_source_2_x70 = 0;
	has_target_x70 = 1;
	has_j_x70 = 0;
	inst_type_x70 = 4;
	source_1_x70 = instruction_x70[25:21];
	target_x70 = instruction_x70[20:16];
	inst_name="LW";
      end   
      'b000100_xxxxxx : // BEQ
      begin
	has_imm_x70 = 1;
	has_source_1_x70 = 1;
	has_source_2_x70 = 1;
	has_target_x70 = 0;
	has_j_x70 = 0;
	inst_type_x70 = 5;
	source_1_x70 = instruction_x70[25:21];
	source_2_x70 = instruction_x70[20:16];
	target_x70 = 0;
	inst_name="BEQ";
      end
      'b000010_xxxxxx : // J
      begin
	has_imm_x70 = 0;
	has_source_1_x70 = 0;
	has_source_2_x70 = 0;
	has_target_x70 = 0;
	has_j_x70 = 1;
	inst_type_x70 = 7;
	inst_name="J";
      end
      'b000000_001000 : // JR
      begin
	has_imm_x70 = 0;
	has_source_1_x70 = 1;
	has_source_2_x70 = 0;
	has_target_x70 = 0;
	has_j_x70 = 0;
	inst_type_x70 = 6;
	source_1_x70 = instruction_x70[25:21];
	target_x70 = 0;
	inst_name="JR";
      end
      default:
      begin
	has_imm_x70 = 0;
	has_source_1_x70 = 0;
	has_source_2_x70 = 0;
	has_target_x70 = 0;
	has_j_x70 = 0;
	inst_type_x70 = 0;
	source_1_x70 = 0;
	source_2_x70 = 0;
	target_x70 = 0;
	inst_name="INVALID";
      end

    endcase

    ///////////// Load Delay /////////////
    if(prev_inst_load) begin
      if((has_source_1_x70 && (source_1_x70 == prev_load_target_reg)) || (has_source_2_x70 && (source_2_x70 == prev_load_target_reg))) begin // LW dependency found
	$display("Inserting Load Delay");
	instruction_x70 = 0;
	has_imm_x70 = 0;
	has_source_1_x70 = 0;
	has_source_2_x70 = 0;
	has_target_x70 = 0;
	has_j_x70 = 0;
	inst_type_x70 = 0;
	source_1_x70 = 0;
	source_2_x70 = 0;
	target_x70 = 0;
	inst_name="NOP";
	pc = pc-4;
      end
    end

    prev_inst_load = 0;
    prev_load_target_reg = 0;
    if(instruction_x70[31:26] == 6'b100011) begin // LW
      prev_inst_load = 1;
      prev_load_target_reg = target_x70;
    end

    $write("INST_FETCH : PC=%0d (%0dth inst) | ", pc, ((pc/4) + 1));
    $write("  %0s ", inst_name);
    if(has_source_1_x70) $write("source_1_x70 = R%0d, ", source_1_x70);
    if(has_source_2_x70) $write("source_2_x70 = R%0d, ", source_2_x70);
    if(has_target_x70) $write("target_x70 = R%0d, ", target_x70);
    if(has_imm_x70) $write("imm_x70 = %0d, ", imm_x70);
    if(has_j_x70) $write("Joffset_x70 = %0d ", Joffset_x70);
    $write(" | (%b)", instruction_x70);
    $display("");

    // update PC for next instruction_x70
    pc = pc + 4;
  end
end

endmodule

