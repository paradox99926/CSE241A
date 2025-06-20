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

oo::class create PriorityQueue {
    variable heap
    
    constructor {} {
        set heap [list]
    }
    
    # Helper method to get parent index
    method parent {i} {
        return [expr {($i - 1) / 2}]
    }
    
    # Helper method to get left child index
    method leftChild {i} {
        return [expr {2 * $i + 1}]
    }
    
    # Helper method to get right child index
    method rightChild {i} {
        return [expr {2 * $i + 2}]
    }
    
    # Swap elements at indices i and j
    method swap {i j} {
        set temp [lindex $heap $i]
        set heap [lreplace $heap $i $i [lindex $heap $j]]
        set heap [lreplace $heap $j $j $temp]
    }
    
    # Heapify up (bubble up) - maintains heap property upward
    method heapifyUp {index} {
        while {$index > 0} {
            set parentIdx [my parent $index]
            set currentPriority [lindex [lindex $heap $index] 1]
            set parentPriority [lindex [lindex $heap $parentIdx] 1]
            
            if {$currentPriority > $parentPriority} {
                my swap $index $parentIdx
                set index $parentIdx
            } else {
                break
            }
        }
    }
    
    # Heapify down (bubble down) - maintains heap property downward
    method heapifyDown {index} {
        set size [llength $heap]
        
        while {1} {
            set largest $index
            set leftIdx [my leftChild $index]
            set rightIdx [my rightChild $index]
            
            # Check left child
            if {$leftIdx < $size} {
                set leftPriority [lindex [lindex $heap $leftIdx] 1]
                set largestPriority [lindex [lindex $heap $largest] 1]
                if {$leftPriority > $largestPriority} {
                    set largest $leftIdx
                }
            }
            
            # Check right child
            if {$rightIdx < $size} {
                set rightPriority [lindex [lindex $heap $rightIdx] 1]
                set largestPriority [lindex [lindex $heap $largest] 1]
                if {$rightPriority > $largestPriority} {
                    set largest $rightIdx
                }
            }
            
            if {$largest != $index} {
                my swap $index $largest
                set index $largest
            } else {
                break
            }
        }
    }
    
    # Insert element with priority
    method insert {value priority} {
        set element [list $value $priority]
        lappend heap $element
        set lastIndex [expr {[llength $heap] - 1}]
        my heapifyUp $lastIndex
    }
    
    # Remove and return element with highest priority (largest value)
    method pop {} {
        set size [llength $heap]
        
        if {$size == 0} {
            error "Priority queue is empty"
        }
        
        # Get the root element (highest priority)
        set result [lindex $heap 0]
        
        if {$size == 1} {
            set heap [list]
        } else {
            # Move last element to root and heapify down
            set heap [lreplace $heap 0 0 [lindex $heap [expr {$size - 1}]]]
            set heap [lreplace $heap [expr {$size - 1}] [expr {$size - 1}]]
            my heapifyDown 0
        }
        
        return $result
    }
    
    # Peek at the highest priority element without removing it
    method peek {} {
        if {[llength $heap] == 0} {
            error "Priority queue is empty"
        }
        
        return [lindex $heap 0]
    }
    
    # Check if queue is empty
    method is_empty {} {
        return [expr {[llength $heap] == 0}]
    }
    
    # Get queue size
    method size {} {
        return [llength $heap]
    }
    
    # Clear all elements from the queue
    method clear {} {
        set heap [list]
    }
    
    # Get all elements as a list (for debugging/inspection)
    method toList {} {
        return $heap
    }
    
    # Display queue contents (for debugging)
    method display {} {
        puts "Priority Queue contents:"
        if {[llength $heap] == 0} {
            puts "  (empty)"
            return
        }
        
        for {set i 0} {$i < [llength $heap]} {incr i} {
            set element [lindex $heap $i]
            puts "  Index $i: Value [lindex $element 0], Priority [lindex $element 1]"
        }
    }
    
    # String representation of the queue
    method toString {} {
        if {[llength $heap] == 0} {
            return "PriorityQueue(empty)"
        }
        
        set elements {}
        foreach element $heap {
            lappend elements "([lindex $element 0], [lindex $element 1])"
        }
        return "PriorityQueue([join $elements {, }])"
    }
    
    # Destructor
    destructor {
        # Cleanup if needed
        set heap [list]
    }
}

proc getFanInCell { cell_name } {
    set pin [get_pins -of $cell_name -filter "direction==in"]

    # level means parents, if you do not specify the levels, it will retrieve all the ancestors.
    set drv_cell [all_fanin -to $pin -only_cells -levels 1]
    # remove the first element, itself from the collection
    set drv_cell [remove_from_collection $drv_cell [get_cells $cell_name]]

    return $drv_cell
}

proc printCellList { cellList } {
    foreach_in_collection cell $cellList {
        set cellName [get_attri $cell base_name]
        puts "current cell is $cellName"
    }
    return
}

proc PtNumNegPaths { cell } {
    # group_path -from clk_name -through cell_name -name group_cell_$cell_name
    set path [get_timing_paths -max_paths -slack_lesser_than 50 -through $cell]
    # set path_slack [get_attribute $path slack]
    return [sizeof_collection $path]
}

proc PtNumPath { cell } {
    # group_path -through cell_name -name group_cell_$cell_name
    # set path [get_timing_paths -group group_cell_$cell_name]
    set path [get_timing_paths -max_paths 10000 -slack_lesser_than 2000 -through $cell]
    return [sizeof_collection $path]
}

proc SF { cellName change } {
    set origin_leakage [PtLeakPower]
    # set cellName [get_attri $cell base_name]
    set libcell [get_lib_cells -of_objects $cellName]
    set libcellName [get_attri $libcell base_name]
    set origin_delay [PtCellDelay $cellName]
    set mySlack [PtCellSlack $cellName]

    # vth 
    if {$change == 0} {
        size_cell $cellName [getNextVtDown $libcellName]
    } else {
        size_cell $cellName [getNextSizeDown $libcellName]
    }

    set new_leakage [PtLeakPower]
    set new_delay [PtCellDelay $cellName]
    set deltaLeakage [expr {$origin_leakage - $new_leakage}]
    set deltaDelay [expr {$new_delay - $origin_delay}]
    set numPath [PtNumPath $cellName]
    # set mySensitivity [expr {$deltaLeakage * $mySlack / $deltaDelay / $numPath}]
    set mySensitivity [expr { $deltaLeakage * $mySlack }]
    # set sensitivity [expr {$deltaLeakage * $slack / $deltaDelay}]
    size_cell $cellName $libcellName 
    
    return $mySensitivity
}

proc downsizeUpVt { cellName } {
    # set cellName [get_attri $cell base_name]
    set libcell [get_lib_cells -of_objects $cellName]
    set libcellName [get_attri $libcell base_name]
    # if {$libcellName == "ms00f80"} {
    #     return
    # }
    if {$libcellName == "ms00f80"} {
        return [list 2 0]
    }

    # cell not HVT
    if { [regexp {[a-z][a-z][0-9][0-9][mf][0-9][0-9]} $libcellName] } { 
    
        set change 0
        set sensitivity [SF $cellName $change]

        # $modify_cell insert [list $cell $change] $sensitivity
        # incr $counter
        return [list $change $sensitivity]
    }
    # downsizeable cell
    if { [regexp {[a-z][a-z][0-9][0-9][smf](?!01)} $libcellName] } { 
        set change 1
        set sensitivity [SF $cellName $change]

        # $modify_cell insert [list $cell $change] $sensitivity
        # incr $counter
        return [list $change $sensitivity]
    }

    return [list 2 0]
}

proc feasible { WNS_threshold } {
    set worstSlack [PtWorstSlack clk]
    if {$worstSlack >= $WNS_threshold} {
        return 1
    } else {
        return 0
    }
}

proc SGGS { cellList } {
    set modifyList [PriorityQueue new]
# set iter 0

# puts "the size of empty pq is [$modifyList size]"

    foreach_in_collection cell $cellList {
        
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


    set WNS_threshold 50

    # puts "finish first part" 

    while { [$modifyList size] > 0 } {
        # puts "============== START to POP=============="
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
    }
}

proc deltaDelayAfterUpsizeUpVt { cell } {
    set cellName [get_attri $cell base_name]
    set libcell [get_lib_cells -of_objects $cellName]
    set libcellName [get_attri $libcell base_name]
    # if {$libcellName == "ms00f80"} {
    #     return
    # }
    # cell not HVT
    set change 0
    set origin_delay [PtCellDelay $cellName]
    # puts "the lib cell name is $libcellName"
    if { [regexp {[a-z][a-z][0-9][0-9][sm][0-9][0-9]} $libcellName] } { 
    
        # set sensitivity [SF $cell $change]
        # set change 0

        size_cell $cellName [getNextVtUp $libcellName]
        set new_delay [PtCellDelay $cellName]
        set deltaDelay [expr {$new_delay - $origin_delay}]

        puts "start to return delta delay $deltaDelay"
        return $deltaDelay
    }
    # downsizeable cell
    # if { [regexp {[a-z][a-z][0-9][0-9][smf](?!80)} $libcellName] } { 
    #     set change 1
    #     size_cell $cellName [getNextSizeUp $libcellName]
    #     set new_delay [PtCellDelay $cellName]
    #     # return back to the origin size
    #     size_cell $cellName $libcellName
    #     # incr $counter
    # }
    return -999999
}


proc slack_legalization { cell_list slack_threshold} {
    puts "start slack legalization"
    set negSlackCell [list]
    # puts "create list"
    set cellWithDeltaDelay [PriorityQueue new]
    # puts "create pq"
    # set slack_threshold 70

    # get all the cells with negative slack
    foreach_in_collection cell $cell_list {
        set cellName [get_attri $cell base_name]
        if {[PtCellSlack $cellName] < $slack_threshold} {
            lappend negSlackCell $cell
        }
    }
    # puts "finish first loop"
    # get delta delay using upsizing and Vt down

    foreach_in_collection eachNegCell $negSlackCell {
        set deltaDelay [deltaDelayAfterUpsizeUpVt $eachNegCell]

        # puts "the neg cell's delta delay is $deltaDelay"

        $cellWithDeltaDelay insert $eachNegCell $deltaDelay
    }
    puts "the size of pq is [$cellWithDeltaDelay size]"

    # maybe we can use while loop with pop
    # foreach_in_collection pqElement $cellWithDeltaDelay {}
    while { [$cellWithDeltaDelay size] > 0} {
        puts "the size of pq is [$cellWithDeltaDelay size]"
        # set pqElement 
        set negElement [lindex [$cellWithDeltaDelay pop] 0]
        set cellName [get_attri $negElement base_name]
        # puts "cell nama is $cellName"
        set fanInCell [getFanInCell $cellName]
        # set cellName [get_attri $cell base_name]
        set libcell [get_lib_cells -of_objects $cellName]
        set libcellName [get_attri $libcell base_name]

        # get origin slack
        set cellSlack [PtCellSlack $cellName]
        set fanInSlack 0

        foreach_in_collection fanIn $fanInCell {
            set fanInName [get_attri $fanIn base_name]
            set fanInSlack [expr {$fanInSlack + [PtCellSlack $fanInName]}]
        }

        # puts "find all fanIn"

        # now we modify the cells
        if { [regexp {[a-z][a-z][0-9][0-9][sm][0-9][0-9]} $libcellName] } {

            # puts "increase cell speed"
            # if { [regexp {[a-z][a-z][0-9][0-9][smf](?!80)} $libcellName] } {}
            size_cell $cellName [getNextVtUp $libcellName]

            # calculate delta slack
            # puts "calculate cell slack"
            set deltaSlack [expr {[PtCellSlack $cellName] - $cellSlack}]
            set newFanInSlack 0

            # puts "start fan in slack"

            foreach_in_collection fanInCell $fanInCell {
                set newFanInName [get_attri $fanIn base_name]
                puts "get fanInName"
                set newFanInSlack [expr {$newFanInSlack + [PtCellSlack $newFanInName]}]
                puts "new fan in slack value is $newFanInSlack"
            }

            # puts "calculate fan In Slack finish"

            set deltaFanInSalck [expr {$newFanInSlack - $fanInSlack}]

            # restore the modification
            if {$deltaSlack < 0.0 || $deltaFanInSalck < 0.0} {
                puts "restore the modification"
                size_cell $cellName $libcellName
            }
        }


        if {[feasible $slack_threshold]} {
            puts "return"
            return
        }
    }
}

proc getDeltaTotalSlack { cell } {
    set cellName [get_attri $cell base_name]
    set libcell [get_lib_cells -of_objects $cellName]
    set libcellName [get_attri $libcell base_name]

    set origin_delay [PtCellDelay $cellName]
    set pathNumber [PtNumPath $cellName]

    if { [regexp {[a-z][a-z][0-9][0-9][sm][0-9][0-9]} $libcellName] } {
            size_cell $cellName [getNextVtUp $libcellName]
            set newDelay [PtCellDelay $cellName]
            set result [expr {($origin_delay - $newDelay) / sqrt($pathNumber)}]
            size_cell $cellName $libcellName
            return $result
    } 
    # size_cell $
    return -100
}

proc speedUpBottleNeck { cell_list gamma } {
    set bottleNeckPQ [PriorityQueue new]

    # get the total delta slack of all the cells
    foreach_in_collection cell $cell_list {
        set deltaTotalSlack [getDeltaTotalSlack $cell]
        $bottleNeckPQ insert $cell $deltaTotalSlack
    }

    set pqLength [$bottleNeckPQ size]
    set perturbNumber [expr {$pqLength * $gamma}]

    for {set i 0} {$i < $perturbNumber} {incr i} {
        puts "start to perturb number $i"
        # start to perturb
        # first upsize or low Vt
        # then downsize or high Vt
        set perturbCell [$bottleNeckPQ pop]
        set perturbCellName [get_attri $perturbCell base_name]
        set originLibCell [get_lib_cells -of_objects $perturbCellName]
        set originLibCellName [get_attri $originLibCell base_name]

        set upvt [getNextVtUp $originLibCellName]
        size_cell $perturbCellName $upvt
        size_cell $perturbCellName $originLibCellName
    }
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
# source ./pt_cmds.tcl

proc getFanInPins {instance outfile} {
    if {![info exists instance] || [get_cells -quiet $instance] eq ""} {
        puts $outfile "WARNING: Invalid cell instance: '$instance'"
        return [list]
    }
    set pins [get_pins -of_objects $instance -filter "direction==in"]
    return $pins
}

proc getFanOutPins {instance outfile} {
    if {![info exists instance] || [get_cells -quiet $instance] eq ""} {
        puts $outfile "WARNING: Invalid cell instance: '$instance'"
        return [list]
    }
    set pins [get_pins -of_objects $instance -filter "direction==out"]
    return $pins
}

proc ReportPinLoadCap { outfile cell pin current_load max_allowed_load } {
    if {[llength $current_load] == 2} {
        puts $outfile "INFO: For cell $cell pin $pin, no load capacitance check needed (input pin or output port)"
    } else {
        puts $outfile "INFO: For cell $cell pin $pin, current_load: [format %.3f $current_load]fF; max_allowed_load: [format %.3f $max_allowed_load]fF"
    }
}

proc FixCapacitanceViolations { design } {
    global upSizeswapCnt downSizeswapCnt
    set upSizeswapCnt 0
    set downSizeswapCnt 0
    set outCap [open ${design}_CapVio.rpt w]

    # Run 1-2 iterations as recommended in the paper
    for {set iter 1} {$iter <= 2} {incr iter} {
        puts $outCap "\nINFO: Capacitance violation repair iteration $iter"

        # Backward Traversal (upsizing current cell when its outputs are overloaded)
        set cellList [sort_collection [get_cells *] base_name]
        puts $outCap "INFO: Backward traversal processing [sizeof_collection $cellList] cells"

        foreach_in_collection cell_instance $cellList {
            set cellName [get_attri $cell_instance base_name]
            set libcell [get_lib_cells -of_objects $cellName]
            set libcellName [get_attribute $libcell base_name]

            foreach_in_collection output_pin [getFanOutPins $cellName $outCap] {
                set pin_name [get_attribute $output_pin full_name]
                set current_load [PtGetPinLoadCap $pin_name]
                set max_allowed_load [PtGetPinMaxCap $pin_name]
                # ReportPinLoadCap  $outCap $cellName $pin_name $current_load $max_allowed_load

                if {$current_load eq "" || $max_allowed_load eq ""} {
                    puts $outCap "DEBUG: Skipping $pin_name - missing load data"
                    continue
                }

                while {1.0*$current_load > 1.0*$max_allowed_load} {
                    set larger_cell [getNextSizeUp $libcellName]

                    if {$larger_cell eq "skip"} {
                        puts $outCap "DEBUG: Max size reached for [get_attribute $cellName full_name] ($libcellName)"
                        break
                    }

                    puts $outCap "DEBUG: Upsizing [get_attribute $cellName full_name] from $libcellName to $larger_cell"
                    size_cell $cellName $larger_cell
                    incr upSizeswapCnt

                    # set libcellName $larger_cell
                    set current_load [PtGetPinLoadCap $pin_name]
                    set max_allowed_load [PtGetPinMaxCap $pin_name]

                    if {1.0*$current_load <= 1.0*$max_allowed_load} {
                        puts $outCap "DEBUG: Violation fixed at $pin_name (Load: $current_load, Max: $max_allowed_load)"
                    }
                }
            }
        }

        # Forward Traversal (downsizing fanout cells when current cell is max-sized)
        set cellList [sort_collection [get_cells *] base_name]
        puts $outCap "INFO: Forward traversal processing [sizeof_collection $cellList] cells"

        foreach_in_collection cell_instance $cellList {
            set cellName [get_attri $cell_instance base_name]
            set libcell [get_lib_cells -of_objects $cellName]
            set libcellName [get_attribute $libcell base_name]

            # Only process if current cell is at max size
            if {![regexp {80$} $libcellName]} { continue }

            foreach_in_collection output_pin [getFanOutPins $cellName $outCap] {
                set pin_name [get_attribute $output_pin full_name]
                set net [get_nets -of_object $pin_name]
                set fanout_pins [getFanInPins $net $outCap]

                set current_load [PtGetPinLoadCap $pin_name]
                set max_allowed_load [PtGetPinMaxCap $pin_name]
                # ReportPinLoadCap  $outCap $cellName $pin_name $current_load $max_allowed_load

                foreach_in_collection fanout_pin $fanout_pins {
                    set fanout_cell [get_cells -of_object $fanout_pin]
                    set fanout_libcellName [get_attribute [get_lib_cells -of_objects $fanout_cell] base_name]

                    if {$current_load eq "" || $max_allowed_load eq ""} {
                        puts $outCap "DEBUG: Skipping [get_attribute $fanout_pin full_name] - missing load data"
                        continue
                    }

                    while {1.0*$current_load > 1.0*$max_allowed_load} {
                        set smaller_cell [getNextSizeDown $fanout_libcellName]

                        if {$smaller_cell eq "skip"} {
                            puts $outCap "DEBUG: Min size reached for fanout cell [get_attribute $fanout_cell full_name] ($fanout_libcellName)"
                            break
                        }

                        puts $outCap "DEBUG: Downsizing fanout cell [get_attribute $fanout_cell full_name] from $fanout_libcellName to $smaller_cell"
                        size_cell $fanout_cell $smaller_cell
                        incr downSizeswapCnt

                        set fanout_libcellName $smaller_cell
                        set current_load [PtGetPinLoadCap $pin_name]
                        set max_allowed_load [PtGetPinMaxCap $pin_name]

                        if {1.0*$current_load <= 1.0*$max_allowed_load} {
                            puts $outCap "DEBUG: Violation fixed at [get_attribute $output_pin full_name] (Load: $current_load, Max: $max_allowed_load)"
                        }
                    }
                }
            }
        }

        # Early exit if no violations remain
        set cap_vios [PtGetCapVio]
        if {[string match "*violations: 0 / 0 / 0" $cap_vios]} {
            puts $outCap "INFO: No capacitance violations detected after iteration $iter"
            break
        }
    }

    puts $outCap "\nSUMMARY:"
    puts $outCap "Total driver cells upsized: $upSizeswapCnt"
    puts $outCap "Total fanout cells downsized: $downSizeswapCnt"
    puts $outCap "Final capacitance violations: [PtGetCapVio]"
    close $outCap
}



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


