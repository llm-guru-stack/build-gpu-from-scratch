// gpu_mem.v : the weights now live in memory.
// The scheduler loads each lane's weight one at a time, waits for it,
// and only when all four lanes have their weight does it run a MAC.
module gpu_mem #(parameter N = 3, FILE = "weights_tiny.hex") (
  input  wire        clk,
  input  wire        rst,
  output reg         done,
  output wire [63:0] y,
  output reg         busy        // 1 on ticks where the cores do maths
);
  // the input is tiny, so it stays on the chip: x = 1, 2, 3, ...
  reg [7:0] x [0:N-1];
  integer j; initial for (j = 0; j < N; j = j + 1) x[j] = j + 1;

  reg        req;  reg [5:0] addr;
  wire       ready; wire [7:0] data;
  memory #(.LAT(4), .DEPTH(4*N), .FILE(FILE)) vram (.clk(clk), .req(req), .addr(addr), .ready(ready), .data(data));

  localparam ASK = 0, WAIT = 1, RUN = 2, FIN = 3;
  reg [1:0] state, lane;
  reg [4:0] k, k_mac;
  reg [7:0] w [0:3];             // each lane's weight for this step
  reg [1:0] op;                  // to the cores: 0 idle, 1 clear, 2 MAC

  always @(posedge clk) begin
    req <= 0; op <= 0; busy <= 0;
    if (rst) begin state <= ASK; lane <= 0; k <= 0; done <= 0; op <= 1; end
    else case (state)
      ASK:  begin req <= 1; addr <= lane*N + k; state <= WAIT; end   // LOAD: lane's own shelf
      WAIT: if (ready) begin
              w[lane] <= data;
              if (lane == 3) state <= RUN;
              else begin lane <= lane + 1; state <= ASK; end
            end
      RUN:  begin
              op <= 2; busy <= 1; lane <= 0; k_mac <= k;
              if (k == N - 1) state <= FIN; else begin k <= k + 1; state <= ASK; end
            end
      FIN:  done <= 1;
    endcase
  end

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lanes
      core_mac c (.clk(clk), .op(op), .a(w[i]), .b(x[k_mac]), .acc(y[16*i +: 16]));
    end
  endgenerate
endmodule
