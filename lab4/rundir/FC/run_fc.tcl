set design jpeg_encoder

if {![file exists fc_report]} {
	exec mkdir fc_report
}

if {[file exists $design]} {
	exec chmod -R 777 $design
	exec rm -r $design
}

# read lib
set home "/home/linux/ieng6/cs241asp25/public/data/libraries"
set search_path ". $home"
set target_library "$home/db/tcbn65gpluswc.db"
set link_library "* $target_library"
set techfile "$home/techfiles/tsmcn65_8lmT2.tf"
set tech_info "{M1 vertical 0.0} {M2 horizontal 0.0} {M3 vertical 0.0} {M4 horizontal 0.0} {M5 vertical 0.0} {M6 horizontal 0.0} {M7 vertical 0.0} {M8 horizontal 0.0} {CB vertical 0.0}"
set ndm "./ndm/tsmc65.ndm"

set tlup "$home/techfiles/cln65g+_1p08m+alrdl_top2_cworst.tluplus"
set tech2itf_map "$home/techfiles/star.map_8M"

create_lib $design -tech $techfile -ref_libs $ndm

read_verilog -top $design "../../gate/$design\.v"
current_block $design
link_block
save_lib

load_upf ${design}.upf
commit_upf
set_voltage 0.90 -object_list [get_supply_nets VDD]
set_voltage 0.00 -object_list [get_supply_nets VSS]
connect_pg_net -automatic 
read_parasitic_tech -tlup $tlup -layermap $tech2itf_map -name wst

#scenario
remove_modes -all; remove_corners -all; remove_scenarios -all
set s "WC"
create_mode $s
create_corner $s
create_scenario -name $s -mode $s -corner $s
current_scenario $s
source "../../gate/$design\.sdc"
set_scenario_status $s -none -setup true -hold true -leakage_power true -dynamic_power true -max_transition true -max_capacitance true -min_capacitance false -active true
set_parasitic_parameters -late_spec wst -early_spec wst

exec date > timer

# floorplan
foreach direction_offset_pair $tech_info {
	set layer [lindex $direction_offset_pair 0]
	set direction [lindex $direction_offset_pair 1]
	set offset [lindex $direction_offset_pair 2]
	set_attribute [get_layers $layer] routing_direction $direction
	if {$offset != ""} {
		set_attribute [get_layers $layer] track_offset $offset
	}
}

initialize_floorplan -core_utilization 0.6 -core_offset 10
place_pins -self 
save_block -as ${design}_floorplan.design
exec date >> timer

#power rail
create_pg_std_cell_conn_pattern m1_rail -layers {M1} -rail_width 0.33
set_pg_strategy rail_strategy -pattern {{name: m1_rail} {nets: VDD VSS}} -core
compile_pg -strategies rail_strategy

#placement
set_app_options -as -list { place.coarse.continue_on_missing_scandef true }

#place_opt
set_app_options -name place_opt.flow.enable_ccd -value true
set_app_options -name place_opt.flow.trial_clock_tree -value true
set_app_options -name place_opt.flow.optimize_icgs -value true
set_app_options -name place_opt.congestion.effort -value high

set_scenario_status -active true [all_scenarios]
set_voltage 0.90 -object_list [get_supply_nets VDD]
set_voltage 0.00 -object_list [get_supply_nets VSS]
place_opt

#check_legality -verbose

#report design
report_design -all > ./fc_report/place_design.rpt
report_qor  > ./fc_report/place_qor.rpt
report_power > ./fc_report/place_power.rpt
save_block -as ${design}_place.design
exec date >> timer

#routing options
set_app_options -name clock_opt.flow.enable_ccd -value true
set_app_options -name clock_opt.flow.enable_clock_power_recovery -value area

set_app_options -name route.global.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.detail.timing_driven -value true

set_app_options -name time.si_enable_analysis -value true
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven -value true

set_app_options -name route_opt.flow.enable_ccd -value true
set_app_options -name route_opt.flow.enable_power -value true
set_app_options -name route_opt.flow.xtalk_reduction -value true

#cts
clock_opt -from build_clock -to final_opto

#report design
report_design -all > ./fc_report/cts_design.rpt
report_qor  > ./fc_report/cts_qor.rpt
report_power > ./fc_report/cts_power.rpt
save_block -as ${design}_cts.design
exec date >> timer

#route
route_auto
route_opt 

#report design
report_design -all > ./fc_report/route_design.rpt
report_qor  > ./fc_report/route_qor.rpt
report_power > ./fc_report/route_power.rpt
report_timing -nworst 1 -nosplit -nets > ./fc_report/route_timing.rpt
save_block -as ${design}_route.design
exec date >> timer


write_parasitics -output ${design}.spef -format spef
write_def -version 5.7 fc_$design\.def
write_verilog fc_$design\_out.v

exit


