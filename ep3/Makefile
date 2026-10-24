# make step1  -> episode 2's layer with the weights in memory (the shock)
# make race   -> a 16-input layer, all three designs, one after another
# make step2  -> fix 1: coalescing          make step3 -> fix 2: prefetching
SRC = core_mac.v memory.v memory_wide.v memory_pipe.v gpu_mem.v gpu_wide.v gpu_prefetch.v tb.v
step1:
	iverilog -DDESIGN=gpu_mem -DN=3 -DFILE='"weights_tiny.hex"' -o s1_sim $(SRC) && vvp -n s1_sim
slow:
	iverilog -DDESIGN=gpu_mem -DN=16 -DFILE='"weights16.hex"' -o s0_sim $(SRC) && vvp -n s0_sim
step2:
	iverilog -DDESIGN=gpu_wide -DN=16 -DFILE='"weights16_wide.hex"' -o s2_sim $(SRC) && vvp -n s2_sim
step3:
	iverilog -DDESIGN=gpu_prefetch -DN=16 -DFILE='"weights16_wide.hex"' -o s3_sim $(SRC) && vvp -n s3_sim
race: slow step2 step3
clean:
	rm -f *_sim
.PHONY: step1 slow step2 step3 race clean
