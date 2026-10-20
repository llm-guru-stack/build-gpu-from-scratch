// core_mac.v : our core, upgraded. It now REMEMBERS its answer (acc)
// so it can keep adding to it. acc = acc + a*b is called a MAC,
// multiply-accumulate: the single most important operation in AI.
module core_mac (
  input  wire        clk,
  input  wire [1:0]  op,
  input  wire [7:0]  a,
  input  wire [7:0]  b,
  output reg  [15:0] acc
);
  localparam CLR = 2'd1, MAC = 2'd2;   // 0 = do nothing
  always @(posedge clk) begin
    if (op == CLR) acc <= 0;
    if (op == MAC) acc <= acc + a * b;
  end
endmodule
