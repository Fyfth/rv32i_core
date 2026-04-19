SV_FILES = ../rtl/rv32i_pkg.sv ../rtl/regfile.sv ../rtl/imem.sv ../rtl/dmem.sv \
           ../rtl/fetch.sv ../rtl/decode.sv ../rtl/alu_ctrl.sv ../rtl/alu.sv \
           ../rtl/execute.sv ../rtl/mem.sv ../rtl/hazard.sv ../rtl/forwarding.sv \
           ../rtl/core.sv ../rtl/bpu.sv ../tb/tb_core.sv	

sim:
	verilator --binary --timing --trace -Wno-UNOPTFLAT --assert -sv $(SV_FILES) --top-module tb_core -o sim_core
	./obj_dir/sim_core

wave:
	gtkwave obj_dir/tb_core.vcd