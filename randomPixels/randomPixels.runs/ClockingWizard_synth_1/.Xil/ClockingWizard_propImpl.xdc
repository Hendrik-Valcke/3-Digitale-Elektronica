set_property SRC_FILE_INFO {cfile:d:/Data/VHDLprojects2020/randomPixels/randomPixels.srcs/sources_1/ip/ClockingWizard/ClockingWizard.xdc rfile:../../../randomPixels.srcs/sources_1/ip/ClockingWizard/ClockingWizard.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports SysClk100MHz]] 0.1
