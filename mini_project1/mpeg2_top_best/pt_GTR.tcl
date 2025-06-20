# source ./pt_cmds.tcl
# source ./pt_CapFix.tcl

proc SF_GTR { cell change alpha } {
    puts "DEBUG: SF_GTR - Calculating sensitivity for cell [get_attri $cell base_name], change type: $change"

    set cellName [get_attri $cell base_name]
    set libcell [get_lib_cells -of_objects $cellName]
    set libcellName [get_attri $libcell base_name]

    set origin_leakage [PtLeakPower]
    set origin_slack [PtCellSlack $cellName]
    puts "DEBUG: Original leakage: $origin_leakage, slack: $origin_slack"

    # vth
    if {$change == 0} {
        puts "DEBUG: Trying Vt down for $cellName"
        set changed_cell [getNextVtDown $libcellName]
        size_cell $cellName $changed_cell
    } else {
        puts "DEBUG: Trying size up for $cellName"
        set changed_cell [getNextSizeUp $libcellName]
        size_cell $cellName $changed_cell
    }

    set new_leakage [PtLeakPower]
    set new_slack [PtCellSlack $cellName]
    set deltaLeakage [expr {$new_leakage - $origin_leakage}]
    set deltaSlack [expr {$new_slack - $origin_slack}]
    set numPath [PtNumPath $cellName]
    set sensitivity [expr {$deltaSlack/(pow($deltaLeakage+(1e-12),$alpha))}]

    puts "DEBUG: New leakage: $new_leakage, slack: $new_slack"
    puts "DEBUG: Delta leakage: $deltaLeakage, delta slack: $deltaSlack"
    puts "DEBUG: Num paths: $numPath, Calculated sensitivity: $sensitivity"

    return $sensitivity
}

proc upsizeHighVt_GTR { cell mod_list alpha } {
    # upvar 1 $modify_cell mod_list

    set cellName [get_attri $cell base_name]
    puts "DEBUG: Processing cell $cellName in upsizeHighVt_GTR"

    set libcell [get_lib_cells -of_objects $cellName]
    set libcellName [get_attri $libcell base_name]

    if {$libcellName == "ms00f80"} {
        puts "DEBUG: Cell $cellName is already max size LVT, skipping"
        return
    }

    # cell not LVT
    if { [regexp {[a-z][a-z][0-9][0-9][sh][0-9][0-9]} $libcellName] } {
        set change 0
        puts "DEBUG: Cell $cellName is not LVT, trying Vt down"
        set sensitivity [SF_GTR $cell $change $alpha]
        lappend mod_list [list $cell $change $sensitivity]
        puts "DEBUG: Added Vt down modification with sensitivity $sensitivity"
    }

    # upsizeable cell
    if { [regexp {[a-z][a-z][0-9][0-9][smh](?!80)} $libcellName] } {
        set change 1
        puts "DEBUG: Cell $cellName is upsizable, trying size up"
        set sensitivity [SF_GTR $cell $change $alpha]
        lappend mod_list [list $cell $change $sensitivity]
        puts "DEBUG: Added size up modification with sensitivity $sensitivity"
    }
    return
}

proc CheckFeasibility_GTR {} {
    set worst_slack [PtWorstSlack clk]

    puts "DEBUG: Checking feasibility - worst slack: $worst_slack"
    if {$worst_slack >= 0} {
        return 1
    } else {
        return 0
    }
}
# Perform Global Timing Recovery
proc GTR { design alpha gamma } {
    global best_seen_leakage
    # set outGTR [open ${design}_GTR.rpt w]

    puts "\nDEBUG: ===== Starting GTR optimization ====="
    puts "DEBUG: Design: $design, alpha: $alpha, gamma: $gamma"

    set best_seen_leakage 99999999
    puts "DEBUG: Fixing initial capacitance violations"
    #Fix initial capacitance violations
    FixCapacitanceViolations $design

    array set S {
        feasible 0
        leakage 0
    }

    set S(feasible) [CheckFeasibility_GTR]
    set S(leakage) [PtLeakPower]
    puts "DEBUG: Initial state - feasible: $S(feasible), leakage: $S(leakage)"

    set cellList [sort_collection [get_cells *] base_name]
    puts "DEBUG: Processing [llength $cellList] cells"
    set iteration 1
    set max_iteration 2

    while {!$S(feasible) && $iteration < $max_iteration && $S(leakage) < $best_seen_leakage} {
        puts "\nDEBUG: === GTR iteration $iteration ==="
        puts "DEBUG: Current leakage: $S(leakage), Best seen leakage: $best_seen_leakage"
        # Generate list of possible modifications
        set modify_cell [list]
        set cell_count 0
        foreach_in_collection cell $cellList {
            # set cellName [get_attri $cell base_name]
            upsizeHighVt_GTR $cell $modify_cell $alpha
            incr cell_count
            if {$cell_count % 100 == 0} {
                puts "DEBUG: Processed $cell_count cells so far"
            }
        }
        puts "DEBUG: Generated [llength $modify_cell] potential modifications"

        set num_to_commit [expr int($gamma*[llength $modify_cell])]
        puts "DEBUG: Will commit top $num_to_commit modifications (gamma: $gamma)"
        set counter 0
        set max_count 100

        while {$counter < $num_to_commit && $counter < $max_count && [llength $modify_cell] > 0} {
            # Find modification with max sensitivit
            set maxIndex 0
            set max_sensitivity -999999
            set iterator 0

            foreach m_cell $modify_cell {
                set cur_sensitivity [lindex $m_cell 2]
                if {$cur_sensitivity >= $max_sensitivity} {
                    set maxIndex $iterator
                    set max_sensitivity $cur_sensitivity
                }
                incr iterator
            }
            # Apply the modification
            set operate_M [lindex $modify_cell $maxIndex]
            set operate_cell [lindex $operate_M 0]
            set cellName [get_attri $operate_cell base_name]
            set libcell [get_lib_cells -of_objects $cellName]
            set libcellName [get_attri $libcell base_name]

            puts "DEBUG: Applying modification #[expr $counter+1]:"
            puts "DEBUG:   Cell: $cellName, Type: [expr {$change ? "Size up" : "Vt down"}], Sensitivity: $max_sensitivity"

            if {$change == 0} {
                # Vt down
                puts "DEBUG:   Executing Vt down for $cellName"
                set changed_cell [getNextVtDown $libcellName]
                size_cell $cellName $changed_cell
            } else {
                # size up
                puts "DEBUG:   Executing size up for $cellName"
                set changed_cell [getNextSizeUp $libcellName]
                size_cell $cellName $changed_cell
            }

            puts "DEBUG:   Fixing capacitance violations"
            FixCapacitanceViolations $design
            # remove modified element
            set modify_cell [lreplace $modify_cell $maxIndex $maxIndex]
            incr counter
        }
        # evaluate current results
        set S(feasible) [CheckFeasibility_GTR]
        set S(leakage) [PtLeakPower]
        puts "DEBUG: After iteration $iteration - feasible: $S(feasible), leakage: $S(leakage)"
        #Update best leakage if current solution is feasible
        if {$S(feasible) || $S(leakage) >= $best_seen_leakage} {
            set best_seen_leakage $S(leakage)
            puts "DEBUG: New best leakage found: $best_seen_leakage"
        }

        incr iteration
    }
    # Print final results
    if {$S(feasible)} {
        puts "\nDEBUG: === Optimization SUCCESS ==="
        puts "DEBUG: Final leakage: $S(leakage)"
    } else {
        puts "\nDEBUG: === Optimization COMPLETED without full timing closure ==="
    }
    puts "DEBUG: ===== GTR optimization finished ====="

    return $S(feasible)
}