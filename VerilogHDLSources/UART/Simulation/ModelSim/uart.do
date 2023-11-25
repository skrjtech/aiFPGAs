# Set Env Path Files
set env(DIR_RTL_TBCH) ../TestBench
set env(DIR_RTL_BODY) ../..
set env(DIR_RTL_UART) ../../../UART/Sources/uart

# View Window
transcript on

# if Design Unit Exists, Delete the Design Unit from a Specified Library.
if {[file exists UartLib]} {
	vdel -lib UartLib -all
}

# Creat a Design Library
vlib UartLib

# Define a Mapping between a Logical Library Name and a Directory
vmap UartWork UartLib

# Compile HDL Source
vlog +define+UART -vlog01compat -work UartWork -f $env(DIR_RTL_TBCH)/flist.txt

vsim -L altera_mf_ver -c UartWork.tb -t 10us

# Add Wave
add wave -divider TESETBENCH
add wave -hex sim:/tb/clock
add wave -hex sim:/tb/reset

add wave -divider TRANSMIT_STATE
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmitState/STATE

add wave -divider TRANSMIT_BAUDRATE
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmitBaudrate/BCLK
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmitBaudrate/BREAK

add wave -divider TRANSMIT
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmit/TX
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmit/TXDATA
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmit/TXBUSY
add wave -hex sim:/tb/uTop/uUART/uTxd/uTransmit/TXDONE

add wave -divider RECIEVE_STATE
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieveState/STATE

add wave -divider RECIEVE_BAUDRATE
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieveBaudrate/BCLK
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieveBaudrate/BREAK

add wave -divider RECIEVE
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieve/RX
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieve/RXDATA
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieve/RXBUSY
add wave -hex sim:/tb/uTop/uUART/uRxd/uRecieve/RXDONE

run 500

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
# run -all