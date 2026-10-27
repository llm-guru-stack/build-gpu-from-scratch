#!/usr/bin/env python3
"""asm.py : turn program.asm into program.hex for our GPU.

Instructions (one per line, # starts a comment):
  CLR          every lane: acc = 0
  MAC k        every lane: acc += w[k] * x[k]   (k = 0..31)
  MAC a..b     shorthand for MAC a, MAC a+1, ... MAC b
  SEND         print every lane's acc over the serial port
  HALT         stop
Encoding: 8 bits = 3-bit opcode + 5-bit argument.
"""
import sys
OPS = {"HALT": 0, "CLR": 1, "MAC": 2, "SEND": 3}
src = sys.argv[1] if len(sys.argv) > 1 else "program.asm"
out = sys.argv[2] if len(sys.argv) > 2 else "program.hex"
words = []
for n, line in enumerate(open(src), 1):
    line = line.split("#")[0].strip()
    if not line:
        continue
    parts = line.split()
    op = parts[0].upper()
    if op not in OPS:
        sys.exit(f"{src}:{n}: unknown instruction '{parts[0]}'")
    args = [0]
    if op == "MAC":
        if len(parts) != 2:
            sys.exit(f"{src}:{n}: MAC needs one argument, like MAC 3 or MAC 0..15")
        if ".." in parts[1]:
            a, b = (int(v) for v in parts[1].split(".."))
            args = list(range(a, b + 1))
        else:
            args = [int(parts[1])]
    for k in args:
        if not 0 <= k < 32:
            sys.exit(f"{src}:{n}: argument {k} must be 0..31")
        words.append((OPS[op] << 5) | k)
if len(words) > 64:
    sys.exit(f"program has {len(words)} instructions; the GPU holds 64")
count = len(words)
words += [0]*(64 - len(words))           # fill the rest with HALT
with open(out, "w") as f:
    for w in words:
        f.write(f"{w:02X}\n")
print(f"{src} -> {out}: {count} instructions")
