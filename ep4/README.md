# Episode 4: a real program, on a real chip

Until now the program was baked into the hardware. Here the scheduler reads it from `program.hex`, so a new program needs no new hardware. Then the same Verilog goes onto a Sipeed Tang Nano 9K FPGA board.

## The instruction set

Four instructions, 8 bits each (3-bit opcode + 5-bit argument):

| Instruction | What every lane does |
| --- | --- |
| `CLR` | acc = 0 |
| `MAC k` | acc += w[k] × x[k] (weights from memory, x shared) |
| `SEND` | print all four accumulators over the serial port |
| `HALT` | stop |

Write programs in `program.asm`; `asm.py` turns them into `program.hex`. `MAC 0..15` is shorthand for sixteen MAC lines.

## Checkpoint 1: run a program

```
make sim
```

```
program.asm -> program.hex: 19 instructions
serial output:
y = 136 272 408 544
maths took 52 clock ticks = 1924 ns at 27 MHz
```

The testbench listens to the GPU's serial wire exactly like your laptop would, and decodes the characters.

## Checkpoint 2: change the program, not the chip

```
make half
```

```
program_half.asm -> program.hex: 11 instructions
serial output:
y = 36 72 108 144
maths took 28 clock ticks = 1036 ns at 27 MHz
```

Same hardware, different program: only the first 8 inputs (1 + 2 + … + 8 = 36).

## Checkpoint 3: put it on a Tang Nano 9K

You need the free open-source FPGA tools: Yosys, nextpnr-himbaechel (with the Gowin chip database from Apicula) and openFPGALoader. The easiest way to get all of them is the OSS CAD Suite: https://github.com/YosysHQ/oss-cad-suite-build

```
make board     # synthesise, place and route, pack -> top.fs
make flash     # send it to the board over USB
```

Then open a serial terminal on the board's USB port at **115200 baud** and press button **S1**. The LEDs count through the program, then all light up, and the terminal shows:

```
y = 136 272 408 544
```

What the tools report for this design (nextpnr 0.11, GW1NR-9):

| Resource | Used | Available |
| --- | --- | --- |
| LUT4 logic cells | 323 | 8,640 |
| Flip-flops | 171 | 6,480 |
| 9×9 hardware multipliers | 4 | 40 |
| Max clock | 170 MHz | (the board runs at 27 MHz) |

Pins (`tangnano9k.cst`) follow Sipeed's Tang Nano 9K examples: clock on pin 52, LEDs on 10, 11, 13, 14, 15, 16 (they light up when driven low), button S1 on pin 3, serial TX on pin 17.

Got a board? Film the LEDs and your terminal and post it in the comments.

## Files

| File | What it is |
| --- | --- |
| `gpu.v` | the programmable GPU: scheduler, 4 MAC lanes, memories |
| `printer.v`, `uart_tx.v` | turn the answers into text and send it over serial |
| `top.v`, `tangnano9k.cst` | the board wrapper and pin map |
| `tb.v` | simulation testbench with a serial decoder |
| `asm.py` | the assembler |
| `program.asm`, `program_half.asm` | two programs |
| `program.hex`, `weights16_wide.hex`, `x.hex` | the numbers the GPU loads |

## Challenge

Write a program that makes the lanes print exactly `y = 100 200 300 400`. Post your program in the comments.
