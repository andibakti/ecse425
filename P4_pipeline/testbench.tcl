proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    ;#add wave -position end sim:/cache_tb/dut/clock
# add wave -position end  sim:/proc/clk
# add wave -position end  sim:/proc/rst
# add wave -position end  sim:/proc/pc_adder_instance/override
# add wave -position end  sim:/proc/pc_adder_instance/pc
# add wave -position end  sim:/proc/pc_adder_instance/override_pc
# add wave -position end  sim:/proc/pc_adder_instance/output_add
# add wave -position end  sim:/proc/pc_instance/input
# add wave -position end  sim:/proc/pc_instance/reset
# add wave -position end  sim:/proc/pc_instance/output_pc
# add wave -position end  sim:/proc/instr_memory_instance/clock
# add wave -position end  sim:/proc/instr_memory_instance/writedata
# add wave -position end  sim:/proc/instr_memory_instance/address
# add wave -position end  sim:/proc/instr_memory_instance/memwrite
# add wave -position end  sim:/proc/instr_memory_instance/memread
# add wave -position end  sim:/proc/instr_memory_instance/readdata
# add wave -position end  sim:/proc/instr_memory_instance/waitrequest
# add wave -position end  sim:/proc/instr_memory_instance/ram_block
add wave -position end sim:/proc_tb/proc_instance/*
		}

# proc GenerateClock {} { 
#     force -deposit /proc/clock 0 0 ns, 1 0.5 ns -repeat 1 ns
# }

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
# GenerateClock

;# Run for 10'000 clock cycles
run 10ns
