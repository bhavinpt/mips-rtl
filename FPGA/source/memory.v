//////////////////////////////////////////////////////////////////////////////////////////////
// Description: Memory stage of pipelined MIPS with Branch Predictor and Data Path Forwarding
//		Implemented as a part of Mini-Project 2 of EE275(fall'22)
// Developed By: Bhavin patel (SJSU-ID: 015954770)
//////////////////////////////////////////////////////////////////////////////////////////////


module Memory(input wire clk,
              input wire reset,
              input wire done_in,
              input wire [3:0] instr_type_EX,
              input wire [4:0] wb_tgt_EX,
              input wire signed [31:0] result,
              input wire [15:0] sw_addr,
              output reg [4:0] wb_addr,
              output reg [31:0] wb_data,
              output reg [31:0] mem_word_0,
              output reg wb_en,
              output reg done_out);
    
    // data memory
    reg [31:0] memory [255:0]; // only 256 locations supported
    reg [7:0] mem_read_addr;
    
    
    initial
    begin
        $readmemh("C:/Users/Checkout/Desktop/FP/source/test.data", memory);
    end
    
    // memory stage
    always @(posedge clk)
    begin
        if (reset) begin
            wb_en    <= 0;
            wb_data  <= 0;
            wb_addr  <= 0;
            done_out <= 0;
            memory[0] <= 'h0; // initialize the result location
        end
        else begin
            mem_word_0 <= memory[0];
            done_out   <= done_in;
            
            wb_data <= 0;
            if (instr_type_EX > 0 && instr_type_EX < 13) begin // ...
                wb_addr <= wb_tgt_EX;
                wb_en   <= 1;
                wb_data <= result;
                $display("[MM] : initiated write of result = 0x%0x to R%0d", result, wb_tgt_EX);
            end
            else if (instr_type_EX == 13) begin // LW
                wb_addr <= wb_tgt_EX;
                wb_en   <= 1;
                
                // do memory read
                wb_data <= memory[result[7:2]];
                $display("[MM] : load data = 0x%0x from %0dth word of memory", memory[result[7:2]], result[7:2]);
            end
                else if (instr_type_EX == 14) begin // SW
                wb_addr <= 0;
                wb_en   <= 0;
                
                // do memory write
                memory[sw_addr[7:2]] <= result;
                $display("[MM] : store data = 0x%0x to %0dth word of memory",result, sw_addr[7:2]);
                end
            else begin
                wb_en <= 0;
                $display("[MM] : nop");
            end
        end
    end
    
endmodule
    
