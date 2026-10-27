// gpu.v : episode 4. A programmable GPU.
// The scheduler reads its program from program.hex, so new programs need
// no new hardware. Four MAC lanes; weights in memory (32-bit shelves, one
// weight per lane); the input x is shared by every lane.
module gpu #(parameter DIV = 234) (
  input  wire        clk,
  input  wire        rst,          // 1 = restart the program
  output reg         done = 0,
  output wire        tx,           // serial text out
  output wire [63:0] y,
  output reg  [5:0]  pc = 0,
  output reg  [15:0] cycles = 0    // how long the maths took
);
  // ---------- memories (loaded from text files) ----------
  reg [7:0]  prog [0:63];          // the program
  reg [31:0] wmem [0:15];          // weights: shelf k = {lane3, lane2, lane1, lane0}
  reg [7:0]  x    [0:15];          // the input
  initial begin
    $readmemh("program.hex", prog);
    $readmemh("weights16_wide.hex", wmem);
    $readmemh("x.hex", x);
  end

  // ---------- the scheduler ----------
  localparam HALT = 3'd0, CLR = 3'd1, MAC = 3'd2, SEND = 3'd3;
  localparam FETCH = 0, EXEC = 1, LOADW = 2, DOMAC = 3, PRINT = 4, STOP = 5;
  reg  [2:0]  st = FETCH;
  reg  [7:0]  ir = 0;              // the instruction being run
  reg  [31:0] w4 = 0;              // the weights that just arrived
  reg  [7:0]  xk = 0;
  reg  [15:0] acc [0:3];
  reg         go = 0, counting = 0;
  wire        pbusy;
  wire [2:0]  op = ir[7:5];
  wire [4:0]  k  = ir[4:0];
  integer i;
  initial for (i = 0; i < 4; i = i + 1) acc[i] = 0;

  always @(posedge clk) begin
    go <= 0;
    if (counting) cycles <= cycles + 1;
    if (rst) begin pc <= 0; st <= FETCH; done <= 0; cycles <= 0; counting <= 1; end
    else case (st)
      FETCH: begin ir <= prog[pc]; pc <= pc + 1; st <= EXEC; end
      EXEC:  case (op)
               CLR:  begin for (i = 0; i < 4; i = i + 1) acc[i] <= 0; st <= FETCH; end
               MAC:  begin w4 <= wmem[k[3:0]]; xk <= x[k[3:0]]; st <= DOMAC; end   // LOAD
               SEND: begin counting <= 0; go <= 1; st <= PRINT; end
               default: begin counting <= 0; done <= 1; st <= STOP; end          // HALT
             endcase
      DOMAC: begin for (i = 0; i < 4; i = i + 1) acc[i] <= acc[i] + w4[8*i +: 8]*xk; st <= FETCH; end
      PRINT: if (!go && !pbusy) st <= FETCH;
      STOP:  ;
    endcase
  end
  assign y = {acc[3], acc[2], acc[1], acc[0]};

  printer #(.DIV(DIV)) p (.clk(clk), .go(go), .y(y), .tx(tx), .busy(pbusy));
endmodule
