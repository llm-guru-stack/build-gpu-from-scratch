// gpu_v2.v : same four cores, but every core gets ITS OWN numbers.
// The loop counter i is the core's thread ID: core i reads slot i.
module gpu_v2 (
  input  wire        clk,
  input  wire        op,          // still ONE instruction for everyone
  input  wire [31:0] a,           // four 8-bit numbers packed together
  input  wire [31:0] b,
  output wire [63:0] result
);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lane
      core c (.clk(clk), .op(op),
              .a(a[8*i +: 8]),          // slot i: bits 8*i up to 8*i+7
              .b(b[8*i +: 8]),
              .result(result[16*i +: 16]));
    end
  endgenerate
endmodule
