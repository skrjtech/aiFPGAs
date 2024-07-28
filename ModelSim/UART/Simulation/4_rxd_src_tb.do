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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.rxd_sink_tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/rxd_sink_tb/clock
add wave -bin sim:/rxd_sink_tb/reset

add wave -divider UartSource
add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/iFEN
add wave -hex sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/iFDATA
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/oTX
add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/oDONE
# add wave -hex sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/nstate
# add wave -hex sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/var_data
# add wave -uns sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/cnt
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/donepos
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/done
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/txdata
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/txstart
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/txbusy
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/txdone
# add wave -bin sim:/rxd_sink_tb/u_txd_src_tb/uUartSrc/tx

add wave -divider UartSink
add wave -uns sim:/rxd_sink_tb/uUartSink/cnt
add wave -bin sim:/rxd_sink_tb/uUartSink/donepos
add wave -hex sim:/rxd_sink_tb/uUartSink/reg_data
add wave -hex sim:/rxd_sink_tb/uUartSink/datao
add wave -bin sim:/rxd_sink_tb/uUartSink/recept
add wave -bin sim:/rxd_sink_tb/uUartSink/done

add wave -divider RecieveState
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveState/iSTART
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveState/nstate

add wave -divider RecieveBaudrate
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveBaudrate/numcnt
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveBaudrate/bcnt
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveBaudrate/oBCLK
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveBaudrate/bpos
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieveBaudrate/oBREAK

add wave -divider Recieve
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieve/iRX
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieve/data
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieve/rxdata
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieve/rxbusy
add wave -uns sim:/rxd_sink_tb/uUartSink/uRxD/uRecieve/rxdone

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all