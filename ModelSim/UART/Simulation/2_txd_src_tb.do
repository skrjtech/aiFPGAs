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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.txd_src_tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/txd_src_tb/clock
add wave -bin sim:/txd_src_tb/reset


# add wave -hex sim:/txd_src_tb/u_uart_src_tb/*



add wave -divider UartSource
add wave -hex sim:/txd_src_tb/uUartSrc/*
add wave -divider TransmitState
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmitState/iSTART
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmitState/nstate
add wave -divider TransmitBaudrate
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmitBaudrate/numcnt
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmitBaudrate/bcnt
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmitBaudrate/oBCLK
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmitBaudrate/oBREAK
add wave -divider Transmit
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmit/oTX
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmit/iTXDATA
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmit/data
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmit/iSTART
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmit/txbusy
add wave -hex sim:/txd_src_tb/uUartSrc/uTxD/uTransmit/txdone

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all