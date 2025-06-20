set design aes_cipher_top

set utilList {}
for {set i 60} {$i <= 80} {incr i 10} {
    lappend utilList $i
}
puts "Generated Utilization List: $utilList"

set cpList [list 1600]
puts "Clock Period List: $cpList"

proc get_design_stats {} {
    set instPtrs [dbGet top.insts]
    set N [llength $instPtrs]
    set totPins 0
    foreach inst $instPtrs {
        set instTerms [dbGet $inst.instTerms]
        incr totPins [llength $instTerms]
    }
    set k [format %.3f [expr {$totPins / double($N)}]]
    return [list $N $totPins $k]
}

set fp [open "training.features.csv" "w"]
puts $fp "netName,util,cp,N,totPins,avgPins,bboxArea,bboxAr,bboxX,bboxY,bboxPerim,numPins"

foreach cp $cpList {
    foreach util $utilList {
        puts "Processing: Utilization = $util, Clock Period = $cp"
        set libdir          "../libdir"
        set netlist         "../design/${design}_${util}_${cp}_cts.v"
        set sdc             "../design/${design}_${cp}.sdc"
        set best_timing_lib "$libdir/lib/tcbn65gplusbc.lib"
        set worst_timing_lib "$libdir/lib/tcbn65gpluswc.lib"
        set lef             "$libdir/lef/tcbn65gplus_8lmT2.lef"
        set best_captbl     "$libdir/captbl/cln65g+_1p08m+alrdl_top2_cbest.captable"
        set worst_captbl    "$libdir/captbl/cln65g+_1p08m+alrdl_top2_cworst.captable"

        set init_pwr_net "vdd"
        set init_gnd_net "gnd"

        set init_verilog "$netlist"
        set init_design_netlisttype "Verilog"
        set init_design_settop 1
        set init_top_cell "$design"
        set init_lef_file "$lef"

        create_library_set -name WC_LIB -timing $worst_timing_lib
        create_library_set -name BC_LIB -timing $best_timing_lib
        create_rc_corner    -name Cmax -cap_table $worst_captbl -T 125
        create_rc_corner    -name Cmin -cap_table $best_captbl  -T -40
        create_delay_corner -name WC   -library_set WC_LIB -rc_corner Cmax
        create_delay_corner -name BC   -library_set BC_LIB -rc_corner Cmin
        create_constraint_mode -name CON -sdc_file [list $sdc]
        create_analysis_view  -name WC_VIEW -delay_corner WC -constraint_mode CON
        create_analysis_view  -name BC_VIEW -delay_corner BC -constraint_mode CON
        init_design   -setup {WC_VIEW} -hold {BC_VIEW}

        set_interactive_constraint_modes {CON}
        setDesignMode -process 65

        defIn ../design/${design}_${util}_${cp}_cts.def

        lassign [get_design_stats] N totPins avgPins

        foreach net [dbGet top.nets] {
            if { [dbGet $net.isPwr] || [dbGet $net.isGnd] || [dbGet $net.isClock] } {
                continue
            }
            set netName [dbGet $net.name]

            if { $netName == "ld" || [string match "*SYNOPSYS_UNCONNECTED*" $netName] } {
                continue
            }

            set numPins [expr [dbGet $net.numInputTerms] + [dbGet $net.numOutputTerms]]
            if {$numPins < 2 || $numPins > 50} {
                continue
            }

            set bboxArea [dbGet $net.box_area]
            if { $bboxArea == "0.0" } {
                set bboxAr 0
            } else {
                set bboxAr [format %.3f [expr [dbGet $net.box_sizex] / [dbGet $net.box_sizey] ]]
            }
            set bboxX   [dbGet $net.box_sizex]
            set bboxY   [dbGet $net.box_sizey]
            set bboxPerim [expr {2.0*($bboxX + $bboxY)}]

            puts $fp "$netName,$util,$cp,$N,$totPins,$avgPins,$bboxArea,$bboxAr,$bboxX,$bboxY,$bboxPerim,$numPins"
        }
        freeDesign
    }
}
close $fp
exit