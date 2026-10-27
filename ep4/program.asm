# program.asm : one neural-network layer, y = W x, on 4 lanes
CLR            # every lane starts from zero
MAC 0..15      # multiply-accumulate all 16 inputs
SEND           # print the 4 answers over USB
HALT
