# Set Env Path Files
set env(DIR_RTL_TBCH) ../TestBench
set env(DIR_RTL_INCL) ../../Sources

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
vlog -vlog01compat -work $env(LIBRARY_NAME)Work -f $env(DIR_RTL_TBCH)/flist.txt

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.tb

# Add Wave

# add wave -divider RESET
# add wave -uns sim:/tb/ufifo/RESET
# add wave -divider WRITE
# add wave -uns sim:/tb/ufifo/WCLK
# add wave -uns sim:/tb/ufifo/WE
# add wave -uns sim:/tb/ufifo/we
# add wave -uns sim:/tb/ufifo/DATAIN
# add wave -uns sim:/tb/ufifo/waddr
# add wave -uns sim:/tb/ufifo/wptr1
# add wave -uns sim:/tb/ufifo/rptr2
# add wave -uns sim:/tb/ufifo/rptr
# add wave -uns sim:/tb/ufifo/FULL
# 
# add wave -divider RESET
# add wave -uns sim:/tb/ufifo/RCLK
# add wave -uns sim:/tb/ufifo/RE
# add wave -uns sim:/tb/ufifo/re
# add wave -uns sim:/tb/ufifo/Q
# add wave -uns sim:/tb/ufifo/raddr
# add wave -uns sim:/tb/ufifo/rptr1
# add wave -uns sim:/tb/ufifo/wptr2
# add wave -uns sim:/tb/ufifo/wptr
# add wave -uns sim:/tb/ufifo/EMPTY
# add wave -divider MEM
# add wave -uns sim:/tb/ufifo/MEM

add wave -divider FIFO
add wave -uns sim:/tb/ufifo/*
add wave -uns sim:/tb/ufifo/uMem//mem

# run 500

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all