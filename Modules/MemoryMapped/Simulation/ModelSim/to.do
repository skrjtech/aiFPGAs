# Set Env Path Files
set env(DIR_RTL_TBCH) ../TestBench
set env(DIR_RTL_BODY) ../..
set env(DIR_RTL_SRC) ../../Source

set env(LIBRARY_NAME) FIFO

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
vlog -vlog01compat -work $env(LIBRARY_NAME)Work -f $env(DIR_RTL_TBCH)/inc.txt

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.tb -t 10us

# Add Wave
add wave -divider TestBench
add wave -hex sim:/tb/*
add wave -divider TXD
add wave -hex sim:/tb/task_uart_tx/*
add wave -divider RXD
add wave -hex sim:/tb/uTop/uRxd/*
add wave -divider FIFO_8to32Bit
add wave -hex sim:/tb/uTop/uFIFO_8to32/*
add wave -hex sim:/tb/uTop/uFIFO_8to32/mem
add wave -divider UARTCMD
add wave -hex sim:/tb/uTop/uUARTCMD/*

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all