// top.v : our GPU on a Sipeed Tang Nano 9K.
// Runs the program at power-up and again every time you press button S1.
// The answer is printed over the USB cable (115200 baud); the LEDs show the
// program counter while it runs and all light up when it's done.
module top (
  input  wire       clk,          // 27 MHz crystal on the board
  input  wire       btn1,         // button S1 (reads 0 when pressed)
  output wire       uart_tx,      // to the board's USB-serial chip
  output wire [5:0] led           // on-board LEDs (light up when driven 0)
);
  // power-on reset + button restart
  reg [7:0] por = 0; reg [1:0] bsync = 2'b11; reg rst = 1;
  always @(posedge clk) begin
    bsync <= {bsync[0], btn1};
    if (por != 8'hFF) por <= por + 1;
    rst <= (por != 8'hFF) || (bsync[1] == 1'b0);
  end
  wire done; wire [5:0] pc; wire [63:0] y; wire [15:0] cycles;
  gpu #(.DIV(234)) g (.clk(clk), .rst(rst), .done(done), .tx(uart_tx), .y(y), .pc(pc), .cycles(cycles));
  assign led = done ? 6'b000000 : ~pc;   // active-low LEDs: 0 = on
endmodule
