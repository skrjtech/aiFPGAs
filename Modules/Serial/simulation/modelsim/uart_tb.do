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
vlog +define+SIMULATION                                     \
    -vlog01compat -work work                                \
    +incdir+../../../Serial                                 \
    ../../../Serial/SERIAL.v                                \
    ../../../Serial/source/counter.v                        \
    ../../../Serial/source/gen8bitdata.v                    \
    ../../../Serial/source/uart/uart.v                      \
    ../../../Serial/source/uart/transmit/transmit.v         \
    ../../../Serial/source/uart/transmit/transmitstate.v    \
    ../../../Serial/source/uart/transmit/transmitbaudrate.v \
    ../../../Serial/source/uart/recieve/recieve.v           \
    ../../../Serial/source/uart/recieve/recievestate.v      \
    ../../../Serial/source/uart/recieve/recievebaudrate.v   \
    ../../../Serial/simulation/modelsim/uart_tb.v           

# Invoke VSIM Simulator
vsim -L altera_mf_ver -c work.uart_tb

# Prepare Wave Display
add wave -divider TESTBENCH
add wave -hex sim:/uart_tb/clk
add wave -hex sim:/uart_tb/count
add wave -hex sim:/uart_tb/reset
add wave -hex sim:/uart_tb/sec1pos
add wave -hex sim:/uart_tb/sec1pos_cnt

# Prepare Wave Display
add wave -divider SERIAL
# add wave -hex sim:/uart_tb/uSERIAL/rx
add wave -hex sim:/uart_tb/uSERIAL/tx
# add wave -hex sim:/uart_tb/uSERIAL/leds

# Prepare Wave Display
add wave -divider TRANSMIT_STATE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitState/START
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitState/STATE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitState/NEXT_STATE

add wave -divider TRANSMIT_BAUDRATE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitBaudrate/BCNT
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitBaudrate/NUMCNT
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitBaudrate/BCLK
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmitBaudrate/BREAK

add wave -divider TRANSMIT
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmit/TXDATA
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmit/TXBUSY
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmit/TXDONE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmit/TX
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTransmit/senddata

# Logging all Signals in WLF file
log -r *

# Run Simulation until $stop or $finish
run -all