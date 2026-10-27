`timescale 1ns/1ps
// tb.v : runs the GPU and listens to its serial wire like your laptop would.
module tb;
  localparam DIV = 8;                       // fast serial for simulation (the board uses 234)
  reg clk = 0; always #18.5 clk = ~clk;     // 27 MHz, like the Tang Nano 9K
  reg rst = 1;
  wire done, tx; wire [63:0] y; wire [5:0] pc; wire [15:0] cycles;
  gpu #(.DIV(DIV)) g (.clk(clk), .rst(rst), .done(done), .tx(tx), .y(y), .pc(pc), .cycles(cycles));

  // a tiny serial receiver: decode tx back into characters
  integer b; reg [7:0] c;
  initial forever begin
    @(negedge tx);                          // start bit
    repeat (DIV + DIV/2) @(posedge clk);    // middle of bit 0
    for (b = 0; b < 8; b = b + 1) begin c[b] = tx; repeat (DIV) @(posedge clk); end
    if (c != 8'h0D) $write("%c", c);
  end

  initial begin
    repeat (2) @(posedge clk); rst = 0;
    $display("serial output:");
    wait (done);
    repeat (DIV*12) @(posedge clk);
    $display("maths took %0d clock ticks = %0d ns at 27 MHz", cycles, cycles*37);
    $finish;
  end
endmodule
