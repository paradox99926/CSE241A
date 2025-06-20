set design [get_attri [current_design] full_name]
set outFp [open ${design}_sizing.rpt w]

# get WNS and Leakage
set initialWNS  [ PtWorstSlack clk ]
set initialLeak [ PtLeakPower ]
set capVio [ PtGetCapVio ]
set tranVio [ PtGetTranVio ]
puts "Initial slack:\t${initialWNS} ps"
puts "Initial leakage:\t${initialLeak} W"
puts "Final $capVio"
puts "Final $tranVio"
puts "======================================" 
puts $outFp "Initial slack:\t${initialWNS} ps"
puts $outFp "Initial leakage:\t${initialLeak} W"
puts $outFp "Final $capVio"
puts $outFp "Final $tranVio"
puts $outFp "======================================" 

# get all the cells
set cellList [sort_collection [get_cells *] base_name]
set VtswapCnt 0
set SizeswapCnt 0


# Perform Global Timing Recovery


# Perform SGGS
# array set modify_cell {}
set modifyList [PriorityQueue new]
# set iter 0

# puts "the size of empty pq is [$modifyList size]"

foreach_in_collection cell $cellList {
    
    # if {$iter > 100} {
    #     break
    # }
    set cellName [get_attri $cell base_name]
    set changeAndSensitivity [downsizeUpVt $cellName]
    set change [lindex $changeAndSensitivity 0]
    set sensitivity [lindex $changeAndSensitivity 1]
    if {$change != 2} {

        # puts "current sensitivity is $sensitivity"
        $modifyList insert [list $cellName $change] $sensitivity
        # puts "the size of modify list after insertion is [$modifyList size]"
    }

    # incr iter
}

# puts "the size of modify list is [$modifyList size]"


set WNS_threshold 80

# puts "finish first part"
set maxIteration 2000
set iter 0

while { [$modifyList size] > 0 } {
    # puts "============== START to POP=============="

    if {$iter > $maxIteration} {
        break
    }

    puts "the size of modify list is [$modifyList size]"

    set operate_M [lindex [$modifyList pop] 0]

    # puts "the size of modify list after POP is [$modifyList size]"

    set operate_cell_name [lindex $operate_M 0]
    # set cellName [get_attri $operate_cell base_name]
    set change [lindex $operate_M 1]
    set libcell [get_lib_cells -of_objects $operate_cell_name]
    set libcellName [get_attri $libcell base_name]

    if {$change == 0} {
        size_cell $operate_cell_name [getNextVtDown $libcellName]
    }
    if {$change == 1} {
        size_cell $operate_cell_name [getNextSizeDown $libcellName]
    }

    # set modify_cell [lreplace $modify_cell $maxIndex $maxIndex]
    # puts "finish cell sizing"
    # puts "operate cell is $operate_M"

    if {[feasible $WNS_threshold]} {
        set changeAndSensitivity [downsizeUpVt $operate_cell_name]
        set change [lindex $changeAndSensitivity 0]
        set sensitivity [lindex $changeAndSensitivity 1]
        # puts "re-operate cell $operate_cell_name"
        set libcell [get_lib_cells -of_objects $operate_cell_name]
        set libcellName [get_attri $libcell base_name]
        # puts "its change is $change"
        # puts "the lib bell name is $libcellName"

        if {$change != 2} {
            # puts "insert again"

            # puts "current sensitivity is $sensitivity"
            $modifyList insert [list $operate_cell_name $change] $sensitivity
            # puts "the size of modify list after insertion is [$modifyList size]"
        }
    } else {
        # return back to the origin state space
        # puts "start to roll back"
        if {$change == 0} {
            # we do not update the libcell name
            size_cell $operate_cell_name $libcellName
        } else {
            size_cell $operate_cell_name $libcellName
        }
    }

    # puts "=========== Current Iteration is $iter ====================="

    incr iter
}

# slack legalization
set slack_threshold 90
# slack_legalization $cellList $slack_threshold

# speedUpBottleNeck $cellList 0.01

set finalWNS  [ PtWorstSlack clk ]
set finalLeak [ PtLeakPower ]
set capVio [ PtGetCapVio ]
set tranVio [ PtGetTranVio ]
set improvment  [format "%.3f" [expr ( $initialLeak - $finalLeak ) / $initialLeak * 100.0]]
puts $outFp "======================================" 
puts $outFp "Final slack:\t${finalWNS} ps"
puts $outFp "Final leakage:\t${finalLeak} W"
puts $outFp "Final $capVio"
puts $outFp "Final $tranVio"
# puts $outFp "#Vt cell swaps:\t${VtswapCnt}"
puts $outFp "#Cell size swaps:\t${SizeswapCnt}"
puts $outFp "Leakage improvment\t${improvment} %"

close $outFp    


