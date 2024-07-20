
# run_testbenches.tcl

# Set Env Path Files
set env(DIR_RTL_INCL) ../../Sources
set env(DIR_RTL_BODY) ../..
set env(DIR_RTL_TBCH) ../TestBench

set verilogfiles [glob -nocomplain -directory $env(DIR_RTL_INCL) *.v]
if {[llength $verilogfiles] == 0} {
	puts "No Verilog files found in $env(DIR_RTL_INCL)"
	exit 1
}

set env(LIBRARY_NAME) NeuronModel

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

foreach file $verilogfiles {
	vlog -vlog01compat -work $env(LIBRARY_NAME)Work $file
}

# Compile HDL Source
vlog -vlog01compat -work $env(LIBRARY_NAME)Work -f $env(DIR_RTL_TBCH)/flist.txt

# Add Wave

# vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.tb -t 1us
# add wave -divider TestBench
# add wave -bin sim:/tb/clock
# add wave -divider SingleCore
# add wave -bin sim:/tb/neuron/START
# add wave -bin sim:/tb/neuron/STREAM_A
# add wave -bin sim:/tb/neuron/STREAM_B
# add wave -bin sim:/tb/neuron/STREAM_O

# vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.single_neuron_tb -t 1us
# add wave -divider NeuronCore
# add wave -bin sim:/single_neuron_tb/singel_neuron_core/START
# add wave -bin sim:/single_neuron_tb/singel_neuron_core/STREAM_A
# add wave -bin sim:/single_neuron_tb/singel_neuron_core/STREAM_B
# add wave -bin sim:/single_neuron_tb/singel_neuron_core/STREAM_O

# vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.single_core_tb -t 1us
# add wave -divider MatrixSingleCore
# add wave -bin sim:/single_core_tb/singel_core/START
# add wave -bin sim:/single_core_tb/singel_core/STREAM_A
# add wave -bin sim:/single_core_tb/singel_core/STREAM_B
# add wave -bin sim:/single_core_tb/singel_core/STREAM_O

vsim -L altera_mf_ver -c $env(LIBRARY_NAME)Work.single_neuron_core_tb -t 1us
add wave -divider TestBench
add wave -bin sim:/single_neuron_core_tb/clock
add wave -bin sim:/single_neuron_core_tb/reset
add wave -divider BRAM
add wave -bin sim:/single_neuron_core_tb/dbram/MEM
add wave -bin sim:/single_neuron_core_tb/dbram/WE_PORT_A
add wave -bin sim:/single_neuron_core_tb/dbram/ADDR_PORT_A
add wave -bin sim:/single_neuron_core_tb/dbram/DATAI_PORT_A
add wave -bin sim:/single_neuron_core_tb/dbram/DATAO_PORT_A
add wave -bin sim:/single_neuron_core_tb/dbram/WE_PORT_B
add wave -bin sim:/single_neuron_core_tb/dbram/ADDR_PORT_B
add wave -bin sim:/single_neuron_core_tb/dbram/DATAI_PORT_B
add wave -bin sim:/single_neuron_core_tb/dbram/DATAO_PORT_B
add wave -divider STREAM_A
add wave -bin sim:/single_neuron_core_tb/stream_a/EN
add wave -bin sim:/single_neuron_core_tb/stream_a/START
add wave -bin sim:/single_neuron_core_tb/stream_a/LIMIT
add wave -bin sim:/single_neuron_core_tb/stream_a/ADDR
add wave -bin sim:/single_neuron_core_tb/stream_a/DATAI
add wave -bin sim:/single_neuron_core_tb/stream_a/DATAO
add wave -bin sim:/single_neuron_core_tb/stream_a/DONE
add wave -divider STREAM_B
add wave -bin sim:/single_neuron_core_tb/stream_b/EN
add wave -bin sim:/single_neuron_core_tb/stream_b/START
add wave -bin sim:/single_neuron_core_tb/stream_b/LIMIT
add wave -bin sim:/single_neuron_core_tb/stream_b/ADDR
add wave -bin sim:/single_neuron_core_tb/stream_b/DATAI
add wave -bin sim:/single_neuron_core_tb/stream_b/DATAO
add wave -bin sim:/single_neuron_core_tb/stream_b/DONE
add wave -divider neuron
add wave -bin sim:/single_neuron_core_tb/neuron/START
add wave -bin sim:/single_neuron_core_tb/neuron/STREAM_A
add wave -bin sim:/single_neuron_core_tb/neuron/STREAM_B
add wave -bin sim:/single_neuron_core_tb/neuron/STREAM_O

# run 1

# Logging all Signals in WLF file
# log -r *

# Run Simulation until $stop or $finish
run -all