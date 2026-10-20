// gpu_v1.v : four copies of our core, all wired to the SAME numbers.
// Spoiler: this has a bug. Run it and see.
module gpu_v1 (
  input  wire        clk,
  input  wire        op,          // 0 = add, 1 = multiply (same for every core)
  input  wire [7:0]  a,           // ONE a ...
  input  wire [7:0]  b,           // ... and ONE b, shared by all four cores
  output wire [63:0] result       // four 16-bit answers side by side
);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lane
      core c (.clk(clk), .op(op), .a(a), .b(b),
              .result(result[16*i +: 16]));
    end
  endgenerate
endmodule
