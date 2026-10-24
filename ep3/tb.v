`timescale 1ns/1ps
// one testbench for every design: pick it with -DDESIGN=... and -DN=...
module tb;
  reg clk = 0; always #5 clk = ~clk;
  reg rst; wire done, busy; wire [63:0] y;
  integer ticks = 0, work = 0;
  `DESIGN #(.N(`N), .FILE(`FILE)) g (.clk(clk), .rst(rst), .done(done), .y(y), .busy(busy));
  initial begin
    rst = 1; #10; rst = 0;
    $write("timeline: ");
    while (!done) begin
      #10; ticks = ticks + 1;
      if (ticks <= 90) $write("%s", busy === 1'b1 ? "M" : ".");
      if (busy === 1'b1) work = work + 1;
    end
    if (ticks > 90) $write("...");
    $display("");
    $display("  M = cores doing maths   . = cores waiting for memory");
    $display("cores busy %0d of %0d ticks (%0d%%)", work, ticks, 100*work/ticks);
    $display("y = [%0d, %0d, %0d, %0d]", y[15:0], y[31:16], y[47:32], y[63:48]);
    $finish;
  end
endmodule
