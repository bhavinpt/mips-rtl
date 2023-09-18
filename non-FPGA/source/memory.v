//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Memory stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


module Memory(
  input wire mem_clk_x70,
  input wire[2:0] inst_type_x70,
  input wire [4:0] target_x70,
  input wire signed [31:0] result_x70,

  output reg [31:0] mw_fwd_tapout_value_x70,
  output reg [4:0] mw_fwd_tapout_target_x70,
  output reg [4:0] reg_write_dest_x70,
  output reg [31:0] reg_write_data_x70,
  output reg reg_write_en_x70
 
);

// memory
reg [5:0] byte_address;
reg [31:0] memory [256];
reg [7:0] mem_read_addr;


reg [2:0] inst_type_in;
reg [4:0] target_in;
reg [31:0] result_in;

initial
begin
  $readmemh("./test.data", memory);
  reg_write_en_x70 = 0;
end



// memory stage
always @(posedge mem_clk_x70) 
begin
  inst_type_in <= inst_type_x70;
  target_in <= target_x70;
  result_in <= result_x70;

  //mem_read_data = 0;
  reg_write_data_x70 = 0;
  case(inst_type_in)
    1, 2, 3 : // ADD, ADDIU, MUL
    begin
      reg_write_dest_x70 = target_in;
      reg_write_data_x70 = result_in;
      reg_write_en_x70 = 1;
      $display("initiated write of result_x70=%0d to R%0d", reg_write_data_x70, reg_write_dest_x70);
    end
    4: // LW
    begin
      reg_write_dest_x70 = target_in;
      reg_write_en_x70 = 1;

      // do memory read
      mem_read_addr = result_in;
      byte_address = mem_read_addr[7:2];
      reg_write_data_x70 = memory[byte_address]; 
      $display("MEMORY     : read data=%0d from address=%0d(%0dth) of memory", memory[byte_address], mem_read_addr, byte_address);
    end
    default:
    begin
      reg_write_en_x70 = 0;
    end

  endcase

  mw_fwd_tapout_value_x70 = reg_write_data_x70;
  mw_fwd_tapout_target_x70 = target_in;

end

endmodule

