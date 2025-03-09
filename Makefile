all: build_alu_tb run_alu_tb

build_alu_tb: 
	verilator tests/alu_tb.v --timing --binary -j 0 --trace

run_alu_tb: 
	obj_dir/Valu_tb