//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Fetch stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


//////////////// ISA ///////////////////

// R-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | rd (5b)[15:11]  | shamt(5)[10:6] | funct(6)[5:0]
// I-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | imm(16)[15:0]

//? add rd, rs, rt # rd <-- rs ADD rt                           000000	rs	rt	rd	00000  100000
//? sub rd, rs, rt # rd <-- rs SUB rt                           000000	rs	rt	rd	00000  100010
//? and rd, rs, rt # rd <-- rs AND rt                           000000	rs	rt	rd	00000  100100
//? or  rd, rs, rt # rd <-- rs OR rt                            000000	rs	rt	rd	00000  100101
//? xor rd, rs, rt # rd <-- rs XOR rt                           000000	rs	rt	rd	00000  100110

//? sll rd, rt, sa # rd <-- rt SLL sa                           000000	00	rt	rd	sa	   000000
//? srl rd, rt, sa # rd <-- rt SRL sa                           000000	00	rt	rd	sa	   000010
//? sra rd, rt, sa # rd <-- rt SRA sa                           000000	00	rt	rd	sa	   000011

//? addi rt, rs, immediate # rt <-- rs ADD (sign)immediate      001000	rs	rt	imm
//? andi rt, rs, immediate # rt <-- rs AND (zero)immediate      001100	rs	rt	imm
//? ori  rt, rs, immediate # rt <-- rs OR (zero)immediate       001101	rs	rt	imm
//? xori rt, rs, immediate # rt <-- rs XOR (zero)immediate      001110	rs	rt	imm

//? lw rt, offset(rs) # rt <-- memory[rs + offset]              100011	rs	rt	offset
//? sw rt, offset(rs) # memory[rs + offset] <-- rtran           101011	rs	rt	offset


// instruction_x70 decode
module Instruction_Fetch(input wire clk,
                         input wire reset,
                         output reg[3:0] instr_type_IF,
                         output reg has_imm,
                         output reg signed [31:0] imm,
                         output reg has_rs,
                         output reg [4:0] rs,
                         output reg has_rt,
                         output reg [4:0] rt,
                         output reg has_rd,
                         output reg [4:0] rd,
                         output reg done);
    
    // only the first 2^8 are supported instead of 2^32 due to hadware limitation
    reg [31:0] memory [255:0];
    reg signed [31:0] pc;
    wire [31:0] instr_read;
    
    assign instr_read = memory[pc[9:2]];
    
    initial
    begin
      $readmemb("test.prog", memory, 0);
        
        //$strobe("[IF] : %p", memory);
    end
    
    
    always @(posedge clk)
    begin
        if (reset) begin
            pc            <= 0;
            instr_type_IF <= 0;
            has_imm       <= 0;
            imm           <= 0;
            has_rs        <= 0;
            rs            <= 0;
            has_rt        <= 0;
            rt            <= 0;
            has_rd        <= 0;
            rd            <= 0;
            done          <= 0;
            
        end
        else begin
            if (!done) begin
                // done executing all instructions
                if (instr_read == 32'hFFFF_FFFF) // EOP (End Of Program)
                begin
                    $display("----- End Of Program -----");
                    done          <= 1;
                    instr_type_IF <= 0;
                    has_imm       <= 0;
                    has_rs        <= 0;
                    has_rt        <= 0;
                    has_rd        <= 0;
                    imm           <= 0;
                    rs            <= 0;
                    rt            <= 0;
                    rd            <= 0;
                end
                else if (instr_read == 32'h0000_0000) // NOP (No OPeration)
                begin
                    instr_type_IF <= 0;
                    has_imm       <= 0;
                    has_rs        <= 0;
                    has_rt        <= 0;
                    has_rd        <= 0;
                    imm           <= 0;
                    rs            <= 0;
                    rt            <= 0;
                    rd            <= 0;
                    
                    $display("[IF] : PC = %0d (%0dth inst)", pc, ((pc/4) + 1));
                    $display("[IF] : (%b)", instr_read);
                    $display("[IF] : NOP");
                    pc <= pc + 4;
                end
                else
                begin
                    $display("[IF] : PC = %0d (%0dth inst)", pc, ((pc/4) + 1));
                    $display("[IF] : (%b)", instr_read);
                    
                    // update PC for next instr
                    pc <= pc + 4;
                    
                    // decode instr
                    casex({instr_read[31:26] , instr_read [5:0]}) // {opcode, funct}
                        
                        // R-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | rd (5b)[15:11]  | shamt(5)[10:6] | funct(6)[5:0]
                        //? add rd, rs, rt # rd <-- rs ADD rt                           000000	rs	rt	rd	00000  100000
                        //? sub rd, rs, rt # rd <-- rs SUB rt                           000000	rs	rt	rd	00000  100010
                        //? and rd, rs, rt # rd <-- rs AND rt                           000000	rs	rt	rd	00000  100100
                        //? or  rd, rs, rt # rd <-- rs OR rt                            000000	rs	rt	rd	00000  100101
                        //? xor rd, rs, rt # rd <-- rs XOR rt                           000000	rs	rt	rd	00000  100110
                        
                        'b000000_100000 : // ADD
                        begin
                            instr_type_IF <= 1;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 1;
                            has_imm       <= 0;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= instr_read[15:11];
                            imm           <= 0;
                            $strobe("[IF] : ADD  : rs = R%0d, rt = R%0d, rd = R%0d", rs, rt, rd);
                        end
                        'b000000_100010 : // SUB
                        begin
                            instr_type_IF <= 2;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 1;
                            has_imm       <= 0;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= instr_read[15:11];
                            imm           <= 0;
                            $strobe("[IF] : SUB  : rs = R%0d, rt = R%0d, rd = R%0d", rs, rt, rd);
                            
                        end
                        'b000000_100100 : // AND
                        begin
                            instr_type_IF <= 3;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 1;
                            has_imm       <= 0;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= instr_read[15:11];
                            imm           <= 0;
                            $strobe("[IF] : AND  : rs = R%0d, rt = R%0d, rd = R%0d", rs, rt, rd);
                        end
                        'b000000_100101 : // OR
                        begin
                            instr_type_IF <= 4;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 1;
                            has_imm       <= 0;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= instr_read[15:11];
                            imm           <= 0;
                            $strobe("[IF] : OR  : rs = R%0d, rt = R%0d, rd = R%0d", rs, rt, rd);
                        end
                        'b000000_100110 : // XOR
                        begin
                            instr_type_IF <= 5;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 1;
                            has_imm       <= 0;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= instr_read[15:11];
                            imm           <= 0;
                            $strobe("[IF] : XOR  : rs = R%0d, rt = R%0d, rd = R%0d", rs, rt, rd);
                        end
                        
                        // R-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | rd (5b)[15:11]  | shamt(5)[10:6] | funct(6)[5:0]
                        
                        //? sll rd, rt, sa # rd <-- rt SLL sa                           000000	00	rt	rd	sa	   000000
                        //? srl rd, rt, sa # rd <-- rt SRL sa                           000000	00	rt	rd	sa	   000010
                        //? sra rd, rt, sa # rd <-- rt SRA sa                           000000	00	rt	rd	sa	   000011
                        
                        'b000000_000000 : // SLL
                        begin
                            instr_type_IF <= 6;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[20:16];
                            rt            <= instr_read[15:11];
                            rd            <= 0;
                            imm           <= instr_read[10:6];  // shift amount is
                          $strobe("[IF] : SLL  : rs = R%0d, rt = R%0d, imm = 0x%0x", rs, rt, imm);

                        end
                        'b000000_000010 : // SRL
                        begin
                          
                            instr_type_IF <= 7;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[20:16];
                            rt            <= instr_read[15:11];
                            rd            <= 0;
                            imm           <= instr_read[10:6];  // shift amount is immediate
                          $strobe("[IF] : SRL  : rs = R%0d, rt = R%0d, imm = 0x%0x", rs, rt, imm);
                        end
                        'b000000_000011 : // SRA
                        begin
                            instr_type_IF <= 8;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[20:16];
                            rt            <= instr_read[15:11];
                            rd            <= 0;
                            imm           <= instr_read[10:6];  // shift amount is immediate
                          $strobe("[IF] : SRL  : rs = R%0d, rt = R%0d, imm = 0x%0x", rs, rt, imm);
                        end
                        
                        // I-Type : opcode (6b)[31:26] | rs (5b)[25:21] | rt (5b)[20:16] | imm(16)[15:0]
                        
                        //? addi rt, rs, immediate # rt <-- rs ADD (sign)immediate      001000	rs	rt	imm
                        //? andi rt, rs, immediate # rt <-- rs AND (zero)immediate      001100	rs	rt	imm
                        //? ori  rt, rs, immediate # rt <-- rs OR (zero)immediate       001101	rs	rt	imm
                        //? xori rt, rs, immediate # rt <-- rs XOR (zero)immediate      001110	rs	rt	imm
                        
                        'b001000_xxxxxx : // ADDI
                        begin
                            instr_type_IF <= 9;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= 0;
                            imm           <= instr_read[15:0];
                            $strobe("[IF] : ADDI  : rt = R%0d, rs = R%0d, imm = 0x%0x", rt, rs, imm);
                        end
                        
                        'b001100_xxxxxx : // ANDI
                        begin
                            instr_type_IF <= 10;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= 0;
                            imm           <= instr_read[15:0];
                            $strobe("[IF] : ANDI  : rt = R%0d, rs = R%0d, imm = 0x%0x", rt, rs, imm);
                        end
                        'b001101_xxxxxx : // ORI
                        begin
                            instr_type_IF <= 11;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= 0;
                            imm           <= instr_read[15:0];
                            $strobe("[IF] : ORI  : rt = R%0d, rs = R%0d, imm = 0x%0x", rt, rs, imm);
                        end
                        'b001110_xxxxxx : // XORI
                        begin
                            instr_type_IF <= 12;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= 0;
                            imm           <= instr_read[15:0];
                            $strobe("[IF] : XORI  : rt = R%0d, rs = R%0d, imm = 0x%0x", rt, rs, imm);
                        end
                        
                        //? lw rt, offset(rs) # rt <-- memory[rs + offset]              100011	rs	rt	offset
                        //? sw rt, offset(rs) # memory[rs + offset] <-- rtran           101011	rs	rt	offset
                        
                        'b100011_xxxxxx : // LW
                        begin
                            instr_type_IF <= 13;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= 0;
                            imm           <= instr_read[15:0];
                            $strobe("[IF] : LW  : rt = R%0d, rs = R%0d, imm = 0x%0x", rt, rs, imm);
                        end
                        'b101011_xxxxxx : // SW
                        begin
                            instr_type_IF <= 14;
                            has_rs        <= 1;
                            has_rt        <= 1;
                            has_rd        <= 0;
                            has_imm       <= 1;
                            rs            <= instr_read[25:21];
                            rt            <= instr_read[20:16];
                            rd            <= 0;
                            imm           <= instr_read[15:0];
                            $strobe("[IF] : SW  : rt = R%0d, rs = R%0d, imm = 0x%0x", rt, rs, imm);
                        end
                        
                        default:
                        begin
                            instr_type_IF <= 14;
                            has_rs        <= 0;
                            has_rt        <= 0;
                            has_rd        <= 0;
                            has_imm       <= 0;
                            rs            <= 0;
                            rt            <= 0;
                            rd            <= 0;
                            imm           <= 0;
                            $strobe("[IF] : INVALID  : rt = R%0d, rs = R%0d, imm = R%0d", rt, rs, imm);
                        end
                    endcase
                    
                end
            end
        end
    end
    
endmodule
    
