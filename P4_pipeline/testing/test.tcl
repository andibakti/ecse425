proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    ;#add wave -position end sim:/cache_tb/dut/clock
    add wave -position end  sim:/ex_alu_tb/a
	add wave -position end  sim:/ex_alu_tb/b
	add wave -position end  sim:/ex_alu_tb/signExtendImmediate
	add wave -position end  sim:/ex_alu_tb/sel
	add wave -position end  sim:/ex_alu_tb/zero
	add wave -position end  sim:/ex_alu_tb/result
	}

vlib work

;# Compile components if any
vcom ex_ALU.vhd
vcom ex_ALU_tb.vhd

;# Start simulation
vsim ex_ALU_tb

;# Generate a clock with 1ns period
;#force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 20 ns
run 10ns
