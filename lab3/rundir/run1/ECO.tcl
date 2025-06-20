setEcoMode -updateTiming false
setEcoMode -refinePlace false -honorDontUse false -batchMode true -honorDontTouch false -honorFixedStatus false

set beginpoint_name {
    us11/U968     
    U968   
    FE_RC_2394_0   
}

foreach inst_name $beginpoint_name {
    set cell_name [dbget [dbget top.insts.name $inst_name -p].cell.name]
    if {[regexp ULVT $cell_name]} {
    } elseif {[regexp LVT $cell_name]} {
        set newcell_name [regsub LVT $cell_name ULVT]
        ecoChangeCell -inst $inst_name -cell $newcell_name
    } elseif {![regexp LVT $cell_name]} {
        set newcell_name ${cell_name}ULVT
        ecoChangeCell -inst $inst_name -cell $newcell_name
    }
}