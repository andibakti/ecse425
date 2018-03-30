proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    ;#add wave -position end sim:/cache_tb/dut/clock
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
vcom proc_tb.vhd

;# Start simulation
vsim proc_tb

;# Generate a clock with 1ns period
;#force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 10'000 clock cycles
run 10000ns
