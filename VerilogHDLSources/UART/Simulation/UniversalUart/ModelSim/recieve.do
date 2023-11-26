# Set Env Path Files
set env(DIR_RTL_TBCH) ../TestBench
set env(DIR_RTL_BODY) ../../..
set env(DIR_RTL_UART) ../../../../UART/Sources/uart
set env(DIR_RTL_UNIVERSAL_UART) ../../../../UART/Sources/universaluart

set env(LIBRARY_NAME) UniversalUart

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
vlog +define+UNIVERSAL -vlog01compat -work $env(LIBRARY_NAME)Work -f $env(DIR_RTL_TBCH)/flist.txt

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.tb -t 10us

# Add Wave
add wave -divider TESETBENCH
add wave -hex sim:/tb/*

add wave -divider TRANSMIT
add wave -hex sim:/tb/uTxd/*

add wave -divider RECIEVE
add wave -hex sim:/tb/uRxd/uRecieve/*

# add wave -divider TOP
# add wave -hex sim:/tb/uTop/tx
# add wave -hex sim:/tb/uTop/txdata
# add wave -hex sim:/tb/uTop/txstart
# add wave -hex sim:/tb/uTop/txbusy
# add wave -hex sim:/tb/uTop/txdone
# add wave -hex sim:/tb/uTop/rx
# add wave -hex sim:/tb/uTop/rxdata
# add wave -hex sim:/tb/uTop/rxbusy
# add wave -hex sim:/tb/uTop/rxdone

# add wave -divider UNIVERSAL_TRANSMIT
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/sendstart
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/senddata
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/senddone

# add wave -divider UNIVERSAL_TRANSMIT_TXD
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/STATUS
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/TXDATA
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/TXBUSY
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/TXDONE
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/BREAK
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/SENDDATA
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/SENDDONE
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTransmit/SENDSTART

# add wave -divider UNIVERSAL_TXD
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/STATE
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/START
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/BCLK
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/BREAK
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/TXDATA
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/TXBUSY
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/TXDONE
# add wave -hex sim:/tb/uTop/uUART/uUniTxd/uTxd/uTransmit/TX

# add wave -divider UNIVERSAL_RECIEVE
# add wave -hex sim:/tb/uTop2/uUART/uUniRxd/recvdata
# add wave -hex sim:/tb/uTop2/uUART/uUniRxd/recvdone

run 4000

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
# run -all