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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/tb/clock
add wave -bin sim:/tb/reset

add wave -divider HostCPU
add wave -hex sim:/tb/u_cpu_uart_tx_tb/fdata
add wave -bin sim:/tb/u_cpu_uart_tx_tb/uUART/TX
add wave -hex sim:/tb/u_cpu_uart_tx_tb/uUartSrc/TXDATA
add wave -bin sim:/tb/u_cpu_uart_tx_tb/uUartSrc/DONE

add wave -bin sim:/tb/u_cpu_uart_tx_tb/uUartSrc/*

# add wave -divider UartController
# add wave -uns sim:/tb/u_uart_con_tb/address
# add wave -uns sim:/tb/u_uart_con_tb/w_addr
# add wave -hex sim:/tb/u_uart_con_tb/ram1

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all