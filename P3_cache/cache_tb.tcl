proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/cache_tb/dut/clock
    add wave -position end sim:/cache_tb/dut/ram
    add wave -position end sim:/cache_tb/dut/ram_size
    add wave -position end sim:/cache_tb/dut/reset
    add wave -position end sim:/cache_tb/dut/rowFound
    add wave -position end sim:/cache_tb/dut/row
    add wave -position end -radix hexadecimal  sim:/cache_tb/dut/s_addr
    add wave -position end sim:/cache_tb/dut/s_read
    add wave -position end sim:/cache_tb/dut/s_write
    add wave -position end sim:/cache_tb/dut/s_readdata
    add wave -position end sim:/cache_tb/dut/s_writedata
    add wave -position end sim:/cache_tb/dut/s_waitrequest
    add wave -position end -radix hexadecimal sim:/cache_tb/dut/m_addr 
    add wave -position end sim:/cache_tb/dut/m_read
    add wave -position end sim:/cache_tb/dut/m_readdata
    add wave -position end sim:/cache_tb/dut/m_write
    add wave -position end sim:/cache_tb/dut/m_writedata
    add wave -position end sim:/cache_tb/dut/m_waitrequest
    add wave -position end sim:/cache_tb/dut/next_state
    add wave -position end sim:/cache_tb/dut/current_state
    add wave -position end sim:/cache_tb/dut/next_state_read
    add wave -position end sim:/cache_tb/dut/read_state
    add wave -position end sim:/cache_tb/dut/r_counter
    add wave -position end sim:/cache_tb/dut/next_state_write
    add wave -position end sim:/cache_tb/dut/write_state
    add wave -position end sim:/cache_tb/dut/w_counter
}

vlib work

;# Compile components if any
vcom cache.vhd
vcom memory.vhd
vcom memory_tb.vhd
vcom cache_tb.vhd

;# Start simulation
vsim cache_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# Run for 20 ns
run 100ns