// memory_pipe.v : wide AND pipelined. It still takes LAT ticks per trip,
// but it accepts a new request EVERY tick, so trips overlap,
// like crates riding a conveyor belt one behind the other.
module memory_pipe #(parameter LAT = 4, DEPTH = 16, FILE = "weights16_wide.hex") (
  input  wire        clk,
  input  wire        req,
  input  wire [5:0]  addr,
  output reg         ready,
  output reg  [31:0] data
);
  reg [31:0] shelf [0:DEPTH-1];
  initial $readmemh(FILE, shelf);
  reg       v [0:LAT-1];          // is there a crate on this part of the belt?
  reg [5:0] a [0:LAT-1];          // which shelf that crate is for
  integer i;
  initial begin ready = 0; for (i = 0; i < LAT; i = i + 1) v[i] = 0; end
  always @(posedge clk) begin
    v[0] <= req; a[0] <= addr;                    // put a crate on the belt
    for (i = 1; i < LAT; i = i + 1) begin         // move every crate one step
      v[i] <= v[i-1]; a[i] <= a[i-1];
    end
    ready <= v[LAT-1];                            // crate at the end: deliver
    data  <= shelf[a[LAT-1]];
  end
endmodule
