set_global_assignment -entity "STSource" -library "lib_STSource" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "STSource" -library "lib_STSource" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "STSource" -library "lib_STSource" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_STSource" -name SPD_FILE [file join $::quartus(sip_path) "../STSource.spd"]
set_global_assignment -library "lib_STSource" -name MISC_FILE [file join $::quartus(sip_path) "../../STSource.qsys"]

set_global_assignment -library "lib_STSource" -name MISC_FILE [file join $::quartus(sip_path) "STSource.v"]
set_global_assignment -library "lib_STSource" -name MISC_FILE [file join $::quartus(sip_path) "submodules/verbosity_pkg.sv"]
set_global_assignment -library "lib_STSource" -name MISC_FILE [file join $::quartus(sip_path) "submodules/avalon_utilities_pkg.sv"]
set_global_assignment -library "lib_STSource" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_avalon_st_source_bfm.sv"]
