# Voltus_rail Command File

#Result directory
setvar output_directory_name static_IR

#Distributed processing setting
setvar max_cpu 4
setvar nga_enabled true
nga_dp_hosts max_cpu=4 mode=local time_out=3600

#Layout Files
layout_file /home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/mpeg2_top.def 

#Cell Library
cell_library techonly.cl
setvar tesla_accuracy_mode hd
use_cell_view type standard fast
use_cell_view type macro accurate
use_cell_view type io accurate
setvar unified_power_switch_flow true
setvar power_up_fast_mode true
setvar report_msmv_format true
setvar compress_powergrid_database false
setvar operation_mode signoff_verification
setvar hierarchy_char /
setvar use_cell_id true
nga_setvar nga_enable_new_transient_analysis true
setvar enable_smx true
setvar extract_oci_flow true
setvar ignore_shorts false
setvar enable_manufacturing_effects true
setvar cluster_via_size 4
setvar cluster_via1_ports true
setvar ignore_fillers true
setvar ignore_decaps true
setvar em_model_file em.model
include em.model
setvar em_redundancy_via_current_threshold 0.0
setvar gif_zoom_topcell_diearea false
setvar tech_file ASAP7.tch
setvar keep_log false
setvar enable_report_db true
setvar eiv_report_auto true
nga_setvar nga_current_redistribution true
setvar mge_load_static_pti false
nga_setvar nga_protect_rail_simulation_time false
layout_file -lef /home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/asap7_tech_1x_201209.lef
layout_file -lef /home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/asap7sc7p5t_27_L_1x_201211.lef
layout_file -lef /home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/asap7sc7p5t_27_R_1x_201211.lef
layout_file -lef /home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/asap7sc7p5t_27_SL_1x_201211.lef
net_voltage VDD 0.7 0.4
power_pin_supply_tolerance 0.49 0.91 net=VDD
net_voltage VSS 0 0.3
power_pin_supply_tolerance 0 0.3 net=VSS
power_domain core pwrnet="VDD" gndnet="VSS"
current_data_file scale=1 static_power/static_VDD.ptiavg
current_data_file scale=1 static_power/static_VSS.ptiavg
power_pin VDD file=/home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/VDD.vsrc
power_pin VSS file=/home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/VSS.vsrc
nga_setvar nga_enable_rc_avg_report true
analyze core 0.7 avg 0.10 ir tc rc iv rv vc pv pi rj reff
