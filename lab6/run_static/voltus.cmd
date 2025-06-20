#######################################################
#                                                     
#  Voltus IC Power Integrity Solution Command Logging File                     
#  Created on Mon Jun  2 11:24:07 2025                
#                                                     
#######################################################

#@(#)CDS: Voltus IC Power Integrity Solution v23.14-s089_1 (64bit) 03/07/2025 10:32 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 23.14-s089_1 NR250219-0822/23_14-UB (database version 18.20.661) {superthreading v2.20}
#@(#)CDS: AAE 23.14-s021 (64bit) 03/07/2025 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 23.14-s037_1 () Mar  5 2025 19:25:03 ( )
#@(#)CDS: SYNTECH 23.14-s011_1 () Mar  4 2025 21:57:26 ( )
#@(#)CDS: CPE v23.14-s083

read_lib -lef {asap7_tech_1x_201209.lef asap7sc7p5t_27_L_1x_201211.lef asap7sc7p5t_27_R_1x_201211.lef asap7sc7p5t_27_SL_1x_201211.lef}
read_view_definition viewDefinition.tcl
read_verilog mpeg2_top.v
set_top_module mpeg2_top -ignore_undefined_cell
read_def mpeg2_top.def
set_pg_nets -net VDD -voltage 0.7 -threshold 0.4 -force
set_pg_nets -net VSS -voltage 0.0 -threshold 0.3 -force
read_spef mpeg2_top.spef
specify_spef mpeg2_top.spef
set_power_analysis_mode -reset
set_power_pads -reset
set_power_data -reset
set_pg_library_mode -celltype techonly -default_area_cap 0.5 -extraction_tech_file ASAP7.tch -power_pins {VDD 0.7} -ground_pins VSS
generate_pg_library
set_power_analysis_mode -method static -corner max -create_binary_db true -write_static_currents true
set_power_output_dir ./static_power
report_power
set_rail_analysis_mode -method static -power_switch_eco false -accuracy hd -analysis_view AV_wc_on -power_grid_library techonly.cl -enable_xp false -enable_rlrp_analysis true -em_models em.model -extraction_tech_file ASAP7.tch
set_pg_nets -net VDD -voltage 0.7 -threshold 0.4 -force
set_pg_nets -net VSS -voltage 0.0 -threshold 0.3 -force
set_rail_analysis_domain -name core -pwrnets VDD -gndnets VSS
set_power_pads -net VDD -format xy -file VDD.vsrc
set_power_pads -net VSS -format xy -file VSS.vsrc
set_power_data -format current -scale 1 { static_power/static_VDD.ptiavg static_power/static_VSS.ptiavg}
analyze_rail -output static_IR -type domain core
