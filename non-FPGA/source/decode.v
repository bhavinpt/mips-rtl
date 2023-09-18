//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Instruction Decode stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


module Instruction_Decode(
  input    read_clk_x70,
  input    writeback_clk_x70,
  input   reg_write_en_x70,
  input  [4:0] reg_write_dest_x70,
  input  [31:0] reg_write_data_x70,
  input  [4:0] reg_read_addr_1_x70,
  input  [4:0] reg_read_addr_2_x70,
  input signed [25:0] Joffset_x70,

  input [2:0] inst_type_x70,
  input has_imm_x70,
  input [31:0] imm_x70,
  input [4:0] target_x70,

  output  reg [31:0] reg_read_data_1_x70,
  output  reg [31:0] reg_read_data_2_x70,

  output reg signed [31:0] A_x70,
  output reg signed [31:0] B_x70,
  output reg [4:0] sourceA_x70, 
  output reg [4:0] sourceB_x70,
  output reg [31:0] wb_fwd_tapout_value_x70,
  output reg [4:0] wb_fwd_tapout_target_x70,

  output reg [2:0] inst_type_fwd_x70,
  output reg [31:0] imm_fwd_x70,
  output reg signed [25:0] Joffset_fwd_x70,
  output reg [4:0] target_fwd_x70
);

// register array
reg [31:0] reg_array [32];


reg [4:0] reg_read_addr_1_in;
reg [4:0] reg_read_addr_2_in;
reg [31:0] imm_in;
reg has_imm_in;
reg [4:0] reg_write_dest_in;
reg [31:0] reg_write_data_in;
reg reg_write_en_in;
reg [2:0] inst_type_in;

// hard-wire R0 to 0, rest don't need initialization
initial begin
  for(integer i = 0; i < 32; i++) begin
    reg_array[i] = 0;
  end
end

// stage 5 : writeback stage
always @ (posedge writeback_clk_x70 ) begin
  reg_write_en_in <= reg_write_en_x70;
  reg_write_dest_in <= reg_write_dest_x70;
  reg_write_data_in <= reg_write_data_x70;
  if(reg_write_en_x70 && reg_write_dest_x70 > 0) begin // R0 is hard-wired to 0, cannot be written
    reg_array[reg_write_dest_x70] <= reg_write_data_x70;
    $display("WRITE_BACK : written R%0d with %0d", reg_write_dest_x70, reg_write_data_x70);
    wb_fwd_tapout_value_x70 <= reg_write_data_x70;
    wb_fwd_tapout_target_x70 <= reg_write_dest_x70;
  end
end

// stage 2 : decode stage
always @(posedge read_clk_x70 ) begin
  // input buffer
  reg_read_addr_1_in <= reg_read_addr_1_x70;
  reg_read_addr_2_in <= reg_read_addr_2_x70;
  imm_in <= imm_x70;
  has_imm_in <= has_imm_x70;
  inst_type_in <= inst_type_x70;

  // forward
  inst_type_fwd_x70 = inst_type_in;
  imm_fwd_x70 = imm_in;
  Joffset_fwd_x70 <= Joffset_x70;
  target_fwd_x70 <= target_x70;

  reg_read_data_1_x70 = reg_array[reg_read_addr_1_in];
  reg_read_data_2_x70 = reg_array[reg_read_addr_2_in];

  if(inst_type_in > 0) begin
    A_x70 = reg_array[reg_read_addr_1_in];
    sourceA_x70 = reg_read_addr_1_in;

    if(inst_type_in == 5) begin //5=BEQ
      //B_x70 = imm_in;
      B_x70 = reg_array[reg_read_addr_2_in];
      sourceB_x70 = reg_read_addr_2_in;
      $display("INST_DECODE: A(R%0d) B=%0d(branch immediate)", A_x70, reg_read_addr_1_in, B_x70);
    end
    else if(has_imm_in) begin
      B_x70 = imm_in;
      sourceB_x70 = 0;
      $display("INST_DECODE: A=%0d(R%0d) B=%0d(immediate)", A_x70, reg_read_addr_1_in, B_x70);
    end
    else begin
      B_x70 = reg_array[reg_read_addr_2_in];
      sourceB_x70 = reg_read_addr_2_in;
      $display("INST_DECODE: A=%0d(R%0d) B=%0d(R%0d)", A_x70, reg_read_addr_1_in, B_x70, reg_read_addr_2_in);
    end
  end


end

endmodule
