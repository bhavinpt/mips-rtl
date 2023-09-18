// `include "clkdiv.v"
// `include "processor.v"
// `include "fetch.v"
// `include "decode.v"
// `include "execute.v"
// `include "memory.v"
// `include "7seg.v"

module top(input wire clk,
           input wire resetn,
           output done,       // to green
           output done_not,   // to blue
           output reset_ind,  // to red
           output [6:0] seg,
           output [7:0] an,
           output dp);
    
    wire [31:0] word_0;
    wire proc_clock;
    wire proc_reset;
    wire done_ind;
    
    assign reset_ind = reset;
    assign done      = (~reset_ind) & done_ind;
    assign done_not  = (~reset_ind) & ~done_ind;
    assign reset     = ~resetn;
    
    clock_divider #(24) clock_divider_inst (
    .clk_in(clk),
    .reset(reset),
    .clk_out(proc_clock),
    .reset_out(proc_reset)
    );
    
    Processor proc(
    .clk(proc_clock),
    .reset(proc_reset),
    .done(done_ind),
    .mem_word_0(word_0)
    );
    
    seg7 disp(
    .clk(clk),
    .reset(reset),
    .data(word_0),
    .seg(seg),
    .an(an),
    .dp(dp)
    );
    
    
    
endmodule
