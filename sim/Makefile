SV_FILES = ../rtl/decode.sv ../tb/tb_decode.sv

sim:
	verilator --binary --timing --trace --assert -sv $(SV_FILES) --top-module tb_decode -o sim_decode
	./obj_dir/sim_decode

wave:
	gtkwave obj_dir/tb_decode.vcd