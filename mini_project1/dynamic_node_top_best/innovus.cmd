#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sat May 24 13:38:20 2025                
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
set init_verilog ./dynamic_node_top.v
set init_design_netlisttype Verilog
set init_design_settop 1
set init_top_cell dynamic_node_top
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
defIn dynamic_node_top.def
setAnalysisMode -analysisType onChipVariation -cppr both
setDelayCalMode -reset
setDelayCalMode -SIAware true
setExtractRCMode -coupled true -engine postRoute
report_timing
setEcoMode -refinePlace true
setEcoMode -batchMode true
ecoChangeCell -inst FE_OCPC2404_n18959 -cell in01m20
ecoChangeCell -inst FE_OCPC2407_n18959 -cell in01m10
ecoChangeCell -inst FE_OCPC2411_n18959 -cell in01m10
ecoChangeCell -inst FE_OCPC2413_n19499_dup -cell in01m20
ecoChangeCell -inst FE_OCPC2414_n19499 -cell in01m20
ecoChangeCell -inst FE_OCPC2418_proc_input_NIB_head_ptr_f_1 -cell in01m40
ecoChangeCell -inst FE_OCPC2423_FE_OFN186_n24453 -cell in01m20
ecoChangeCell -inst FE_OCPC2433_west_input_NIB_head_ptr_f_1 -cell in01m40
ecoChangeCell -inst FE_OCPC2434_west_input_NIB_head_ptr_f_1 -cell in01m40
ecoChangeCell -inst FE_OCPC2467_n24342 -cell in01m10
ecoChangeCell -inst FE_OCPC2481_FE_OFN97_n21865 -cell in01m20
ecoChangeCell -inst FE_OCPC2539_west_input_NIB_head_ptr_f_0 -cell in01m20
ecoChangeCell -inst FE_OCPC2540_west_input_NIB_head_ptr_f_0 -cell in01m20
ecoChangeCell -inst FE_OCPC2541_west_input_NIB_head_ptr_f_0 -cell in01m20
ecoChangeCell -inst FE_OCPC2543_west_input_NIB_head_ptr_f_0 -cell in01m40
ecoChangeCell -inst FE_OCPC2582_n18648 -cell in01m20
ecoChangeCell -inst FE_OCPC2583_n18648 -cell in01m40
ecoChangeCell -inst FE_OCPC2584_n18648 -cell in01m40
ecoChangeCell -inst FE_OCPC2584_n18648_dup -cell in01m40
ecoChangeCell -inst FE_OCPC2585_n18648 -cell in01m20
ecoChangeCell -inst FE_OCPC2604_n19306 -cell in01m40
ecoChangeCell -inst FE_OCPC2604_n19306_dup -cell in01m20
ecoChangeCell -inst FE_OCPC2610_n19306 -cell in01m40
ecoChangeCell -inst FE_OCPC2610_n19306_dup -cell in01m40
ecoChangeCell -inst FE_OCPC2611_n19504 -cell in01m20
ecoChangeCell -inst FE_OCPC2612_n19504 -cell in01m40
ecoChangeCell -inst FE_OCPC2613_n19504 -cell in01m40
ecoChangeCell -inst FE_OCPC2621_n24342 -cell in01m40
ecoChangeCell -inst FE_OCPC2622_n24342 -cell in01m10
ecoChangeCell -inst FE_OCPC2623_n19498 -cell in01m20
ecoChangeCell -inst FE_OCPC2625_n19498 -cell in01m40
ecoChangeCell -inst FE_OCPC2626_n19980 -cell in01m40
ecoChangeCell -inst FE_OCPC2627_n19550 -cell in01m20
ecoChangeCell -inst FE_OCPC2627_n19550_dup -cell in01m40
ecoChangeCell -inst FE_OCPC2628_n19914 -cell in01m40
ecoChangeCell -inst FE_OCPC2631_n19914 -cell in01m10
ecoChangeCell -inst FE_OCPC2632_n19914 -cell in01m20
ecoChangeCell -inst FE_OCPC2633_n19914 -cell in01m40
ecoChangeCell -inst FE_OCPC2635_n24965 -cell in01m40
ecoChangeCell -inst FE_OCPC2652_n19071 -cell in01m20
ecoChangeCell -inst FE_OCPC2653_n19071 -cell in01m20
ecoChangeCell -inst FE_OCPC2654_n19071 -cell in01m40
ecoChangeCell -inst FE_OCPC2658_n19501 -cell in01m20
ecoChangeCell -inst FE_OCPC2659_n19501 -cell in01m20
ecoChangeCell -inst FE_OCPC2660_n19501 -cell in01m20
ecoChangeCell -inst FE_OCPC2661_n21747 -cell in01m40
ecoChangeCell -inst FE_OCPC2662_n19595 -cell in01m20
ecoChangeCell -inst FE_OCPC2674_n19595 -cell in01m40
ecoChangeCell -inst FE_OCPC2676_n18039 -cell in01m20
ecoChangeCell -inst FE_OCPC2688_n18039 -cell in01m10
ecoChangeCell -inst FE_OCPC2699_n21739 -cell in01m40
ecoChangeCell -inst FE_OCPC2700_n19530 -cell in01m40
ecoChangeCell -inst FE_OCPC2701_proc_input_NIB_head_ptr_f_2 -cell in01m20
ecoChangeCell -inst FE_OCPC2704_n19500 -cell in01m20
ecoChangeCell -inst FE_OCPC2713_n19500 -cell in01m20
ecoChangeCell -inst FE_OFC1105_n18131 -cell in01m40
ecoChangeCell -inst FE_OFC1112_n22273 -cell in01m10
ecoChangeCell -inst FE_OFC1119_n20814 -cell in01m10
ecoChangeCell -inst FE_OFC1147_n23737 -cell in01m10
ecoChangeCell -inst FE_OFC1150_n21174 -cell in01m08
ecoChangeCell -inst FE_OFC1161_n21219 -cell in01m08
ecoChangeCell -inst FE_OFC1162_n21219 -cell in01m08
ecoChangeCell -inst FE_OFC1170_n23050 -cell in01m10
ecoChangeCell -inst FE_OFC1178_n20655 -cell in01m08
ecoChangeCell -inst FE_OFC1193_east_input_NIB_head_ptr_f_0 -cell in01m20
ecoChangeCell -inst FE_OFC1200_n20152 -cell in01m20
ecoChangeCell -inst FE_OFC1205_n21052 -cell in01m08
ecoChangeCell -inst FE_OFC1206_n18683 -cell in01m20
ecoChangeCell -inst FE_OFC1207_n18683 -cell in01m20
ecoChangeCell -inst FE_OFC1209_n18683 -cell in01m10
ecoChangeCell -inst FE_OFC1210_n18683 -cell in01m20
ecoChangeCell -inst FE_OFC1211_north_input_NIB_head_ptr_f_0 -cell in01m20
ecoChangeCell -inst FE_OFC1228_n21914 -cell in01m10
ecoChangeCell -inst FE_OFC1265_n23761 -cell in01m08
ecoChangeCell -inst FE_OFC1267_n23761 -cell in01m10
ecoChangeCell -inst FE_OFC1273_n23045 -cell in01m10
ecoChangeCell -inst FE_OFC1276_n20971 -cell in01m10
ecoChangeCell -inst FE_OFC1292_n21069 -cell in01m08
ecoChangeCell -inst FE_OFC1299_n19075 -cell in01m20
ecoChangeCell -inst FE_OFC1302_n19075 -cell in01m10
ecoChangeCell -inst FE_OFC1305_n19075 -cell in01m20
ecoChangeCell -inst FE_OFC1345_n23101 -cell in01m10
ecoChangeCell -inst FE_OFC1348_n20995 -cell in01m10
ecoChangeCell -inst FE_OFC1349_n20995 -cell in01m10
ecoChangeCell -inst FE_OFC1350_east_input_NIB_head_ptr_f_1 -cell in01m20
ecoChangeCell -inst FE_OFC1364_n23089 -cell in01m10
ecoChangeCell -inst FE_OFC1381_n22778 -cell in01m10
ecoChangeCell -inst FE_OFC1383_n22084 -cell in01m08
ecoChangeCell -inst FE_OFC1384_n22084 -cell in01m10
ecoChangeCell -inst FE_OFC1397_n20858 -cell in01m10
ecoChangeCell -inst FE_OFC1400_n22139 -cell in01m08
ecoChangeCell -inst FE_OFC1401_n22139 -cell in01m10
ecoChangeCell -inst FE_OFC1523_myChipID_f_7 -cell in01m10
ecoChangeCell -inst FE_OFC1532_myChipID_f_8 -cell in01m10
ecoChangeCell -inst FE_OFC1535_n21667 -cell in01m10
ecoChangeCell -inst FE_OFC1579_n22517 -cell in01m10
ecoChangeCell -inst FE_OFC1633_myChipID_f_13 -cell in01m10
ecoChangeCell -inst FE_OFC1641_n19871 -cell in01m10
ecoChangeCell -inst FE_OFC1643_n20501 -cell in01m10
ecoChangeCell -inst FE_OFC1656_reset -cell in01m10
ecoChangeCell -inst FE_OFC1658_reset -cell in01m10
ecoChangeCell -inst FE_OFC1688_n21944 -cell in01m10
ecoChangeCell -inst FE_OFC1700_n18377 -cell in01m20
ecoChangeCell -inst FE_OFC1702_n22097 -cell in01m08
ecoChangeCell -inst FE_OFC1703_n22097 -cell in01m08
ecoChangeCell -inst FE_OFC1708_n23739 -cell in01m10
ecoChangeCell -inst FE_OFC1726_n19507 -cell in01m20
ecoChangeCell -inst FE_OFC1727_n21745 -cell in01m20
ecoChangeCell -inst FE_OFC1739_n17934 -cell in01m20
ecoChangeCell -inst FE_OFC1740_n17934 -cell in01m20
ecoChangeCell -inst FE_OFC1755_n19932 -cell in01m20
ecoChangeCell -inst FE_OFC1756_n19932 -cell in01m10
ecoChangeCell -inst FE_OFC1757_n19932 -cell in01m20
ecoChangeCell -inst FE_OFC1758_n19932 -cell in01m10
ecoChangeCell -inst FE_OFC1759_n19932 -cell in01m20
ecoChangeCell -inst FE_OFC1761_north_input_NIB_head_ptr_f_1_dup -cell in01m40
ecoChangeCell -inst FE_OFC1796_n18815 -cell in01m20
ecoChangeCell -inst FE_OFC1797_n18815 -cell in01m20
ecoChangeCell -inst FE_OFC1798_n18815 -cell in01m20
ecoChangeCell -inst FE_OFC1798_n18815_dup -cell in01m20
ecoChangeCell -inst FE_OFC1799_n18815 -cell in01m20
ecoChangeCell -inst FE_OFC1800_n18815_dup -cell in01m20
ecoChangeCell -inst FE_OFC1805_south_input_NIB_head_ptr_f_1 -cell in01m20
ecoChangeCell -inst FE_OFC1805_south_input_NIB_head_ptr_f_1_dup -cell in01m40
ecoChangeCell -inst FE_OFC1821_n20933 -cell in01m08
ecoChangeCell -inst FE_OFC1873_n19225 -cell in01m10
ecoChangeCell -inst FE_OFC1875_n19225 -cell in01m10
ecoChangeCell -inst FE_OFC1875_n19225_dup -cell in01m20
ecoChangeCell -inst FE_OFC1885_n19073 -cell in01m20
ecoChangeCell -inst FE_OFC1886_n19073 -cell in01m20
ecoChangeCell -inst FE_OFC1889_n19073 -cell in01m10
ecoChangeCell -inst FE_OFC1891_n19073 -cell in01m20
ecoChangeCell -inst FE_OFC1896_n21748 -cell in01m20
ecoChangeCell -inst FE_OFC1903_reset -cell in01m06
ecoChangeCell -inst FE_OFC1907_n18960 -cell in01m20
ecoChangeCell -inst FE_OFC1908_n18960 -cell in01m20
ecoChangeCell -inst FE_OFC1911_n18960 -cell in01m40
ecoChangeCell -inst FE_OFC1915_n18762 -cell in01m20
ecoChangeCell -inst FE_OFC1990_myChipID_f_10 -cell in01m10
ecoChangeCell -inst FE_OFC2027_n19482 -cell in01m10
ecoChangeCell -inst FE_OFC2032_proc_input_NIB_head_ptr_f_3 -cell in01m20
ecoChangeCell -inst FE_OFC2036_n21747 -cell in01m20
ecoChangeCell -inst FE_OFC2115_n19655 -cell in01m20
ecoChangeCell -inst FE_OFC2119_n19655 -cell in01m20
ecoChangeCell -inst FE_OFC2121_myChipID_f_4 -cell in01m10
ecoChangeCell -inst FE_OFC2132_n19530 -cell in01m20
ecoChangeCell -inst FE_OFC2199_n19508 -cell in01m20
ecoChangeCell -inst FE_OFC2260_n19508 -cell in01m20
ecoChangeCell -inst FE_OFC2260_n19508_dup -cell in01m20
ecoChangeCell -inst FE_OFC2263_n19508 -cell in01m40
ecoChangeCell -inst FE_OFC2276_proc_input_NIB_head_ptr_f_0 -cell in01m40
ecoChangeCell -inst FE_OFC2279_n17814 -cell in01m20
ecoChangeCell -inst FE_OFC2281_n17814 -cell in01m20
ecoChangeCell -inst FE_OFC2288_n17814 -cell in01m20
ecoChangeCell -inst FE_OFC2290_n19372 -cell in01m10
ecoChangeCell -inst FE_OFC2292_n18151 -cell in01m20
ecoChangeCell -inst FE_OFC2293_n18151 -cell in01m20
ecoChangeCell -inst FE_OFC2335_FE_OFN25605_n21944 -cell in01m10
ecoChangeCell -inst FE_OFC2339_FE_OFN25605_n21944 -cell in01m10
ecoChangeCell -inst FE_OFC2356_FE_OFN1077_n17766 -cell in01m08
ecoChangeCell -inst FE_OFC2365_FE_OFN1077_n17766 -cell in01m08
ecoChangeCell -inst FE_OFC2374_FE_OFN582_n25619 -cell in01m10
ecoChangeCell -inst FE_OFC2377_FE_OFN448_n23236 -cell in01m10
ecoChangeCell -inst FE_OFC2379_FE_OFN448_n23236 -cell in01m10
ecoChangeCell -inst FE_OFC2382_n17770 -cell in01m10
ecoChangeCell -inst FE_OFC2506_FE_OFN24766_n21069 -cell in01m08
ecoChangeCell -inst FE_OFC2516_n25842 -cell in01m10
ecoChangeCell -inst FE_OFC2520_n19446 -cell in01m10
ecoChangeCell -inst FE_OFC2531_n25395 -cell in01m10
ecoChangeCell -inst FE_RC_16_0 -cell ao22m08
ecoChangeCell -inst FE_RC_39_0 -cell oa22m10
ecoChangeCell -inst FE_RC_51_0 -cell ao22m10
ecoChangeCell -inst FE_RC_54_0 -cell oa22m10
ecoChangeCell -inst FE_RC_56_0 -cell ao22m10
ecoChangeCell -inst FE_RC_5_0 -cell ao12m08
ecoChangeCell -inst FE_RC_62_0 -cell ao22m10
ecoChangeCell -inst FE_RC_69_0 -cell ao22m10
ecoChangeCell -inst FE_RC_75_0 -cell ao12m06
ecoChangeCell -inst FE_RC_76_0 -cell oa22m10
ecoChangeCell -inst FE_RC_77_0 -cell ao22m08
ecoChangeCell -inst FE_RC_78_0 -cell ao22m08
ecoChangeCell -inst FE_RC_83_0 -cell ao22m08
ecoChangeCell -inst FE_RC_90_0 -cell ao22m08
ecoChangeCell -inst FE_RC_91_0 -cell ao22m08
ecoChangeCell -inst FE_RC_98_0 -cell ao22m10
ecoChangeCell -inst U18436 -cell na03m08
ecoChangeCell -inst FE_RC_55_0 -cell ao22s20
ecoChangeCell -inst FE_RC_33_0 -cell ao22s20
ecoChangeCell -inst FE_RC_61_0 -cell ao22s20
ecoChangeCell -inst FE_RC_38_0 -cell ao22s20
ecoChangeCell -inst FE_RC_46_0 -cell na04s20
ecoChangeCell -inst FE_RC_84_0 -cell ao22s10
ecoChangeCell -inst FE_OFC2183_n20506 -cell in01s40
setEcoMode -batchMode false
routeDesign
report_timing
saveNetlist dynamic_node_top_eco.v
rcOut -excNetFile excNet.rpt -spef dynamic_node_top_eco.spef
defOut -routing dynamic_node_top_eco.def
