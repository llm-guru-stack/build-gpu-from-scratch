// gpu_wide.v : fix 1, coalescing. One wide delivery carries all four
// lanes' weights for input k, so there's one trip per step, not four.
module gpu_wide #(parameter N = 16, FILE = "weights16_wide.hex") (
  input  wire        clk,
  input  wire        rst,
  output reg         done,
  output wire [63:0] y,
  output reg         busy
);
  reg [7:0] x [0:N-1];
  integer j; initial for (j = 0; j < N; j = j + 1) x[j] = j + 1;

  reg        req;  reg [5:0] addr;
  wire       ready; wire [31:0] data;
  memory_wide #(.LAT(4), .DEPTH(N), .FILE(FILE)) vram (.clk(clk), .req(req), .addr(addr), .ready(ready), .data(data));

  localparam ASK = 0, WAIT = 1, RUN = 2, FIN = 3;
  reg [1:0] state, op;
  reg [4:0] k, k_mac;
  reg [31:0] w4;                 // all four lanes' weights, side by side

  always @(posedge clk) begin
    req <= 0; op <= 0; busy <= 0;
    if (rst) begin state <= ASK; k <= 0; done <= 0; op <= 1; end
    else case (state)
      ASK:  begin req <= 1; addr <= k; state <= WAIT; end            // one LOAD for everyone
      WAIT: if (ready) begin w4 <= data; state <= RUN; end
      RUN:  begin
              op <= 2; busy <= 1; k_mac <= k;
              if (k == N - 1) state <= FIN; else begin k <= k + 1; state <= ASK; end
            end
      FIN:  done <= 1;
    endcase
  end

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lanes
      core_mac c (.clk(clk), .op(op), .a(w4[8*i +: 8]), .b(x[k_mac]), .acc(y[16*i +: 16]));
    end
  endgenerate
endmodule
