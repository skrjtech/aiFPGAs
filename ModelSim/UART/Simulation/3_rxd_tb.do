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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.rxd_tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/rxd_tb/clock
add wave -bin sim:/rxd_tb/reset

add wave -divider TransmitState
add wave -bin sim:/rxd_tb/u_txd_tb/uTransmitState/iSTART
add wave -hex sim:/rxd_tb/u_txd_tb/uTransmitState/nstate

add wave -divider TransmitBaudrate
add wave -uns sim:/rxd_tb/u_txd_tb/uTransmitBaudrate/numcnt
add wave -uns sim:/rxd_tb/u_txd_tb/uTransmitBaudrate/bcnt
add wave -bin sim:/rxd_tb/u_txd_tb/uTransmitBaudrate/oBCLK
add wave -bin sim:/rxd_tb/u_txd_tb/uTransmitBaudrate/oBREAK

add wave -divider Transmit
add wave -hex sim:/rxd_tb/u_txd_tb/uTransmit/oTX
add wave -hex sim:/rxd_tb/u_txd_tb/uTransmit/iTXDATA
add wave -hex sim:/rxd_tb/u_txd_tb/uTransmit/data
add wave -bin sim:/rxd_tb/u_txd_tb/uTransmit/iSTART
add wave -bin sim:/rxd_tb/u_txd_tb/uTransmit/txbusy
add wave -bin sim:/rxd_tb/u_txd_tb/uTransmit/txdone

add wave -divider RecieveState
add wave -bin sim:/rxd_tb/uRecieveState/iSTART
add wave -hex sim:/rxd_tb/uRecieveState/nstate

add wave -divider RecieveBaudrate
add wave -uns sim:/rxd_tb/uRecieveBaudrate/numcnt
add wave -uns sim:/rxd_tb/uRecieveBaudrate/bcnt
add wave -uns sim:/rxd_tb/uRecieveBaudrate/oBCLK
add wave -bin sim:/rxd_tb/uRecieveBaudrate/bpos
add wave -bin sim:/rxd_tb/uRecieveBaudrate/oBREAK

add wave -divider Recieve
add wave -bin sim:/rxd_tb/uRecieve/iRX
add wave -hex sim:/rxd_tb/uRecieve/data
add wave -hex sim:/rxd_tb/uRecieve/rxdata
add wave -bin sim:/rxd_tb/uRecieve/rxbusy
add wave -bin sim:/rxd_tb/uRecieve/rxdone

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all