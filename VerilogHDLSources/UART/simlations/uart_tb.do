# Echoing of Commands Executed in a Macro File
transcript on

# if Design Unit Exists, Delete the Design Unit from a Specified Library.
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}

# Creat a Design Library
vlib rtl_work

# Define a Mapping between a Logical Library Name and a Directory
vmap work rtl_work

# Compile HDL Source
vlog +define+SIMULATION                  \
    -vlog01compat -work work             \
    +incdir+../../../Serial              \
    ../../../Serial/SERIAL.v             \
    ../../../Serial/source/counter.v     \
    ../../../Serial/source/gen8bitdata.v \
    ../../../Serial/source/baudraterx.v  \
    ../../../Serial/source/baudratetx.v  \
    ../../../Serial/source/rxd.v         \
    ../../../Serial/source/txd.v         \
    ../../../Serial/source/uart.v        \
    ../../../Serial/simulation/modelsim/uart_tb.v

# Invoke VSIM Simulator
vsim -L altera_mf_ver -c work.uart_tb

# Prepare Wave Display
add wave -divider TESTBENCH
add wave -hex sim:/uart_tb/clk50
add wave -hex sim:/uart_tb/reset

add wave -divider SERIAL_DISPLAY
add wave -hex sim:/uart_tb/uSERIAL/sec1pos
add wave -hex sim:/uart_tb/uSERIAL/txdata
add wave -hex sim:/uart_tb/uSERIAL/txstart
add wave -hex sim:/uart_tb/uSERIAL/txbusy
add wave -hex sim:/uart_tb/uSERIAL/txdone

add wave -divider SERIAL_uTX_DISPLAY
add wave -hex sim:/uart_tb/uSERIAL/uTx/CLK
add wave -hex sim:/uart_tb/uSERIAL/uTx/RESET
add wave -hex sim:/uart_tb/uSERIAL/uTx/TXSTART
add wave -hex sim:/uart_tb/uSERIAL/uTx/CURR_STATE
add wave -hex sim:/uart_tb/uSERIAL/uTx/NEXT_STATE
add wave -hex sim:/uart_tb/uSERIAL/uTx/SENDDATA
add wave -hex sim:/uart_tb/uSERIAL/uTx/RCOUNT
add wave -hex sim:/uart_tb/uSERIAL/uTx/TXBUSY
add wave -hex sim:/uart_tb/uSERIAL/uTx/TXDONE


# Logging all Signals in WLF file
log -r *

# Run Simulation until $stop or $finish
run -all