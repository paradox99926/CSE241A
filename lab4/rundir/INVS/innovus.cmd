#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Mon Apr 28 17:45:59 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.10-p004_1 (64bit) 05/18/2021 11:58 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.10-p004_1 NR210506-1544/21_10-UB (database version 18.20.544) {superthreading v2.14}
#@(#)CDS: AAE 21.10-p006 (64bit) 05/18/2021 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.10-p004_1 () May 13 2021 20:04:41 ( )
#@(#)CDS: SYNTECH 21.10-b006_1 () Apr 18 2021 22:44:07 ( )
#@(#)CDS: CPE v21.10-p004
#@(#)CDS: IQuantus/TQuantus 20.1.2-s510 (64bit) Sun Apr 18 10:29:16 PDT 2021 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
set init_pwr_net vdd
set init_gnd_net gnd
set init_verilog ../../gate/jpeg_encoder.v
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell jpeg_encoder
set init_lef_file /home/linux/ieng6/cs241asp25/public/data/libraries/techfiles/tcbn65gplus_8lmT2.lef
create_library_set -name WC_LIB -timing $libworst
create_library_set -name BC_LIB -timing $libworst
create_rc_corner -name Cmax -cap_table $captblworst -T 125
create_rc_corner -name Cmin -cap_table $captblworst -T -40
create_delay_corner -name WC -library_set WC_LIB -rc_corner Cmax
create_delay_corner -name BC -library_set BC_LIB -rc_corner Cmin
create_constraint_mode -name CON -sdc_file [list $sdc]
create_analysis_view -name WC_VIEW -delay_corner WC -constraint_mode CON
create_analysis_view -name BC_VIEW -delay_corner BC -constraint_mode CON
init_design -setup WC_VIEW -hold BC_VIEW
set_interactive_constraint_modes {CON}
setDesignMode -process 65
floorPlan -site core -r 1 0.6 10.0 10.0 10.0 10.0
setOptMode -effort high -powerEffort high -leakageToDynamicRatio 0.5 -fixFanoutLoad true
place_opt_design
report_power -outfile ./invs_report/place_power.rpt
summaryReport -noHtml -outfile ./invs_report/place_summary.rpt
saveDesign jpeg_encoder_placed.enc
set_ccopt_property -update_io_latency false
create_ccopt_clock_tree_spec
ccopt_design
set_propagated_clock [all_clocks]
optDesign -postCTS -hold
report_power -outfile ./invs_report/CT_power.rpt
report_ccopt_clock_trees -file ./invs_report/CT.rpt
summaryReport -noHtml -outfile ./invs_report/CT_summary.rpt
saveDesign jpeg_encoder_CT.enc
setNanoRouteMode -quiet -drouteAllowMergedWireAtPin false
setNanoRouteMode -quiet -drouteFixAntenna true
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
setNanoRouteMode -quiet -routeSiEffort medium
setNanoRouteMode -quiet -routeWithSiPostRouteFix false
setNanoRouteMode -quiet -drouteAutoStop true
setNanoRouteMode -quiet -routeSelectedNetOnly false
setNanoRouteMode -quiet -drouteStartIteration default
routeDesign
setExtractRCMode -engine postRoute
extractRC
setAnalysisMode -analysisType onChipVariation -cppr both
optDesign -postRoute -setup -hold
extractRC
rcOut -spef invs_jpeg_encoder.spef
defOut -routing invs_jpeg_encoder.def
summaryReport -noHtml -outfile ./invs_report/route_summary.rpt
report_power -outfile ./invs_report/route_power.rpt
report_timing > ./invs_report/route_timing.rpt
saveDesign jpeg_encoder_routed.enc
saveNetlist invs_jpeg_encoder.v
