`timescale 1ns/1ps
module tb_v2;
  reg clk = 0; always #5 clk = ~clk;
  reg op; reg [31:0] a, b; wire [63:0] result;
  gpu_v2 gpu (.clk(clk), .op(op), .a(a), .b(b), .result(result));
  initial begin
    //        core 3    core 2   core 1   core 0
    a = {8'd200, 8'd7, 8'd5, 8'd3};
    b = {8'd200, 8'd8, 8'd6, 8'd4};
    op = 1; #10;                       // multiply, everywhere, in one tick
    $display("core 0: %0d", result[15:0]);
    $display("core 1: %0d", result[31:16]);
    $display("core 2: %0d", result[47:32]);
    $display("core 3: %0d", result[63:48]);
    $finish;
  end
endmodule
