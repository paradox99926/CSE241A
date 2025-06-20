#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sat May 24 16:55:34 2025                
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
set init_pwr_net VDD
set init_gnd_net VSS
set init_verilog ../usb_phy/usb_phy.v
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell usb_phy
set init_lef_file /home/linux/ieng6/cs241asp25/public/data/libraries/techfiles/contest.lef
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
defIn ../usb_phy/usb_phy.def
setAnalysisMode -analysisType onChipVariation -cppr both
setDelayCalMode -reset
setDelayCalMode -SIAware true
setExtractRCMode -coupled true -engine postRoute
report_timing
setEcoMode -refinePlace true
setEcoMode -batchMode true
ecoChangeCell -inst U407 -cell no02s02
ecoChangeCell -inst U408 -cell na02s01
ecoChangeCell -inst U409 -cell ao12m01
ecoChangeCell -inst U410 -cell na03s01
ecoChangeCell -inst U411 -cell na03s02
ecoChangeCell -inst U413 -cell no02s02
ecoChangeCell -inst U415 -cell no02s02
ecoChangeCell -inst U417 -cell na02s03
ecoChangeCell -inst U421 -cell no02s02
ecoChangeCell -inst U425 -cell no04m06
ecoChangeCell -inst U430 -cell na02s02
ecoChangeCell -inst U431 -cell na02s02
ecoChangeCell -inst U434 -cell na02s02
ecoChangeCell -inst U437 -cell na02m08
ecoChangeCell -inst U439 -cell in01s02
ecoChangeCell -inst U444 -cell no02s02
ecoChangeCell -inst U446 -cell in01s01
ecoChangeCell -inst U447 -cell oa12s02
ecoChangeCell -inst U451 -cell na03s02
ecoChangeCell -inst U452 -cell no03m03
ecoChangeCell -inst U453 -cell oa22s01
ecoChangeCell -inst U454 -cell oa22s01
ecoChangeCell -inst U457 -cell oa12m01
ecoChangeCell -inst U465 -cell in01m01
ecoChangeCell -inst U466 -cell in01m02
ecoChangeCell -inst U468 -cell na03s02
ecoChangeCell -inst U471 -cell oa12s02
ecoChangeCell -inst U473 -cell oa12s01
ecoChangeCell -inst U474 -cell oa12s01
ecoChangeCell -inst U476 -cell oa12s01
ecoChangeCell -inst U478 -cell oa12s01
ecoChangeCell -inst U480 -cell no02s02
ecoChangeCell -inst U482 -cell no04m02
ecoChangeCell -inst U489 -cell oa22m02
ecoChangeCell -inst U491 -cell oa12m02
ecoChangeCell -inst U492 -cell ao12m02
ecoChangeCell -inst U495 -cell ao12m01
ecoChangeCell -inst U501 -cell no02m02
ecoChangeCell -inst U512 -cell na03s02
ecoChangeCell -inst U535 -cell in01m02
ecoChangeCell -inst U551 -cell na03m02
ecoChangeCell -inst U552 -cell in01m02
ecoChangeCell -inst U613 -cell in01m01
ecoChangeCell -inst U440 -cell ao12s02
ecoChangeCell -inst U472 -cell ao22s02
ecoChangeCell -inst U436 -cell oa12s02
ecoChangeCell -inst U481 -cell ao12s02
ecoChangeCell -inst U435 -cell no04s02
ecoChangeCell -inst U456 -cell ao12s02
ecoChangeCell -inst U687 -cell ao22s01
ecoChangeCell -inst U710 -cell ao22s01
ecoChangeCell -inst U708 -cell ao22s01
ecoChangeCell -inst U448 -cell ao12s02
ecoChangeCell -inst U718 -cell no02s01
ecoChangeCell -inst U688 -cell no02s01
ecoChangeCell -inst U460 -cell oa22s01
ecoChangeCell -inst U657 -cell ao22s01
ecoChangeCell -inst U418 -cell ao12s02
ecoChangeCell -inst U716 -cell na02s01
ecoChangeCell -inst U470 -cell oa22s01
ecoChangeCell -inst U500 -cell na03s02
ecoChangeCell -inst U412 -cell ao22s01
ecoChangeCell -inst U690 -cell oa22s01
ecoChangeCell -inst U694 -cell oa22s01
ecoChangeCell -inst U486 -cell ao22s01
ecoChangeCell -inst U722 -cell ao12s01
ecoChangeCell -inst U744 -cell oa12s01
ecoChangeCell -inst U704 -cell ao22s01
ecoChangeCell -inst U660 -cell oa12s01
ecoChangeCell -inst U643 -cell oa12s01
ecoChangeCell -inst U461 -cell ao12s01
ecoChangeCell -inst U475 -cell na02s01
ecoChangeCell -inst U477 -cell na02s01
ecoChangeCell -inst U479 -cell na02s01
ecoChangeCell -inst U441 -cell na02s02
ecoChangeCell -inst U693 -cell na03s01
ecoChangeCell -inst U662 -cell ao12s01
ecoChangeCell -inst U487 -cell in01s02
ecoChangeCell -inst U422 -cell no04s04
ecoChangeCell -inst U483 -cell no02s02
ecoChangeCell -inst U628 -cell na02s02
ecoChangeCell -inst U637 -cell na02s01
ecoChangeCell -inst U571 -cell no02s02
ecoChangeCell -inst U667 -cell no02s02
ecoChangeCell -inst U625 -cell no02s01
ecoChangeCell -inst U442 -cell no02s01
ecoChangeCell -inst U484 -cell ao12s01
ecoChangeCell -inst U420 -cell na02s01
ecoChangeCell -inst U424 -cell no02s04
ecoChangeCell -inst U458 -cell no02s03
ecoChangeCell -inst U450 -cell in01s02
ecoChangeCell -inst U443 -cell no02s04
ecoChangeCell -inst U553 -cell no02s02
ecoChangeCell -inst U445 -cell in01s01
ecoChangeCell -inst U648 -cell in01s01
ecoChangeCell -inst U462 -cell na02s03
ecoChangeCell -inst U459 -cell na02s02
ecoChangeCell -inst U533 -cell in01s02
ecoChangeCell -inst U532 -cell no02s04
ecoChangeCell -inst U463 -cell no02s01
ecoChangeCell -inst U724 -cell no02s02
ecoChangeCell -inst U414 -cell no02s02
ecoChangeCell -inst U423 -cell na02s02
ecoChangeCell -inst U490 -cell no02s02
ecoChangeCell -inst FE_OFC1_fs_ce -cell in01s04
ecoChangeCell -inst U614 -cell in01s01
ecoChangeCell -inst U498 -cell in01s01
setEcoMode -batchMode false
routeDesign
report_timing
saveNetlist usb_phy_eco.v
rcOut -excNetFile excNet.rpt -spef usb_phy_eco.spef
defOut -routing usb_phy_eco.def
