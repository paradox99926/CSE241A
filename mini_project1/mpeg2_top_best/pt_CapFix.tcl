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



