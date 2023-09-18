

module seg7(input wire clk,
            input wire reset,
            input wire [31:0] data,
            output [6:0] seg,
            output [7:0] an,
            output dp);
    
    
    reg [3:0] DIGIT1 = 'hA;
    reg [3:0] DIGIT2 = 'hB;
    reg [3:0] DIGIT3 = 'hC;
    reg [3:0] DIGIT4 = 'hD;
    reg [3:0] DIGIT5 = 'h1;
    reg [3:0] DIGIT6 = 'h2;
    reg [3:0] DIGIT7 = 'h3;
    reg [3:0] DIGIT8 = 'h4;
    
    
    initial begin
        $dumpvars(0, seg);
    end
    
    //////////////////////// Digits read //////////////////////
    
    always @(posedge clk or posedge reset) begin
        if (reset)
        begin
            DIGIT1 <= 'hA;
            DIGIT2 <= 'hB;
            DIGIT3 <= 'hC;
            DIGIT4 <= 'hD;
            DIGIT5 <= 'h1;
            DIGIT6 <= 'h2;
            DIGIT7 <= 'h3;
            DIGIT8 <= 'h4;
        end
        else begin
            DIGIT1 <= data[3:0];
            DIGIT2 <= data[7:4];
            DIGIT3 <= data[11:8];
            DIGIT4 <= data[15:12];
            DIGIT5 <= data[19:16];
            DIGIT6 <= data[23:20];
            DIGIT7 <= data[27:24];
            DIGIT8 <= data[31:28];
        end
    end
    
    //////////////////////// Ring counter for multiplexing ////////////////
    
    reg [31:0] counter;
    reg [7:0] ring = 8'b0000_0001;
    assign an      = ~ring;
    
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            counter <= 32'h0000_0000;
        else
            counter <= counter + 1'b1;
    end
    
    always @(posedge counter[15] or posedge reset)
    begin
        if (reset)
            ring <= 8'b0000_0001;
        else
            ring <= {ring[6:0],ring[7]};
    end
    
    //////////////////////// Digit select based on Ring Counter ////////////////
    
    assign dp = 1'b1; // always off
    wire [3:0] code = 
    (ring == 8'b00000001) ? DIGIT1 :
    (ring == 8'b00000010) ? DIGIT2 :
    (ring == 8'b00000100) ? DIGIT3 :
    (ring == 8'b00001000) ? DIGIT4 :
    (ring == 8'b00010000) ? DIGIT5 :
    (ring == 8'b00100000) ? DIGIT6 :
    (ring == 8'b01000000) ? DIGIT7 :
    (ring == 8'b10000000) ? DIGIT8 :
    4'h0;
    
    //////////////////////// Digit decoding for display ////////////////
    
    parameter A = 7'b0000001;
    parameter B = 7'b0000010;
    parameter C = 7'b0000100;
    parameter D = 7'b0001000;
    parameter E = 7'b0010000;
    parameter F = 7'b0100000;
    parameter G = 7'b1000000;
    
    assign seg = ~seg_out;
    wire [6:0] seg_out = 
    (code == 4'h0) ? A|B|C|D|E|F :
    (code == 4'h1) ? B|C :
    (code == 4'h2) ? A|B|G|E|D :
    (code == 4'h3) ? A|B|C|D|G :
    (code == 4'h4) ? F|B|G|C :
    (code == 4'h5) ? A|F|G|C|D :
    (code == 4'h6) ? A|F|G|C|D|E :
    (code == 4'h7) ? A|B|C :
    (code == 4'h8) ? A|B|C|D|E|F|G :
    (code == 4'h9) ? A|B|C|D|F|G :
    (code == 4'ha) ? A|F|B|G|E|C :
    (code == 4'hb) ? F|G|C|D|E :
    (code == 4'hc) ? G|E|D :
    (code == 4'hd) ? B|C|G|E|D :
    (code == 4'he) ? A|F|G|E|D :
    (code == 4'hf) ? A|F|G|E :
    7'b000_0000;
    
endmodule
