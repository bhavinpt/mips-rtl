//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Instruction Decode stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


module Instruction_Decode(input clk,
                          input reset,
                          input done_in_ID,
                          input done_in_WB,
                          input wb_en,
                          input [4:0] wb_addr,
                          input [31:0] wb_data,
                          input has_rs,
                          input [4:0] rs,
                          input has_rt,
                          input [4:0] rt,
                          input has_rd,
                          input [4:0] rd,
                          input has_imm,
                          input [31:0] imm,
                          input [3:0] instr_type_IF,
                          output reg signed [31:0] A,
                          output reg signed [31:0] B,
                          output reg [4:0] sourceA,
                          output reg [4:0] sourceB,
                          output reg [4:0] wb_tgt_ID,
                          output reg [3:0] instr_type_ID,
                          output reg [15:0] sw_offset,
                          output reg done_ID,
                          output reg done_WB);
    
    // register array
    reg [31:0] reg_array [31:0];
    
    // hard-wire R0 to 0, rest don't need initialization
    
    always @(posedge clk) begin
        
        if (reset) begin
            A             <= 0;
            B             <= 0;
            sourceA       <= 0;
            sourceB       <= 0;
            wb_tgt_ID     <= 0;
            instr_type_ID <= 0;
            done_ID       <= 0;
            done_WB       <= 0;
            
            reg_array[0]  <= 0;
            reg_array[1]  <= 0;
            reg_array[2]  <= 0;
            reg_array[3]  <= 0;
            reg_array[4]  <= 0;
            reg_array[5]  <= 0;
            reg_array[6]  <= 0;
            reg_array[7]  <= 0;
            reg_array[8]  <= 0;
            reg_array[9]  <= 0;
            reg_array[10] <= 0;
            reg_array[11] <= 0;
            reg_array[12] <= 0;
            reg_array[13] <= 0;
            reg_array[14] <= 0;
            reg_array[15] <= 0;
            reg_array[16] <= 0;
            reg_array[17] <= 0;
            reg_array[18] <= 0;
            reg_array[19] <= 0;
            reg_array[20] <= 0;
            reg_array[21] <= 0;
            reg_array[22] <= 0;
            reg_array[23] <= 0;
            reg_array[24] <= 0;
            reg_array[25] <= 0;
            reg_array[26] <= 0;
            reg_array[27] <= 0;
            reg_array[28] <= 0;
            reg_array[29] <= 0;
            reg_array[30] <= 0;
            reg_array[31] <= 0;
        end
        else begin
            // stage 5 : writeback
            done_WB <= done_in_WB;
            if (wb_en && wb_addr > 0) begin // R0 is hard-wired to 0, cannot be written
                reg_array[wb_addr] <= wb_data;
                $display("[WB] : Writeback of R%0d with 0x%0x", wb_addr, wb_data);
            end
            else begin
                $display("[WB] : nop");
            end
            
            // stage 2 : decode
            done_ID       <= done_in_ID;
            instr_type_ID <= instr_type_IF;
            if (instr_type_IF > 0) begin  // maybe not needed
                
                A       <= reg_array[rs];
                sourceA <= rs;
                
                if (instr_type_IF == 14) begin // Store
                    B         <= reg_array[rt];
                    sourceB   <= rt;
                    wb_tgt_ID <= 0;
                    sw_offset <= imm;
                    $display("[ID] : A = 0x%0x(R%0d) B = 0x%0x(R%0d) imm = %d", reg_array[rs], rs, reg_array[rt], rt, imm);
                end
                else if (has_imm) begin
                    B         <= imm;
                    sourceB   <= 0;
                    wb_tgt_ID <= rt;
                    $display("[ID] : A = 0x%0x(R%0d) B = %0d(immediate)  wb_tgt: R%0d", reg_array[rs],rs, imm, rt);
                end
                else begin
                    B         <= reg_array[rt];
                    sourceB   <= rt;
                    wb_tgt_ID <= rd;
                    $display("[ID] : A = 0x%0x(R%0d) B = 0x%0x(R%0d)  wb_tgt: R%0d", reg_array[rs], rs, reg_array[rt], rt, rd);
                end
            end
            else begin
                $display("[ID] : nop");
            end
        end
    end
    
endmodule
