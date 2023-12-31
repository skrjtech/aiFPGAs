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
# add wave -divider SERIAL
# add wave -hex sim:/uart_tb/uSERIAL/rx
# add wave -hex sim:/uart_tb/uSERIAL/tx
add wave -hex sim:/uart_tb/uSERIAL/leds

# Prepare Wave Display
add wave -divider TRANSMIT_STATE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmitState/START
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmitState/STATE

add wave -divider TRANSMIT_BAUDRATE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmitBaudrate/BCNT
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmitBaudrate/BCLK
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmitBaudrate/NUMCNT
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmitBaudrate/BREAK

add wave -divider TRANSMIT
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmit/TXDATA
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmit/TXBUSY
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmit/TXDONE
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmit/TX
add wave -hex sim:/uart_tb/uSERIAL/uUART/uTxd/uTransmit/senddata

# add wave -divider RECIEVE_STATE
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveState/START
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveState/STATE
# 
# add wave -divider RECIEVE_BAUDRATE
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveBaudrate/BCNT
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveBaudrate/BCLK
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveBaudrate/BPOS
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveBaudrate/NUMCNT
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieveBaudrate/BREAK
# 
# add wave -divider RECIEVE
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieve/RXDATA
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieve/RXBUSY
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieve/RXDONE
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieve/RX
# add wave -hex sim:/uart_tb/uSERIAL/uUART/uRxd/uRecieve/recvdata

# Logging all Signals in WLF file
log -r *

# Run Simulation until $stop or $finish
run -all