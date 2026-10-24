// gpu_prefetch.v : fix 2, prefetching. Ask for the next weights while the
// earlier ones are still on their way, and do the maths the moment
// each delivery arrives.
module gpu_prefetch #(parameter N = 16, FILE = "weights16_wide.hex") (
  input  wire        clk,
  input  wire        rst,
  output reg         done,
  output wire [63:0] y,
  output wire        busy
);
  reg [7:0] x [0:N-1];
  integer j; initial for (j = 0; j < N; j = j + 1) x[j] = j + 1;

  reg        req;  reg [5:0] addr;
  wire       ready; wire [31:0] data;
  memory_pipe #(.LAT(4), .DEPTH(N), .FILE(FILE)) vram (.clk(clk), .req(req), .addr(addr), .ready(ready), .data(data));

  reg [5:0] asked, got;          // how many requests sent / deliveries received
  always @(posedge clk) begin
    req <= 0;
    if (rst) begin asked <= 0; got <= 0; done <= 0; end
    else begin
      if (asked < N) begin req <= 1; addr <= asked[5:0]; asked <= asked + 1; end   // keep asking
      if (ready) got <= got + 1;
      if (got == N) done <= 1;
    end
  end

  assign busy = ready;           // maths happens on every delivery
  wire [1:0] op = rst ? 2'd1 : (ready ? 2'd2 : 2'd0);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lanes
      core_mac c (.clk(clk), .op(op), .a(data[8*i +: 8]), .b(x[got[4:0]]), .acc(y[16*i +: 16]));
    end
  endgenerate
endmodule
