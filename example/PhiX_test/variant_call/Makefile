# This makefile was automatically generated by configureWorkflow.pl
#
# Please do not edit.

script_dir := /TBI/Tools/isaac_variant_caller/libexec
call_script := $(script_dir)/callSmallVariants.pl
finish_script := $(script_dir)/consolidateResults.pl

config_file := /TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test/variant_call/config/run.config.ini

analysis_dir := /TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test/variant_call
results_dir := $(analysis_dir)/results


complete_tag := task.complete

finish_task := $(analysis_dir)/$(complete_tag)

get_chrom_dir = $(analysis_dir)/chromosomes/$1
get_bin_task = $(call get_chrom_dir,$1)/bins/$2/$(complete_tag)



all: $(finish_task)
	@$(print_success)


define print_success
echo;\
echo Analysis complete. Final gVCF output can be found in $(results_dir);\
echo
endef


# top level results target:
#
$(finish_task):
	perl $(finish_script) --config=$(config_file) && touch $@


# chromosome targets:
#

# chromosome bin targets:
#
chrom_phix_bin_0000_task := $(call get_bin_task,phix,0000)
$(finish_task): $(chrom_phix_bin_0000_task)
$(chrom_phix_bin_0000_task):
	perl $(call_script) --config=$(config_file) --chrom=phix --bin=0000 && touch $@

