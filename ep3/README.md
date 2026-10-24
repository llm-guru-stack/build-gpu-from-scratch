# Episode 3: memory

Episode 2 cheated: the weights were baked into the chip. Here they move into a slow memory, the way real weights live in the VRAM chips around a GPU, and we measure what that does to our cores. Then we fix it twice.

Every run prints a timeline, one character per clock tick: `M` = the cores are doing maths, `.` = the cores are waiting for memory.

## Checkpoint 1: weights in memory (the shock)

```
make step1
```

```
timeline: ............................M............................M............................M.
  M = cores doing maths   . = cores waiting for memory
cores busy 3 of 88 ticks (3%)
y = [6, 5, 18, 140]
```

Same answer as episode 2, but 88 ticks instead of 4. `memory.v` answers one request at a time and each answer takes 4 ticks (`LAT`), and every lane asks for its own weight separately: 12 trips for 3 ticks of maths.

## The race: a 16-input layer, three designs

```
make race
```

```
cores busy 16 of 465 ticks (3%)      <- gpu_mem.v: one lane, one trip at a time
cores busy 16 of 129 ticks (12%)     <- gpu_wide.v: fix 1, coalescing
cores busy 16 of 23 ticks (69%)      <- gpu_prefetch.v: fix 2, prefetching
y = [136, 272, 408, 544]             (every design gets the same answer)
```

Run them one at a time with `make slow`, `make step2` and `make step3`.

The layer: lane L multiplies every input by L+1, and the inputs are 1, 2, ..., 16. Their sum is 136, so the answer is 136 × 1, 2, 3 and 4.

### Fix 1: coalescing (`memory_wide.v`, `gpu_wide.v`)

Store the data in the order the lanes read it. Each shelf now holds a 32-bit word with all four lanes' weights for the same input, side by side (`weights16_wide.hex`). One trip feeds every lane: 64 trips become 16.

### Fix 2: prefetching (`memory_pipe.v`, `gpu_prefetch.v`)

The memory still takes 4 ticks per trip, but it accepts a new request every tick, like crates on a conveyor belt. The scheduler keeps asking for the next weights while earlier ones are still travelling, and the cores do a MAC the moment each delivery lands. The only waiting left is the first trip. With more inputs, the cores get closer and closer to 100% busy.

## Files

| File | What it is |
| --- | --- |
| `memory.v` | slow memory, one request at a time, 8-bit shelves |
| `memory_wide.v` | the same, but 32-bit shelves (four weights per shelf) |
| `memory_pipe.v` | wide and pipelined: a new request every tick |
| `gpu_mem.v` | episode 2's GPU with a LOAD step per lane |
| `gpu_wide.v` | fix 1: one wide LOAD for all four lanes |
| `gpu_prefetch.v` | fix 2: keep asking while earlier loads are in flight |
| `core_mac.v` | episode 2's MAC core, unchanged |
| `tb.v` | one testbench for every design |
| `weights_tiny.hex`, `weights16.hex`, `weights16_wide.hex` | the weights, as plain text files |

## Challenge

Real memory is much slower than 4 ticks. In `gpu_mem.v`, `gpu_wide.v` and `gpu_prefetch.v`, change `.LAT(4)` to `.LAT(20)` and run `make race` again. Which design survives? Post your numbers in the comments.

## Coming in episode 4

A real program, a bigger layer, and taking the GPU off the simulator and onto an FPGA board.
