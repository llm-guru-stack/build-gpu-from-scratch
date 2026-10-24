// memory_wide.v : same slow memory, but each shelf is 32 bits wide:
// four 8-bit weights side by side, one for each lane.
module memory_wide #(parameter LAT = 4, DEPTH = 16, FILE = "weights16_wide.hex") (
  input  wire        clk,
  input  wire        req,
  input  wire [5:0]  addr,
  output reg         ready,
  output reg  [31:0] data         // four weights in one delivery
);
  reg [31:0] shelf [0:DEPTH-1];
  initial $readmemh(FILE, shelf);
  reg [5:0] a;
  reg [7:0] left = 0;
  initial ready = 0;
  always @(posedge clk) begin
    ready <= 0;
    if (left == 0 && req) begin a <= addr; left <= LAT; end
    else if (left == 1) begin data <= shelf[a]; ready <= 1; left <= 0; end
    else if (left > 1) left <= left - 1;
  end
endmodule
