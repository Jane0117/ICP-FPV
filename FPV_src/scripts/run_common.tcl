#------------------------------------------------------------
# VC Formal FPV - common flow
#------------------------------------------------------------

set_fml_appmode FPV

# IMPORTANT: use quotes so Tcl expands $SVA_FILES
analyze -format sverilog \
  -vcs "-f ../design/filelist +define+INLINE_SVA ../sva/ref_model_pkg.sv $SVA_FILES"

elaborate $TOP -sva

create_clock clk -period 10
create_reset reset_n -sense low

sim_run -stable
sim_save_reset

check_fv -block
report_fv -list > results_${TOP}.txt

