`timescale 1ns/1ps
module tb_gpu;
  reg clk = 0; always #5 clk = ~clk;
  reg rst; wire done; wire [63:0] y;
  integer tick;
  gpu g (.clk(clk), .rst(rst), .done(done), .y(y));
  initial begin
    rst = 1; #10; rst = 0;
    for (tick = 0; !done; tick = tick + 1) begin
      #10;
      $display("tick %0d  pc=%0d  lanes: %0d %0d %0d %0d", tick, g.pc,
               y[15:0], y[31:16], y[47:32], y[63:48]);
    end
    $display("done in %0d ticks", tick);
    $display("y = [%0d, %0d, %0d, %0d]", y[15:0], y[31:16], y[47:32], y[63:48]);
    $finish;
  end
endmodule
