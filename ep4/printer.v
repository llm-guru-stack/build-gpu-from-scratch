// printer.v : turns four 16-bit numbers into text and sends it over serial:
//   "y = 136 272 408 544" + new line
module printer #(parameter DIV = 234) (
  input  wire        clk,
  input  wire        go,           // pulse to start printing
  input  wire [63:0] y,            // four lanes, 16 bits each
  output wire        tx,
  output wire        busy
);
  reg        start = 0;
  reg  [7:0] ch = 0;
  wire       ubusy;
  uart_tx #(.DIV(DIV)) u (.clk(clk), .start(start), .byte_in(ch), .tx(tx), .busy(ubusy));

  localparam IDLE = 0, HEAD = 1, NUM = 2, DIGIT = 3, NEXTD = 4, SEP = 5, CR = 6, LF = 7, EMIT = 8, WAITU = 9;
  reg  [3:0]  st = IDLE, ret = IDLE;
  reg  [1:0]  lane = 0;
  reg  [1:0]  hpos = 0;
  reg  [2:0]  di = 0;               // which digit: 10000s, 1000s, 100s, 10s, 1s
  reg  [15:0] v = 0;
  reg  [3:0]  dcount = 0;
  reg         started = 0;
  assign busy = (st != IDLE);
  wire [15:0] pow  = (di == 0) ? 16'd10000 : (di == 1) ? 16'd1000 : (di == 2) ? 16'd100 : (di == 3) ? 16'd10 : 16'd1;
  wire [7:0]  head = (hpos == 0) ? "y" : (hpos == 1) ? " " : (hpos == 2) ? "=" : " ";

  always @(posedge clk) begin
    start <= 0;
    case (st)
      IDLE:  if (go) begin hpos <= 0; lane <= 0; st <= HEAD; end
      HEAD:  begin ch <= head; ret <= (hpos == 3) ? NUM : HEAD; hpos <= hpos + 1; st <= EMIT; end
      NUM:   begin v <= y[16*lane +: 16]; di <= 0; dcount <= 0; started <= 0; st <= DIGIT; end
      DIGIT: if (v >= pow) begin v <= v - pow; dcount <= dcount + 1; end   // divide by subtracting
             else if (dcount != 0 || started || di == 4) begin            // skip leading zeros
               ch <= "0" + dcount; started <= 1; ret <= NEXTD; st <= EMIT;
             end else st <= NEXTD;
      NEXTD: begin dcount <= 0; if (di == 4) st <= SEP; else begin di <= di + 1; st <= DIGIT; end end
      SEP:   if (lane == 3) st <= CR; else begin ch <= " "; lane <= lane + 1; ret <= NUM; st <= EMIT; end
      CR:    begin ch <= 8'h0D; ret <= LF; st <= EMIT; end
      LF:    begin ch <= 8'h0A; ret <= IDLE; st <= EMIT; end
      EMIT:  begin start <= 1; st <= WAITU; end
      WAITU: if (!start && !ubusy) st <= ret;
      default: st <= IDLE;
    endcase
  end
endmodule
