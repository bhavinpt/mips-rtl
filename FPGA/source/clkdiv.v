module clock_divider #
  (parameter N_pow = 23)
  (input clk_in, input reset,
   output reg clk_out,
   output reg reset_out
  );
  
  reg [(N_pow-2):0] counter = 0;
  reg [1:0] reset_fwd_done = 0;
  
  initial  begin
    //$dumpvars(0);
  end
  
  always @(posedge clk_in) begin
    if(reset) begin
    	counter <= 0;
        clk_out <= 0;
        reset_fwd_done <= 3;
        reset_out <= 0;
    end
    else begin
      if (counter == 0) begin
        if(reset_fwd_done != 0) begin
          reset_fwd_done <= reset_fwd_done - 1;
          reset_out <= 1;
        end
        else begin
          reset_out <= 0;
        end
        clk_out <= ~clk_out;
      end
      counter <= counter + 1;
    end
  end
  
endmodule
