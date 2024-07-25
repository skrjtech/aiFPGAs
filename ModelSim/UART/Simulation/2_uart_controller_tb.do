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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.uart_controller_tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/uart_controller_tb/clock
add wave -bin sim:/uart_controller_tb/reset
add wave -bin sim:/uart_controller_tb/ip
add wave -bin sim:/uart_controller_tb/op

add wave -divider HostCompute
add wave -bin sim:/uart_controller_tb/tx
add wave -bin sim:/uart_controller_tb/hostStart
add wave -hex sim:/uart_controller_tb/hostData
add wave -bin sim:/uart_controller_tb/txdone

add wave -divider KernelSource

add wave -bin sim:/uart_controller_tb/uKernel/uUartSrc/iFEN
add wave -hex sim:/uart_controller_tb/uKernel/uUartSrc/iFDATA
add wave -bin sim:/uart_controller_tb/uKernel/uUartSrc/oTX
add wave -bin sim:/uart_controller_tb/uKernel/uUartSrc/oDONE

add wave -divider KernelSource
add wave -bin sim:/uart_controller_tb/uKernel/uUartSink/iRX
add wave -bin sim:/uart_controller_tb/uKernel/uUartSink/oRECEPT
add wave -bin sim:/uart_controller_tb/uKernel/uUartSink/oDONE
add wave -hex sim:/uart_controller_tb/uKernel/uUartSink/oFDATA

add wave -divider KernelMEM
add wave -bin sim:/uart_controller_tb/uKernel/mem_req
add wave -uns sim:/uart_controller_tb/uKernel/address
add wave -hex sim:/uart_controller_tb/uKernel/odatas
add wave -hex sim:/uart_controller_tb/uKernel/idatas
add wave -hex sim:/uart_controller_tb/uKernel/RAM1
add wave -hex sim:/uart_controller_tb/uKernel/RAM2

add wave -divider uUartCon
add wave -hex sim:/uart_controller_tb/uKernel/uUartCon/latchdata
add wave -uns sim:/uart_controller_tb/uKernel/uUartCon/opecode
add wave -uns sim:/uart_controller_tb/uKernel/uUartCon/address
add wave -hex sim:/uart_controller_tb/uKernel/uUartCon/datas
add wave -hex sim:/uart_controller_tb/uKernel/uUartCon/state

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all