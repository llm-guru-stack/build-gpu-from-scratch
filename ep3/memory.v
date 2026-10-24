// memory.v : a slow memory, like the VRAM chips around a real GPU.
// Ask for a shelf (req + addr). LAT ticks later the value arrives on
// data, with ready = 1 for one tick. It handles ONE request at a time.
module memory #(parameter LAT = 4, DEPTH = 64, FILE = "weights_tiny.hex") (
  input  wire       clk,
  input  wire       req,          // "please fetch this shelf"
  input  wire [5:0] addr,         // which shelf
  output reg        ready,        // "here it is"
  output reg  [7:0] data
);
  reg [7:0] shelf [0:DEPTH-1];    // the storage itself
  initial $readmemh(FILE, shelf);

  reg [5:0] a;                    // the shelf we're fetching
  reg [7:0] left = 0;             // ticks until it arrives (0 = idle)
  initial ready = 0;

  always @(posedge clk) begin
    ready <= 0;
    if (left == 0 && req) begin   // idle and asked: start the trip
      a    <= addr;
      left <= LAT;
    end else if (left == 1) begin // trip finished: deliver
      data  <= shelf[a];
      ready <= 1;
      left  <= 0;
    end else if (left > 1)        // still on the way
      left <= left - 1;
  end
endmodule
