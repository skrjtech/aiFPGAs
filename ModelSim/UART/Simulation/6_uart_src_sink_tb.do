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

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.uart_src_sink_tb -t 1us

# Add Wave
add wave -divider TestBench
add wave -bin sim:/uart_src_sink_tb/clock
add wave -bin sim:/uart_src_sink_tb/reset

add wave -divider host_to_kernel
add wave -bin sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/tx
add wave -bin sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/txstart
add wave -hex sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/txbusy
add wave -hex sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/txdone
add wave -hex sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/txdata

add wave -bin sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/iFEN
add wave -hex sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/iFDATA
add wave -bin sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/oDONE
add wave -hex sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/var_data
add wave -uns sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/cnt
add wave -bin sim:/uart_src_sink_tb/u_host_to_kernel/uUartSrc/donepos

add wave -divider from_host_to_kernel
add wave -bin sim:/uart_src_sink_tb/u_from_host_to_kernel/rx
add wave -bin sim:/uart_src_sink_tb/u_from_host_to_kernel/uart_sink_recept
add wave -bin sim:/uart_src_sink_tb/u_from_host_to_kernel/uart_sink_done
add wave -hex sim:/uart_src_sink_tb/u_from_host_to_kernel/uUartSink/reg_data
add wave -hex sim:/uart_src_sink_tb/u_from_host_to_kernel/uart_sink_data

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all