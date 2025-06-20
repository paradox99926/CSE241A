set design mpeg2_top

set qrc "ASAP7.tch"

set lib "asap7sc7p5t_AllVT_TT_nldm_201020.lib"

create_library_set -name LS_wc -timing ./lib/$lib 
create_op_cond -name OC_wc -library_file ./lib/$lib -P 1 -V 0.7 -T 25
create_rc_corner -name RC_wc_25 -T 25 -qx_tech_file $qrc

create_delay_corner -name DC_wc\
   -rc_corner RC_wc_25\
   -library_set LS_wc\
   -opcond_library slow\
   -opcond OC_wc

update_delay_corner -name DC_wc -power_domain PD1\
   -library_set LS_wc\
   -opcond_library slow\
   -opcond OC_wc


# define constraints
create_constraint_mode -name CM_base -sdc_files [list ${design}.sdc]

# define views
create_analysis_view -name AV_wc_off -constraint_mode CM_base -delay_corner DC_wc
create_analysis_view -name AV_wc_on  -constraint_mode CM_base  -delay_corner DC_wc

# active views
set_analysis_view -setup [list AV_wc_on ] -hold [list AV_wc_on ]

