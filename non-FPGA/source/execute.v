//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Execute stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


module Execute(
  input clk_x70,
  input signed [31:0] A_x70,  //src1
  input signed [31:0] B_x70,  //src2
  input signed [31:0] imm_x70,  //src2
  input [2:0] inst_type_x70, 
  input signed [25:0] Joffset_x70,
  input [4:0] target_x70,
  input [4:0] sourceA_x70,
  input [4:0] sourceB_x70,
  input wire [31:0] mw_fwd_tapout_value_x70,
  input wire [4:0] mw_fwd_tapout_target_x70,
  input wire [31:0] wb_fwd_tapout_value_x70,
  input wire [4:0] wb_fwd_tapout_target_x70,

  input wire predicted_x70,
  output reg stall_x70,

  output reg signed [31:0] result_x70,  //result_x70 
  output reg signed [25:0] pc_inc_x70,
  output reg [2:0] inst_type_fwd_x70, 
  output reg [4:0] target_fwd_x70
);

reg [2:0] inst_type_in; 

reg signed [31:0] Ain;
reg signed [31:0] Bin;
reg signed [31:0] imm_in;
reg signed [25:0] Joffset_in;
reg b_taken;
reg [4:0] target_in;
reg [4:0] last_target;
reg [31:0] last_result;
reg [4:0] sourceA_in;
reg [4:0] sourceB_in;

always @(posedge clk_x70)
begin 
  inst_type_in <= inst_type_x70;
  Ain <= A_x70;
  Bin <= B_x70;
  imm_in <= imm_x70;
  Joffset_in <= Joffset_x70;
  target_in <= target_x70;
  sourceA_in <= sourceA_x70;
  sourceB_in <= sourceB_x70;

  inst_type_fwd_x70 = inst_type_in;
  target_fwd_x70 = target_in;

  // check for dependency from WB buffer to ALU
  if(mw_fwd_tapout_target_x70) begin
    if( sourceA_in == mw_fwd_tapout_target_x70 ) begin
      Ain = mw_fwd_tapout_value_x70;
      $display("FORWARDING  : WB buffer Forwarded last result_x70:%0d scheduled to be written in R%0d back to ALU input R%0d(A_x70) of this instruction", mw_fwd_tapout_value_x70, mw_fwd_tapout_target_x70, sourceA_in);
    end
    if( sourceB_in == mw_fwd_tapout_target_x70 ) begin
      Bin = mw_fwd_tapout_value_x70;
      $display("FORWARDING  : WB buffwer Forwarded last result_x70:%0d scheduled to be written in R%0d back to ALU input R%0d(B_x70) of this instruction", mw_fwd_tapout_value_x70, mw_fwd_tapout_target_x70, sourceB_in);
    end
  end

   // check for dependency from MEM/WB buffer to ALU
  if(wb_fwd_tapout_target_x70) begin
    if( sourceA_in == wb_fwd_tapout_target_x70 ) begin
      Ain = wb_fwd_tapout_value_x70;
      $display("FORWARDING  : MEM/WB buffer Forwarded last result_x70:%0d scheduled to be written in R%0d back to ALU input R%0d(A_x70) of this instruction", wb_fwd_tapout_value_x70, wb_fwd_tapout_target_x70, sourceA_in);
    end
    if( sourceB_in == wb_fwd_tapout_target_x70 ) begin
      Bin = wb_fwd_tapout_value_x70;
      $display("FORWARDING  : MEM/WB buffer Forwarded last result_x70:%0d scheduled to be written in R%0d back to ALU input R%0d(B_x70) of this instruction", wb_fwd_tapout_value_x70, wb_fwd_tapout_target_x70, sourceB_in);
    end
  end
  
  // check for dependency from ALU/MEM buffer to ALU
  if(last_target) begin
    if( sourceA_in == last_target ) begin
      Ain = last_result;
      $display("FORWARDING  : ALU/MEM buffer Forwarded last result_x70:%0d scheduled to be written in R%0d back to ALU input R%0d(A_x70) of this instruction", last_result, last_target, sourceA_in);
    end
    if( sourceB_in == last_target ) begin
      Bin = last_result;
      $display("FORWARDING  : ALU/MEM buffer Forwarded last result_x70:%0d scheduled to be written in R%0d back to ALU input R%0d(B_x70) of this instruction", last_result, last_target, sourceB_in);
    end
  end

 
  last_target = 0;
  last_result = 0;
  case(inst_type_in)
    // 0 : NOP 
    1, 2, 4: // ADDU, ADDIU, LW
    begin
      result_x70 = Ain + Bin; 
      $display("EXECUTE    : A_x70=%0d, B_x70=%0d, result_x70=%0d, inst_type_x70:%0d", Ain, Bin, result_x70, inst_type_x70);
      if(inst_type_x70 == 1) begin // ADDU
	last_target = target_in;
	last_result = result_x70;
      end
    end
    3: // MUL
    begin
      result_x70 = Ain * Bin; 
      $display("EXECUTE    : A_x70=%0d, B_x70=%0d, result_x70=%0d, inst_type_x70:%0d (%d)", Ain, Bin, result_x70, inst_type_x70, target_x70);
      last_target = target_in;
      last_result = result_x70;
    end
    5: // BEQ 
    begin
      b_taken = (Ain == Bin) ? 1 : 0;
      stall_x70 = (predicted_x70 != b_taken) ? 1 : 0;
      pc_inc_x70 = (b_taken == 1 && stall_x70) ? (imm_in << 2) : 0; // Should've jumped but didn't so do it now.
      $display("EXECUTE    : Branching %0d instructions (predicted_x70:%0d, actual:%0d -> passed: %0d)", pc_inc_x70/4, predicted_x70, b_taken, !stall_x70);;
    end
    // 6: // JR // TODO
    7: // J
    begin
      //pc_inc_x70 = Joffset_in << 2;
      $display("EXECUTE    : already taken unconditional Jump");
      //$display("EXECUTE    : Jumping %0d instructions ", pc_inc_x70/4);
    end

    default: // unknown operation

    begin
    end

  endcase

end

endmodule


