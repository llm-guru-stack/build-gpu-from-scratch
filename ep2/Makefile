# make v1   -> four cores, shared inputs (the bug)
# make v2   -> four lanes with thread IDs (the fix)
# make gpu  -> scheduler + MAC lanes running a neural-network layer
v1:
	iverilog -o v1_sim tb_v1.v gpu_v1.v core.v && vvp -n v1_sim
v2:
	iverilog -o v2_sim tb_v2.v gpu_v2.v core.v && vvp -n v2_sim
gpu:
	iverilog -o gpu_sim tb_gpu.v gpu.v core_mac.v && vvp -n gpu_sim
clean:
	rm -f *_sim *.vcd
.PHONY: v1 v2 gpu clean
