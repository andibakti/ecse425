proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    ;#add wave -position end sim:/cache_tb/dut/clock
    add wave -position end  sim:/data_memory_tb/clk
	add wave -position end  sim:/data_memory_tb/data_in
	add wave -position end  sim:/data_memory_tb/data_out
	add wave -position end  sim:/data_memory_tb/addr
	add wave -position end  sim:/data_memory_tb/reg_id_in
	add wave -position end  sim:/data_memory_tb/reg_id_out
	#add wave -position end  sim:/data_memory_tb/output
	}

vlib work

;# Compile components if any
vcom data_memory.vhd
vcom data_memory_tb.vhd

;# Start simulation
vsim data_memory_tb

;# Generate a clock with 1ns period
;#force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 20 ns
#bp data_memory.vhd 43
run 10ns
