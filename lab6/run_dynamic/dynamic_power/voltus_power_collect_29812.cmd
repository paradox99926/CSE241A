set_message -limit 20 
sxclDesign design ./dynamic_power
design rUseSfeDefParser  1
design rSuppressStdout  1
design calLef ./dynamic_power/voltus_dummy.lef
design calDef voltus_dummy.def
sxclPowerMeter ChipPwr design
create_result_json -dir {./dynamic_power}