// tb.v : feed the core some numbers and watch what it does
`timescale 1ns/1ps
module tb;
  reg        clk = 0;
  reg  [7:0] a, b;
  reg        op;
  wire [15:0] result;

  core dut (.clk(clk), .a(a), .b(b), .op(op), .result(result));

  always #5 clk = ~clk;          // a 100 MHz clock: tick every 10 ns

  initial begin
    a = 3; b = 4; op = 0;  #10;  $display("%0d + %0d = %0d", a, b, result);
    a = 3; b = 4; op = 1;  #10;  $display("%0d x %0d = %0d", a, b, result);
    a = 200; b = 200; op = 1; #10; $display("%0d x %0d = %0d", a, b, result);
    $finish;
  end
endmodule
