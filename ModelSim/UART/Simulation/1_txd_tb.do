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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.txd_tb -t 10us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/txd_tb/clock
add wave -bin sim:/txd_tb/reset

add wave -divider TransmitState
add wave -bin sim:/txd_tb/uTransmitState/iSTART
add wave -hex sim:/txd_tb/uTransmitState/nstate
add wave -divider TransmitBaudrate
add wave -uns sim:/txd_tb/uTransmitBaudrate/numcnt
add wave -uns sim:/txd_tb/uTransmitBaudrate/bcnt
add wave -bin sim:/txd_tb/uTransmitBaudrate/oBCLK
add wave -bin sim:/txd_tb/uTransmitBaudrate/oBREAK
add wave -divider Transmit
add wave -hex sim:/txd_tb/uTransmit/oTX
add wave -hex sim:/txd_tb/uTransmit/iTXDATA
add wave -hex sim:/txd_tb/uTransmit/data
add wave -bin sim:/txd_tb/uTransmit/iSTART
add wave -bin sim:/txd_tb/uTransmit/txbusy
add wave -bin sim:/txd_tb/uTransmit/txdone

# add wave -divider TransmitState
# add wave -bin sim:/txd_tb/uTxD/uTransmitState/iSTART
# add wave -hex sim:/txd_tb/uTxD/uTransmitState/nstate
# add wave -hex sim:/txd_tb/uTxD/uTransmitState/*
# add wave -divider TransmitBaudrate
# add wave -uns sim:/txd_tb/uTxD/uTransmitBaudrate/numcnt
# add wave -uns sim:/txd_tb/uTxD/uTransmitBaudrate/bcnt
# add wave -bin sim:/txd_tb/uTxD/uTransmitBaudrate/oBCLK
# add wave -bin sim:/txd_tb/uTxD/uTransmitBaudrate/oBREAK
# add wave -bin sim:/txd_tb/uTxD/uTransmitBaudrate/*
# add wave -divider Transmit
# add wave -hex sim:/txd_tb/uTxD/uTransmit/oTX
# add wave -hex sim:/txd_tb/uTxD/uTransmit/iTXDATA
# add wave -hex sim:/txd_tb/uTxD/uTransmit/data
# add wave -bin sim:/txd_tb/uTxD/uTransmit/iSTART
# add wave -bin sim:/txd_tb/uTxD/uTransmit/txbusy
# add wave -bin sim:/txd_tb/uTxD/uTransmit/txdone
# add wave -bin sim:/txd_tb/uTxD/uTransmit/*

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all