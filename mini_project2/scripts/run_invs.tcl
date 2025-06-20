# Load design
set design aes_cipher_top
set util 0.80
set cp 1400
set utilStr [format "%d" [expr int($util * 100)]]

set libdir 		"../libdir"
set netlist 		"../design/$design.v"
set sdc 		"../design/${design}_${cp}.sdc"
set best_timing_lib 	"$libdir/lib/tcbn65gplusbc.lib"
set worst_timing_lib 	"$libdir/lib/tcbn65gpluswc.lib"
set lef 		"$libdir/lef/tcbn65gplus_8lmT2.lef"
set best_captbl 	"$libdir/captbl/cln65g+_1p08m+alrdl_top2_cbest.captable"
set worst_captbl 	"$libdir/captbl/cln65g+_1p08m+alrdl_top2_cworst.captable"

set runMode orig_${utilStr}_${cp}

set rptDir rpt_${runMode}/
set encDir enc_${runMode}/
set designDir ../design/

if {![file exists $rptDir/]} {
    exec mkdir $rptDir/
}
if {![file exists $encDir/]} {
    exec mkdir $encDir/
}

# default settings
set init_pwr_net "vdd"
set init_gnd_net "gnd"

# default settings
set init_verilog "$netlist"
set init_design_netlisttype "Verilog"
set init_design_settop 1
set init_top_cell "$design"
set init_lef_file "$lef"

# MCMM setup
create_library_set -name WC_LIB -timing $worst_timing_lib
create_library_set -name BC_LIB -timing $best_timing_lib
create_rc_corner -name Cmax -cap_table $worst_captbl -T 125
create_rc_corner -name Cmin -cap_table $best_captbl -T -40
create_delay_corner -name WC -library_set WC_LIB -rc_corner Cmax
create_delay_corner -name BC -library_set BC_LIB -rc_corner Cmin
create_constraint_mode -name CON -sdc_file [list $sdc]
create_analysis_view -name WC_VIEW -delay_corner WC -constraint_mode CON
create_analysis_view -name BC_VIEW -delay_corner BC -constraint_mode CON
init_design -setup {WC_VIEW} -hold {BC_VIEW}

set_interactive_constraint_modes {CON}
setDesignMode -process 65

# Floorplan
floorPlan -site core -r 1 $util 10.0 10.0 10.0 10.0

# Placement
saveDesign $encDir/floorplan.enc
setPlaceMode -timingDriven true -reorderScan false -congEffort medium -modulePlan false
setOptMode -effort high -powerEffort high -leakageToDynamicRatio 0.5 -fixFanoutLoad true -restruct true -verbose true
place_opt_design

saveDesign $encDir/placement.enc


# Clock tree synthesis
set_ccopt_property -update_io_latency false
create_ccopt_clock_tree_spec
# create_ccopt_clock_tree_spec -file $desdir/constraints/$design.ccopt
ccopt_design

# Use actual clock network
set_propagated_clock [all_clocks]

# Post-CTS timing optimization
optDesign -postCTS -hold
saveDesign $encDir/cts.enc
defOut -routing $designDir/${design}_${utilStr}_${cp}_cts.def
saveNetlist $designDir/${design}_${utilStr}_${cp}_cts.v
summaryReport -nohtml -outfile $rptDir/${design}.post_cts.summary.rpt

# Routing
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

# RC extraction for optimization
setExtractRCMode -engine postRoute
extractRC

# Post-route timing optimization
setAnalysisMode -analysisType onChipVariation -cppr both
optDesign -postRoute -setup -hold
saveDesign $encDir/route.enc
defOut -routing $designDir/${design}_${utilStr}_${cp}_route.def
saveNetlist $designDir/${design}_${utilStr}_${cp}_route.v


# Timing report
report_timing -max_paths 5 > $rptDir/${design}.post_route.timing.rpt

# Power report
report_power -outfile $rptDir/${design}.post_route.power.rpt

# Design report
summaryReport -nohtml -outfile $rptDir/${design}.post_route.summary.rpt

exit
