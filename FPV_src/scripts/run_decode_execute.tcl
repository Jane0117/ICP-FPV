set TOP decode_execute_top
set SVA_FILES "../sva/decode_execute_props.sva ../sva/bind_decode_execute.sva"
puts "TOP=$TOP"
puts "SVA_FILES=$SVA_FILES"
# Forwarding inputs are unconstrained unless assumed in SVA.
source run_common.tcl

