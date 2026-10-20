# Episode 2: make it parallel

Three checkpoints. Run each one and compare with the expected output.
(No `make`? Copy the two commands under each step instead.)

## Checkpoint 1: four cores, one bug

```
make v1
# or: iverilog -o v1_sim tb_v1.v gpu_v1.v core.v && vvp -n v1_sim
```

```
core 0: 7
core 1: 7
core 2: 7
core 3: 7
```

All four cores got the same `a` and `b`, so they did the same work four times.

## Checkpoint 2: lanes with thread IDs

```
make v2
# or: iverilog -o v2_sim tb_v2.v gpu_v2.v core.v && vvp -n v2_sim
```

```
core 0: 12
core 1: 30
core 2: 56
core 3: 40000
```

One instruction (multiply), four different answers, one clock tick.
`a[8*i +: 8]` means "the 8 bits starting at bit 8*i": core `i` reads slot `i`. The loop counter `i` is the core's **thread ID**, the same idea as `threadIdx.x` in CUDA.

## Checkpoint 3: a scheduler running a neural-network layer

```
make gpu
# or: iverilog -o gpu_sim tb_gpu.v gpu.v core_mac.v && vvp -n gpu_sim
```

```
tick 0  pc=1  lanes: 0 0 0 0
tick 1  pc=2  lanes: 1 2 3 10
tick 2  pc=3  lanes: 3 2 9 50
tick 3  pc=4  lanes: 6 5 18 140
done in 4 ticks
y = [6, 5, 18, 140]
```

`gpu.v` holds a 5-instruction program (CLR, MAC, MAC, MAC, HALT). The scheduler's program counter `pc` steps through it and sends each instruction to all four lanes. Each lane multiplies its own row of weights `w` by the shared input `x` and accumulates: that's `y = W · x`, one layer of a neural network with 4 neurons and 3 inputs.

Check lane 3 by hand: 10×1 + 20×2 + 30×3 = 140.

## Files

| File | What it is |
| --- | --- |
| `core.v` | Episode 1's core (add or multiply) |
| `gpu_v1.v`, `tb_v1.v` | Four cores sharing inputs (the bug) |
| `gpu_v2.v`, `tb_v2.v` | Four lanes, each with its own data |
| `core_mac.v` | The core with an accumulator: `acc <= acc + a*b` (MAC) |
| `gpu.v`, `tb_gpu.v` | Scheduler + four MAC lanes + a baked-in program and data |

## Challenge

Make it **eight** lanes. You'll need to change the loop limit, widen `y`, and add four more weight rows. Your new lanes 4 to 7 can compute anything you like. Post your output in the comments.

## Coming in episode 3

Right now the weights are baked into the chip. Real models have billions of them, stored in memory. Next episode: why your cores spend most of their time waiting for memory, and how to feed them.
