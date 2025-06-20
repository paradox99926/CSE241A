
set sdc_version 2.0

set_units -capacitance 1fF
set_units -time 1ps

# Set the current design
current_design mpeg2_top

create_clock -name "clk" -period 200.0 -waveform {0.0 100.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"

