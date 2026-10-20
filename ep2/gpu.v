// gpu.v : four lanes + a scheduler. Our first real (tiny) GPU.
// The scheduler holds a program, steps through it one instruction per tick,
// and sends the SAME instruction to all four lanes. Each lane uses its
// thread ID to pick its own numbers.
// The program computes y = W * x : one layer of a neural network,
// 4 neurons (one per lane), 3 inputs each.
module gpu (
  input  wire        clk,
  input  wire        rst,
  output wire        done,
  output wire [63:0] y            // four answers, one per lane
);
  localparam HALT = 2'd0, CLR = 2'd1, MAC = 2'd2;

  // ---------- the program (scheduler's instruction memory) ----------
  reg [1:0] prog [0:4];
  initial begin
    prog[0] = CLR;   // everyone: acc = 0
    prog[1] = MAC;   // everyone: acc += w * x   (input 0)
    prog[2] = MAC;   //                          (input 1)
    prog[3] = MAC;   //                          (input 2)
    prog[4] = HALT;  // stop
  end

  // ---------- the data, baked in for now (episode 3: real memory) ----------
  reg [7:0] x [0:2];           // the input, SAME for every lane
  reg [7:0] w [0:11];          // the weights, a DIFFERENT row per lane
  initial begin
    x[0] = 1;  x[1] = 2;  x[2] = 3;
    w[0] = 1;  w[1] = 1;  w[2] = 1;      // lane 0
    w[3] = 2;  w[4] = 0;  w[5] = 1;      // lane 1
    w[6] = 3;  w[7] = 3;  w[8] = 3;      // lane 2
    w[9] = 10; w[10] = 20; w[11] = 30;   // lane 3
  end

  // ---------- the scheduler: a program counter ----------
  reg  [2:0] pc;
  wire [1:0] op = prog[pc];
  wire [1:0] k  = pc[1:0] - 2'd1;  // which input this MAC step uses
  assign done = (op == HALT);
  always @(posedge clk)
    if (rst)        pc <= 0;
    else if (!done) pc <= pc + 1;

  // ---------- four lanes, one instruction ----------
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : lane
      core_mac c (.clk(clk), .op(rst ? 2'd0 : op),
                  .a(w[3*i + k]),    // thread ID i picks its own weight row
                  .b(x[k]),          // everyone shares the input
                  .acc(y[16*i +: 16]));
    end
  endgenerate
endmodule
