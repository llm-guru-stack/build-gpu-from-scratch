// core.v : the simplest possible GPU core
// one register, one clock, two operations
module core (
  input  wire        clk,
  input  wire [7:0]  a,
  input  wire [7:0]  b,
  input  wire        op,      // 0 = add, 1 = multiply
  output reg  [15:0] result
);
  always @(posedge clk)
    result <= op ? a * b : a + b;
endmodule
