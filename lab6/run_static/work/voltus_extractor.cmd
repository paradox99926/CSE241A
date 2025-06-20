setvar log_file ./work/voltus_extractor.log
setvar output_cache_directory_name /tmp/ssv_tmpdir_5948_ce4f5cdb-5fec-482b-ba68-73838f9d37c1_AuqEx6/zx_tmp_ieng6-ece-08.ucsd.edu_6763
setvar library_name techonly.cl
setvar output_directory_name ./work
setvar output_file_name TopLevelPGDB
setvar output_multi_pgdb true
setvar max_error_messages 100
setvar max_resistor_length 800
setvar hierarchy_char /
layout_file /home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/mpeg2_top.def
setvar exec_token "/home/linux/ieng6/cs241asp25/cs241asp25bu/lab6/run_static/mpeg2_top.def"
setvar enable_signal_via_overhang false
setvar extraction_mode signoff
setvar zx_multinet_extraction true
extraction_type all none
setvar output_wlt drawn
setvar use_hpt_leqnets_info true
label port VSSvsrc1 17.7160 17.7160 Pad
label port VSSvsrc2 17.7160 41.7160 Pad
label port VSSvsrc3 41.7160 17.7160 Pad
label port VSSvsrc4 41.7160 41.7160 Pad
setvar output_wlt drawn
setvar use_hpt_leqnets_info true
label port VDDvsrc1 5.7160 5.7160 Pad
label port VDDvsrc2 5.7160 29.7160 Pad
label port VDDvsrc3 29.7160 5.7160 Pad
label port VDDvsrc4 29.7160 29.7160 Pad
hierarchical_path_tracer pgnet_table ./work/all.pgnets
setvar output_def false
setvar cluster_via_size 4
setvar cluster_via1_maximum true
setvar def_merge_supply_shorts false
setvar promote_ports true
setvar max_cpu 4
setvar tech_file ASAP7.tch
setvar create_seg_length_resistors true
setvar density_check_method database
setvar sfedb_path ./work/SFEDB
setvar enable_binary_inst_pgdb true
setvar keep_log_file false
extraction_type pattern {VSS} r_only 
hierarchical_path_tracer netinst_table ./work/VSS.netinst
hierarchical_path_tracer cell_table ./work/VSS.cellinst
extraction_type pattern {VDD} r_only 
hierarchical_path_tracer netinst_table ./work/VDD.netinst
hierarchical_path_tracer cell_table ./work/VDD.cellinst
