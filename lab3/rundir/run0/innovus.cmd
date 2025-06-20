#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Thu Apr 24 17:48:30 2025                
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
win
is_common_ui_mode
restoreDesign /home/linux/ieng6/cs241asp25/cs241asp25bu/lab3/rundir/run0/route.enc.dat aes_cipher_top
set_interactive_constraint_modes {CON}
set_max_transition 0.22 -data_path [get_clocks clk]
report_constraint -drv_violation_type max_transition -all_violators > pre_vios.rpt
gpsPrivate::masterAndSlaveCPU
gpsPrivate::masterAndSlaveCPU
gpsPrivate::masterAndSlaveCPU
optDesign -postRoute -drv
report_timing -max_paths 5 > ${design}.post_route.timing.rpt
report_power -outfile aes_cipher_top.post_route.power.rpt
summaryReport -nohtml -outfile aes_cipher_top.post_route.summary.rpt
report_constraint -drv_violation_type max_transition -all_violators > post_vios.rpt
selectWire 241.2500 61.9500 241.3500 68.0500 4 us13/n780
