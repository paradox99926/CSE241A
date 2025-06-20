set design [get_attri [current_design] full_name]
set outFp [open ${design}_sizing.rpt w]

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

set cellList [sort_collection [get_cells *] base_name]
# set WNS_thres 80
set VtswapCnt 0
set SizeswapCnt 0
# foreach_in_collection cell $cellList {
#     set cellName [get_attri $cell base_name]
#     set libcell [get_lib_cells -of_objects $cellName]
#     set libcellName [get_attri $libcell base_name]
#     if {$libcellName == "ms00f80"} {
#         continue
#     }

#     # Vt cell swap: try HVT('s') first, if fails try MVT('m')
#     if { [regexp {[a-z][a-z][0-9][0-9]f[0-9][0-9]} $libcellName] } {
#         set hvtLibcellName [string replace $libcellName 4 4 s]
#         set mvtLibcellName [string replace $libcellName 4 4 m]
#         # First try HVT
#         size_cell $cellName $hvtLibcellName
#         set newWNS [ PtWorstSlack clk ]
#         if { $newWNS < $WNS_thres } {
#             # Fallback to MVT if HVT fails
#             size_cell $cellName $mvtLibcellName
#             set recWNS [ PtWorstSlack clk ]
#             if { $recWNS < $WNS_thres } {
#                 # Revert to original if both fail
#                 size_cell $cellName $libcellName
#             } else {
#                 incr VtswapCnt
#                 puts $outFp "- cell ${cellName} Vt-swapped to MVT: $mvtLibcellName"
#             }
#         } else {
#             incr VtswapCnt
#             puts $outFp "- cell ${cellName} Vt-swapped to HVT: $hvtLibcellName"
#         }
#     }

#     # Cell size swap: try size 02 first, if fails try size 04 (with original size 08 as fallback)
#     if { [regexp {[a-z][a-z][0-9][0-9][smf]08} $libcellName] } {
#         set smallestLibcellName [string replace $libcellName 5 6 "02"]
#         set mediumLibcellName [string replace $libcellName 5 6 "04"]
#         # First try smallest size (02)
#         size_cell $cellName $smallestLibcellName
#         set newWNS [ PtWorstSlack clk ]
#         if { $newWNS < $WNS_thres } {
#             # Fallback to medium size (04) if smallest fails
#             size_cell $cellName $mediumLibcellName
#             set recWNS [ PtWorstSlack clk ]
#             if { $recWNS < $WNS_thres } {
#                 # Revert to original size (08) if both fail
#                 size_cell $cellName $libcellName
#             } else {
#                 incr SizeswapCnt
#                 puts $outFp "- cell ${cellName} size-swapped to medium: $mediumLibcellName"
#             }
#         } else {
#             incr SizeswapCnt
#             puts $outFp "- cell ${cellName} size-swapped to smallest: $smallestLibcellName"
#         }
#     }
# }




SGGS $design
set maxCap_ratio 0.8
FixCapacitanceViolations $design $maxCap_ratio

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
puts $outFp "#Vt cell swaps:\t${VtswapCnt}"
puts $outFp "#Cell size swaps:\t${SizeswapCnt}"
puts $outFp "Leakage improvment\t${improvment} %"

close $outFp


