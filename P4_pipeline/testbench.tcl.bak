proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    ;#add wave -position end sim:/cache_tb/dut/clock
    add wave -position end  sim:/proc_tb/proc_instance/clock
	add wave -position end  sim:/proc_tb/proc_instance/reset
	add wave -position end  sim:/proc_tb/proc_instance/sign_ext_instance/data_in
	add wave -position end  sim:/proc_tb/proc_instance/sign_ext_instance/data_out
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/write_en
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/writedata
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/addr_write
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/addr_regA
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/addr_regB
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/read_regA
	add wave -position end  sim:/proc_tb/proc_instance/register_file_instance/read_regB
	add wave -position end  sim:/proc_tb/proc_instance/pc_adder_instance/override
	add wave -position end  sim:/proc_tb/proc_instance/pc_adder_instance/pc
	add wave -position end  sim:/proc_tb/proc_instance/pc_adder_instance/override_pc
	add wave -position end  sim:/proc_tb/proc_instance/pc_adder_instance/output_add
	add wave -position end  sim:/proc_tb/proc_instance/pc_instance/output_pc
	add wave -position end  sim:/proc_tb/proc_instance/instr_memory_instance/writedata
	add wave -position end  sim:/proc_tb/proc_instance/instr_memory_instance/address
	add wave -position 19  sim:/proc_tb/proc_instance/id_reg_instance/pc_in
	add wave -position 20  sim:/proc_tb/proc_instance/id_reg_instance/instruction_in
	add wave -position 21  sim:/proc_tb/proc_instance/id_reg_instance/opCode_out
	add wave -position 22  sim:/proc_tb/proc_instance/id_reg_instance/reg1_out
	add wave -position 23  sim:/proc_tb/proc_instance/id_reg_instance/reg2_out
	add wave -position 24  sim:/proc_tb/proc_instance/id_reg_instance/reg_write_in
	add wave -position 25  sim:/proc_tb/proc_instance/id_reg_instance/address_out
	add wave -position 26  sim:/proc_tb/proc_instance/id_reg_instance/immediateValue_out
	add wave -position 27  sim:/proc_tb/proc_instance/id_reg_instance/shamt_out
	add wave -position 28  sim:/proc_tb/proc_instance/id_reg_instance/funct_out
	add wave -position 29  sim:/proc_tb/proc_instance/id_reg_instance/reg_write_out
	add wave -position 30  sim:/proc_tb/proc_instance/id_reg_instance/pc_out
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/a
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/b
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/address_in
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/offset_in
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/shift_in
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/signExtendImmediate
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/uSignExtendImmediate
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/sel
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/funct
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/pc_in
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/regWrite_in
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/jump
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/mem
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/load
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/store
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/jumpAddress
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/memAddress
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/regWrite_out
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/result
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/temp
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/jA
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/memAddr
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/hi
	add wave -position end  sim:/proc_tb/proc_instance/ex_alu_instance/lo
		}

vlib work

;# Compile components if any
vcom USign_Ext.vhd
vcom Sign_Ext.vhd
vcom Register_File.vhd
vcom PC_adder.vhd
vcom PC.vhd
vcom mux_2to1.vhd
vcom instr_memory.vhd
vcom id_reg.vhd
vcom hazard_Detection.vhd
vcom ex_ALU.vhd
vcom data_memory.vhd
vcom proc.vhd
vcom proc_tb.vhd

;# Start simulation
vsim proc_tb

;# Generate a clock with 1ns period
;#force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 10'000 clock cycles
run 10ns
