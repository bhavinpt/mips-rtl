//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Execute stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


module Execute(input clk,
               input reset,
               input done_in,
               input [3:0] instr_type_ID,
               input [4:0] wb_tgt_ID,
               input signed [31:0] A,
               input signed [31:0] B,
               input [4:0] sourceA,
               input [4:0] sourceB,
               input [15:0] sw_offset,
               output reg [3:0] instr_type_EX,
               output reg [4:0] wb_tgt_EX,
               output reg [15:0] sw_addr,
               output reg signed [31:0] result,
               output reg done_out);
    
    
    always @(posedge clk)
    begin
        if (reset) begin
            result        <= 0;
            wb_tgt_EX     <= 0;
            instr_type_EX <= 0;
            done_out      <= 0;
        end
        else begin
            done_out      <= done_in;
            instr_type_EX <= instr_type_ID;
            wb_tgt_EX     <= wb_tgt_ID;
            done_out      <= done_in;
            case(instr_type_ID)
                
                // R-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | rd (5b)[15:11]  | shamt(5)[10:6] | funct(6)[5:0]
                //? add rd, rs, rt # rd <-- rs ADD rt                           000000	rs	rt	rd	00000  100000
                //? sub rd, rs, rt # rd <-- rs SUB rt                           000000	rs	rt	rd	00000  100010
                //? and rd, rs, rt # rd <-- rs AND rt                           000000	rs	rt	rd	00000  100100
                //? or  rd, rs, rt # rd <-- rs OR rt                            000000	rs	rt	rd	00000  100101
                //? xor rd, rs, rt # rd <-- rs XOR rt                           000000	rs	rt	rd	00000  100110
                
                1 : // ADD
                begin
                    result <= A + B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (ADD)", result);
                end
                2 : // SUB
                begin
                    result <= A - B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (SUB)", result);
                end
                3 : // AND
                begin
                    result <= A & B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (AND)", result);
                end
                4 : // OR
                begin
                    result <= A | B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (OR)", result);
                end
                5 : // XOR
                begin
                    result <= A ^ B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (XOR)", result);
                end
                
                // R-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | rd (5b)[15:11]  | shamt(5)[10:6] | funct(6)[5:0]
                
                //? sll rd, rt, sa # rd <-- rt SLL sa                           000000	00	rt	rd	sa	   000000
                //? srl rd, rt, sa # rd <-- rt SRL sa                           000000	00	rt	rd	sa	   000010
                //? sra rd, rt, sa # rd <-- rt SRA sa                           000000	00	rt	rd	sa	   000011
                
                6 : // SLL
                begin
                    result <= A << B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (SLL)", result);
                end
                7 : // SRL
                begin
                    result <= A >> B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (SRL)", result);
                end
                8 : // SRA
                begin
                    result <= A >>> B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (SRA)", result);
                end
                
                // I-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | imm(16)[15:0]
                
                //? addi rt, rs, immediate # rt <-- rs ADD (sign)immediate      001000	rs	rt	imm
                //? andi rt, rs, immediate # rt <-- rs AND (zero)immediate      001100	rs	rt	imm
                //? ori  rt, rs, immediate # rt <-- rs OR (zero)immediate       001101	rs	rt	imm
                //? xori rt, rs, immediate # rt <-- rs XOR (zero)immediate      001110	rs	rt	imm
                
                9 : // ADDI
                begin
                    result <= A + B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (ADDI)", result);
                end
                
                10 : // ANDI
                begin
                    result <= A & B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (ANDI)", result);
                end
                11 : // ORI
                begin
                    result <= A | B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (ORI)", result);
                end
                12 : // XORI
                begin
                    result <= A ^ B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (XORI)", result);
                end
                
                //? lw rt, offset(rs) # rt <-- memory[rs + offset]              100011	rs	rt	offset
                //? sw rt, offset(rs) # memory[rs + offset] <-- rtran           101011	rs	rt	offset
                
                13 : // LW
                begin
                    result <= A + B;
                    $display("[EX] : A     = %0x, B     = %0x", A, B);
                    $strobe("[EX] : result = 0x%0x (LW)", result);
                end
                14 : // SW
                begin
                    result  <= A;
                    sw_addr <= B + sw_offset;
                    $display("[EX] : sw_addr = %0x", B + sw_offset);
                    $strobe("[EX] : result   = 0x%0x (SW)", result);
                end
                
                default: // unknown operation
                begin
                    $display("[EX] : nop");
                end
                
            endcase
        end
    end
    
endmodule
    
    
