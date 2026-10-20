`timescale 1ns/1ps
module tb_v1;
  reg clk = 0; always #5 clk = ~clk;
  reg op; reg [7:0] a, b; wire [63:0] result;
  gpu_v1 gpu (.clk(clk), .op(op), .a(a), .b(b), .result(result));
  initial begin
    a = 3; b = 4; op = 0; #10;
    $display("core 0: %0d", result[15:0]);
    $display("core 1: %0d", result[31:16]);
    $display("core 2: %0d", result[47:32]);
    $display("core 3: %0d", result[63:48]);
    $finish;
  end
endmodule
