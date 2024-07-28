# Set Env Path Files
set env(DIR_RTL_INCL) ../../../VerilogHDL
set env(DIR_RTL_TBCH) ../TestBench
set env(DIR_RTL_BODY) ..

set env(LIBRARY_NAME) Uart

# View Window
transcript on

# if Design Unit Exists, Delete the Design Unit from a Specified Library.
if {[file exists $env(LIBRARY_NAME)]} {
	vdel -lib $env(LIBRARY_NAME)Lib -all
}

# Creat a Design Library
vlib $env(LIBRARY_NAME)Lib

# Define a Mapping between a Logical Library Name and a Directory
vmap $env(LIBRARY_NAME)Work $env(LIBRARY_NAME)Lib

# Compile HDL Source
vlog -vlog01compat -work $env(LIBRARY_NAME)Work -f $env(DIR_RTL_TBCH)/_flist.txt

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.uart_tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/uart_tb/clock
add wave -bin sim:/uart_tb/reset

add wave -divider TransmitState
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmitState/START
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmitState/STATE
add wave -divider TransmitBaudrate
add wave -uns sim:/uart_tb/u_txd_tb/uTxD/uTransmitBaudrate/numcnt
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmitBaudrate/BCLK
add wave -uns sim:/uart_tb/u_txd_tb/uTxD/uTransmitBaudrate/bcnt
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmitBaudrate/BREAK
add wave -divider TxD
add wave -hex sim:/uart_tb/u_txd_tb/uTxD/uTransmit/TXDATA
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmit/TXBUSY
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmit/TXDONE
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmit/TX
add wave -bin sim:/uart_tb/u_txd_tb/uTxD/uTransmit/data

add wave -divider RecieveState
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieveState/START
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieveState/STATE
add wave -divider RecieveBaudrate
add wave -uns sim:/uart_tb/u_rxd_tb/uRxD/uRecieveBaudrate/numcnt
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieveBaudrate/BCLK
add wave -uns sim:/uart_tb/u_rxd_tb/uRxD/uRecieveBaudrate/bcnt
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieveBaudrate/BREAK
add wave -divider RxD
add wave -hex sim:/uart_tb/u_rxd_tb/uRxD/uRecieve/RXDATA
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieve/RXBUSY
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieve/RXDONE
add wave -bin sim:/uart_tb/u_rxd_tb/uRxD/uRecieve/RX

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all