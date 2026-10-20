# Build a GPU From Scratch

Code for the **LLM Guru** YouTube series where we build a tiny GPU in Verilog, one piece per episode.
Every folder is complete: copy it, run one command, and you should see exactly the output shown in its README.

| Episode | Folder | What you build |
| --- | --- | --- |
| 1 | [`ep1/`](ep1) | One core that adds or multiplies |
| 2 | [`ep2/`](ep2) | Four lanes, thread IDs, a scheduler, and a neural-network layer |

## Install (once)

You need Icarus Verilog, a free Verilog simulator.

- macOS: `brew install icarus-verilog`
- Ubuntu / Debian: `sudo apt install iverilog`
- Windows: install WSL (Ubuntu), then `sudo apt install iverilog` inside it

Check it works: `iverilog -V`

Each run also ends with a line like `tb.v:17: $finish called at 30000 (1ps)`. That's normal: it's the simulator saying the test finished.

Stuck? Open an issue with the command you ran and the error you got.
