// uart_tx.v : sends one byte over a serial wire (8 data bits, no parity, 1 stop bit).
// DIV = clock ticks per bit. 27 MHz / 115200 baud = 234.
module uart_tx #(parameter DIV = 234) (
  input  wire       clk,
  input  wire       start,        // pulse: send this byte
  input  wire [7:0] byte_in,
  output reg        tx = 1,       // the wire (idles high)
  output wire       busy
);
  reg [9:0]  frame = 10'h3FF;     // stop bit, 8 data bits, start bit
  reg [3:0]  bits = 0;
  reg [15:0] cnt  = 0;
  assign busy = (bits != 0);
  always @(posedge clk) begin
    if (!busy) begin
      if (start) begin frame <= {1'b1, byte_in, 1'b0}; bits <= 10; cnt <= 0; end
    end else if (cnt == DIV - 1) begin
      cnt <= 0; tx <= frame[0]; frame <= {1'b1, frame[9:1]}; bits <= bits - 1;
    end else cnt <= cnt + 1;
  end
endmodule
