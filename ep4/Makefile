# make sim      -> assemble program.asm and run it in the simulator
# make half     -> run program_half.asm instead (same chip, new program)
# make board    -> build top.fs for the Tang Nano 9K (needs yosys + nextpnr-himbaechel + apycula)
# make flash    -> send it to the board (needs openFPGALoader)
SRC = gpu.v printer.v uart_tx.v
sim:
	python3 asm.py program.asm program.hex && iverilog -o sim tb.v $(SRC) && vvp -n sim
half:
	python3 asm.py program_half.asm program.hex && iverilog -o sim tb.v $(SRC) && vvp -n sim
board:
	python3 asm.py program.asm program.hex
	yosys -q -p "read_verilog top.v $(SRC); synth_gowin -top top -json top.json"
	nextpnr-himbaechel --json top.json --write pnr.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst --freq 27
	gowin_pack -d GW1N-9C -o top.fs pnr.json
flash:
	openFPGALoader -b tangnano9k top.fs
clean:
	rm -f sim top.json pnr.json top.fs
.PHONY: sim half board flash clean
