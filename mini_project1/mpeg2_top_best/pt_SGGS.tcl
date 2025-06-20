# source ./pt_cmds.tcl
# source ./my_own_cmds.tcl

proc CheckFeasibility_SGGS {WNS_thres} {
    set worst_slack [PtWorstSlack clk]
    if {$worst_slack >= $WNS_thres} {
        return 1
    } else {
        return 0
    }
}

# Perform Global Timing Recovery
proc SGGS { design } {
    puts "===== STARTING SGGS PROCEDURE ====="
    puts "Design: $design"

    set WNS_thres 60
    set group_size 3000
    puts "Setting WNS threshold to: $WNS_thres"

    set modify_cell [list]
    puts "Initializing empty modify_cell list"

    set feasible [CheckFeasibility_SGGS $WNS_thres]
    puts "Initial feasibility check: $feasible"

    set cellList [sort_collection [get_cells *] base_name]
    puts "Selected [llength $cellList] cells for processing"

    puts "===== DOWNSIZING LOW VT CELLS ====="
    set down_iteration 0
    foreach_in_collection cell $cellList {
        puts "Processing cell: [get_attribute $cell base_name]"
        set  modify_cell [downsizeLowVt $cell $modify_cell]
        incr down_iteration
        puts "Processing $down_iteration cell"
        puts "Current modify_cell list length: [llength $modify_cell]"
        # set l [llength $modify_cell]
        # set c [lindex $modify_cell [expr {$l-1}]]
        # puts "Current cell name: [lindex $c 0]"
        if {$down_iteration eq $group_size} {
            break
        }
    }

    puts "===== MAIN OPTIMIZATION LOOP ====="
    set iteration 0
    set max_iteration [expr {0.1*$group_size}]
    while {[llength $modify_cell] > 0 } {
        incr iteration
        puts "\n==== Iteration $iteration ===="
        puts "Current modify_cell list length: [llength $modify_cell]"

        # Find cell with max sensitivity
        set maxIndex 0
        set max_sensitivity -999999
        set iterator 0
        foreach m_cell $modify_cell {
            set cur_sensitivity [lindex $m_cell 2]
            puts "cur_sensitivity: $cur_sensitivity"
            if {$cur_sensitivity >= $max_sensitivity} {
                set maxIndex $iterator
                set max_sensitivity $cur_sensitivity
            }
            incr iterator
        }
        puts "Found max sensitivity cell at index $maxIndex with sensitivity $max_sensitivity"

        set operate_M [lindex $modify_cell $maxIndex]
        set operate_cell [lindex $operate_M 0]
        set change [lindex $operate_M 1]
        set cellName [get_attribute $operate_cell base_name]
        set libcell [get_lib_cells -of_objects $cellName]
        set libcellName [get_attribute $libcell base_name]

        puts "Operating on cell: $cellName (current libcell: $libcellName)"

        if {$change == 0} {
            set newLibcell [getNextVtDown $libcellName]
            puts "Changing to next VT Down: $newLibcell"
            size_cell $cellName $newLibcell
        } else {
            set newLibcell [getNextSizeDown $libcellName]
            puts "Changing to size down: $newLibcell"
            size_cell $cellName $newLibcell
        }

        # set modify_cell [lreplace $modify_cell $maxIndex $maxIndex]
        # puts "Removed cell from modify_cell list"

        set feasible [CheckFeasibility_SGGS $WNS_thres]
        puts "Feasibility check after modification: $feasible"

        if {$feasible} {
            puts "Modification was feasible, continuing..."
            # set  modify_cell [downsizeLowVt $cell $modify_cell]
            # puts "Added new cells to modify_cell list. New length: [llength $modify_cell]"
        } else {
            puts "Modification was NOT feasible, reverting changes..."
            if {$change == 0} {
                puts "Reverting to original libcell: $libcellName"
                size_cell $cellName $libcellName
            } else {
                puts "Reverting to original libcell: $libcellName"
                size_cell $cellName $libcellName
            }
        }

        # remove modified element
        set modify_cell [lreplace $modify_cell $maxIndex $maxIndex]
        puts "Final modify_cell list length after iteration: [llength $modify_cell]"
        if {$iteration eq $max_iteration} {
            break
        }
    }


    puts "===== SGGS PROCEDURE COMPLETED ====="
}