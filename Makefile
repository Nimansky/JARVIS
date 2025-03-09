all: alu_tb regfile_tb instr_fetch_tb instr_decode_tb

alu_tb: build_alu_tb run_alu_tb

build_alu_tb: 
	verilator tests/alu_tb.v --timing --binary -j 0 --trace

run_alu_tb: 
	obj_dir/Valu_tb

regfile_tb: build_regfile_tb run_regfile_tb

build_regfile_tb:
	verilator tests/regfile_tb.v --timing --binary -j 0 --trace

run_regfile_tb:
	obj_dir/Vregfile_tb

instr_fetch_tb: build_instr_fetch_tb run_instr_fetch_tb

build_instr_fetch_tb:
	verilator tests/instr_fetch_tb.v --timing --binary -j 0 --trace

run_instr_fetch_tb:
	obj_dir/Vinstr_fetch_tb

instr_decode_tb: build_instr_decode_tb run_instr_decode_tb

build_instr_decode_tb:
	verilator tests/instr_decode_tb.v --timing --binary -j 0 --trace

run_instr_decode_tb:
	obj_dir/Vinstr_decode_tb