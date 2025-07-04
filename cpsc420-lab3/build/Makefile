#=========================================================================
# Makefile for Verilog Packages
#=========================================================================
# This is a simple start to a much more sophisticated Verilog build
# system. For most packages, a developer will not need to make any
# changes to this file except to make sure that the subpkgs make variable
# correctly lists the desired subpackages to include in this package.
# Developers also need to make sure each subpackage makefile fragment
# (e.g., vc.mk) is uptodate with a list of all of the subpackage
# dependencies, Verilog source files, test source files, and program
# source files. The key targets for this Makefile are as follows:
#
#  - default   : build all programs
#  - check     : build and run all unit tests
#  - clean     : remove all generated content
#

#-------------------------------------------------------------------------
# Basic setup
#-------------------------------------------------------------------------

# Remove all default implicit rules since they can cause subtle bugs
# and they just make things run slower
.SUFFIXES:
% : %,v
% : RCS/%,v
% : RCS/%
% : s.%
% : SCCS/s.%

# Default is to build the prereqs of the all target (defined at bottom)
default : all
.PHONY : default

topdir = ..

#-------------------------------------------------------------------------
# List of subpackages
#-------------------------------------------------------------------------

subpkgs = \
  vc \
  imuldiv \
  mcparc \
  pv2stall \
  pv2byp \
  pv2dualfetch \
  pv2ssc \

#-------------------------------------------------------------------------
# List of Assembly Tests
#-------------------------------------------------------------------------

tests = \
  parcv1-addiu.vmh \
  parcv1-ori.vmh \
  parcv1-lui.vmh \
  parcv1-addu.vmh \
  parcv1-lw.vmh \
  parcv1-sw.vmh \
  parcv1-bne.vmh \
  parcv1-jal.vmh \
  parcv1-jr.vmh \
  parcv2-andi.vmh \
  parcv2-and.vmh \
  parcv2-beq.vmh \
  parcv2-bgez.vmh \
  parcv2-bgtz.vmh \
  parcv2-blez.vmh \
  parcv2-bltz.vmh \
  parcv2-divu.vmh \
  parcv2-div.vmh \
  parcv2-jalr.vmh \
  parcv2-j.vmh \
  parcv2-lbu.vmh \
  parcv2-lb.vmh \
  parcv2-lhu.vmh \
  parcv2-lh.vmh \
  parcv2-mul.vmh \
  parcv2-nor.vmh \
  parcv2-or.vmh \
  parcv2-remu.vmh \
  parcv2-rem.vmh \
  parcv2-sb.vmh \
  parcv2-sh.vmh \
  parcv2-sll.vmh \
  parcv2-sllv.vmh \
  parcv2-sltiu.vmh \
  parcv2-slti.vmh \
  parcv2-sltu.vmh \
  parcv2-slt.vmh \
  parcv2-sra.vmh \
  parcv2-srav.vmh \
  parcv2-srl.vmh \
  parcv2-srlv.vmh \
  parcv2-subu.vmh \
  parcv2-xori.vmh \
  parcv2-xor.vmh \

pv2stall_rtl_sim = pv2stall-sim
pv2stall_rtl_rand_sim = pv2stall-randdelay-sim
pv2byp_rtl_sim = pv2byp-sim
pv2byp_rtl_rand_sim = pv2byp-randdelay-sim
pv2dualfetch_rtl_sim = pv2dualfetch-sim
pv2dualfetch_rtl_rand_sim = pv2dualfetch-randdelay-sim
pv2ssc_rtl_sim = pv2ssc-sim
pv2ssc_rtl_rand_sim = pv2ssc-randdelay-sim

stall_tests_outs = $(patsubst %.vmh,%-stall.out,$(tests))
$(stall_tests_outs) : %-stall.out : %.vmh $(pv2stall_rtl_sim)
	./$(pv2stall_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

stall_tests_rand_outs = $(patsubst %.vmh,%-stall-rand.out,$(tests))
$(stall_tests_rand_outs) : %-stall-rand.out : %.vmh $(pv2stall_rtl_rand_sim)
	./$(pv2stall_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

byp_tests_outs = $(patsubst %.vmh,%-byp.out,$(tests))
$(byp_tests_outs) : %-byp.out : %.vmh $(pv2byp_rtl_sim)
	./$(pv2byp_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

byp_tests_rand_outs = $(patsubst %.vmh,%-byp-rand.out,$(tests))
$(byp_tests_rand_outs) : %-byp-rand.out : %.vmh $(pv2byp_rtl_rand_sim)
	./$(pv2byp_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

dualfetch_tests_outs = $(patsubst %.vmh,%-dualfetch.out,$(tests))
$(dualfetch_tests_outs) : %-dualfetch.out : %.vmh $(pv2dualfetch_rtl_sim)
	./$(pv2dualfetch_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

dualfetch_tests_rand_outs = $(patsubst %.vmh,%-dualfetch-rand.out,$(tests))
$(dualfetch_tests_rand_outs) : %-dualfetch-rand.out : %.vmh $(pv2dualfetch_rtl_rand_sim)
	./$(pv2dualfetch_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

ssc_tests_outs = $(patsubst %.vmh,%-ssc.out,$(tests))
$(ssc_tests_outs) : %-ssc.out : %.vmh $(pv2ssc_rtl_sim)
	./$(pv2ssc_rtl_sim) +stats=1 +vcd=1 +exe=$< > $@

ssc_tests_rand_outs = $(patsubst %.vmh,%-ssc-rand.out,$(tests))
$(ssc_tests_rand_outs) : %-ssc-rand.out : %.vmh $(pv2ssc_rtl_rand_sim)
	./$(pv2ssc_rtl_rand_sim) +stats=1 +vcd=1 +exe=$< > $@

check-asm-pv2stall : $(stall_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_tests_outs); echo;

check-asm-rand-pv2stall : $(stall_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_tests_rand_outs); echo;

check-asm-pv2byp : $(byp_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_tests_outs); echo;

check-asm-rand-pv2byp : $(byp_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_tests_rand_outs); echo;

check-asm-pv2dualfetch : $(dualfetch_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_tests_outs); echo;

check-asm-rand-pv2dualfetch : $(dualfetch_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_tests_rand_outs); echo;

check-asm-pv2ssc : $(ssc_tests_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_tests_outs); echo;

check-asm-rand-pv2ssc : $(ssc_tests_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_tests_rand_outs); echo;

junk += $(stall_tests_outs)
junk += $(stall_tests_rand_outs)
junk += $(byp_tests_outs)
junk += $(byp_tests_rand_outs)
junk += $(dualfetch_tests_outs)
junk += $(dualfetch_tests_rand_outs)
junk += $(ssc_tests_outs)
junk += $(ssc_tests_rand_outs)

#-------------------------------------------------------------------------
# List of Benchmarks
#-------------------------------------------------------------------------

bmarks = \
  ubmark-vvadd.vmh \
  ubmark-cmplx-mult.vmh \
  ubmark-masked-filter.vmh \
  ubmark-bin-search.vmh \

stall_bmarks_outs = $(patsubst %.vmh,%-stall.out,$(bmarks))
$(stall_bmarks_outs) : %-stall.out : %.vmh $(pv2stall_rtl_sim)
	./$(pv2stall_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

byp_bmarks_outs = $(patsubst %.vmh,%-byp.out,$(bmarks))
$(byp_bmarks_outs) : %-byp.out : %.vmh $(pv2byp_rtl_sim)
	./$(pv2byp_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

dualfetch_bmarks_outs = $(patsubst %.vmh,%-dualfetch.out,$(bmarks))
$(dualfetch_bmarks_outs) : %-dualfetch.out : %.vmh $(pv2dualfetch_rtl_sim)
	./$(pv2dualfetch_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

ssc_bmarks_outs = $(patsubst %.vmh,%-ssc.out,$(bmarks))
$(ssc_bmarks_outs) : %-ssc.out : %.vmh $(pv2ssc_rtl_sim)
	./$(pv2ssc_rtl_sim) +verbose=1 +vcd=1 +exe=$< > $@

run-bmark-pv2stall : $(stall_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_bmarks_outs); echo;

run-bmark-pv2byp : $(byp_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_bmarks_outs); echo;

run-bmark-pv2dualfetch : $(dualfetch_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_bmarks_outs); echo;

run-bmark-pv2ssc : $(ssc_bmarks_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_bmarks_outs); echo;

stall_bmarks_rand_outs = $(patsubst %.vmh,%-stall-rand.out,$(bmarks))
byp_bmarks_rand_outs = $(patsubst %.vmh,%-byp-rand.out,$(bmarks))
dualfetch_bmarks_rand_outs = $(patsubst %.vmh,%-dualfetch-rand.out,$(bmarks))
ssc_bmarks_rand_outs = $(patsubst %.vmh,%-ssc-rand.out,$(bmarks))

$(stall_bmarks_rand_outs) : %-stall-rand.out : %.vmh $(pv2stall_rtl_rand_sim)
	./$(pv2stall_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(byp_bmarks_rand_outs) : %-byp-rand.out : %.vmh $(pv2byp_rtl_rand_sim)
	./$(pv2byp_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(dualfetch_bmarks_rand_outs) : %-dualfetch-rand.out : %.vmh $(pv2dualfetch_rtl_rand_sim)
	./$(pv2dualfetch_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

$(ssc_bmarks_rand_outs) : %-ssc-rand.out : %.vmh $(pv2ssc_rtl_rand_sim)
	./$(pv2ssc_rtl_rand_sim) +verbose=1 +vcd=1 +exe=$< > $@

run-bmark-rand-pv2stall : $(stall_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(stall_bmarks_rand_outs); echo;

run-bmark-rand-pv2byp : $(byp_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(byp_bmarks_rand_outs); echo;

run-bmark-rand-pv2dualfetch : $(dualfetch_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(dualfetch_bmarks_rand_outs); echo;

run-bmark-rand-pv2ssc : $(ssc_bmarks_rand_outs)
	@echo; \
  perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.{8})\*{3}(.*)/' \
       $(ssc_bmarks_rand_outs); echo;

junk += $(stall_bmarks_outs)
junk += $(byp_bmarks_outs)
junk += $(dualfetch_bmarks_outs)
junk += $(ssc_bmarks_outs)

#-------------------------------------------------------------------------
# Programs
#-------------------------------------------------------------------------

COMP := iverilog
ifdef COMP_PATH
	COMP := $(COMP_PATH)
endif
COMP_FLAGS = -g2005 -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array

#-------------------------------------------------------------------------
# Makefile fragments from subpackages
#-------------------------------------------------------------------------

subpkgs_mk := \
  $(join $(addprefix $(topdir)/, $(subpkgs)), \
         $(patsubst %, /%.mk, $(subpkgs)))

-include $(subpkgs_mk)
VPATH := $(addprefix $(topdir)/, $(subpkgs))

VPATH += $(topdir)/tests/build/vmh
VPATH += $(topdir)/ubmark/build/vmh

#-------------------------------------------------------------------------
# Template for per subpackage rules
#-------------------------------------------------------------------------

# Helper template for collecting sources from subpackage dependencies

define subpkg_template_collect_deps
$(1)_deps_srcs += $$($(2)_srcs)
endef

# Main subpackage template

define subpkg_template

# Subpackage subdirectory

$(2)_dir := $$(addprefix $(topdir)/, $(1))

# Subpackage dependencies

$(2)_incs := $$(addprefix -I $(topdir)/, $$($(2)_deps))

$$(foreach dep,$$($(2)_deps), \
  $$(eval $$(call subpkg_template_collect_deps,$(2),$$(dep))))

# Build unit tests

$(2)_test_exes := $$(patsubst %.t.v,%-utst,$$($(2)_test_srcs))

$$($(2)_test_exes) : %-utst : $$($(2)_dir)/%.t.v $$($(2)_srcs) $$($(2)_deps_srcs)
	$(COMP) $(COMP_FLAGS) -o $$@ \
    -I $(topdir)/vc -I $(topdir)/$(2) $$($(2)_incs) $$<

$(2)_junk += $$($(2)_test_exes)

# Run unit tests

$(2)_test_outs := $$(addsuffix .out, $$($(2)_test_exes))

$$($(2)_test_outs) : %.out : %
	./$$< +verbose=2 > $$@

$(2)_junk += $$($(2)_test_outs)

# Build programs

$(2)_prog_exes := $$(patsubst %.v, %, $$($(2)_prog_srcs))

$$($(2)_prog_exes) : % : $$($(2)_dir)/%.v $$($(2)_srcs) $$($(2)_deps_srcs)
	$(COMP) $(COMP_FLAGS) -o $$@ \
    -I $(topdir)/$(2) $$($(2)_incs) $$<

$(2)_junk += $$($(2)_prog_exes)

# Other subpkg specific targets

all-$(1) : $$($(2)_prog_exes)

check-$(1) : $$($(2)_test_outs)
	@echo
	@grep -h -e "Entering Test Suite" -e "FAILED" $($(2)_test_outs)
	@echo;

clean-$(1) :
	rm -rf $$($(2)_junk)

.PHONY : all-$(1) check-$(1) clean-$(1)

# Update running variables

exes += $$($(2)_prog_exes)
outs += $$($(2)_test_outs)
junk += $$($(2)_junk)

endef

# Call template for each subpackage

$(foreach subpkg,$(subpkgs), \
  $(eval $(call subpkg_template,$(subpkg),$(subst -,_,$(subpkg)))))

#-------------------------------------------------------------------------
# Check
#-------------------------------------------------------------------------

check : $(outs)
	@echo
	@grep -h -e "Entering Test Suite" -e "FAILED" $(outs)
	@echo;

.PHONY : check

#-------------------------------------------------------------------------
# Default
#-------------------------------------------------------------------------

all : $(exes)
.PHONY : all

#-------------------------------------------------------------------------
# Makefile debugging
#-------------------------------------------------------------------------
# This handy rule will display the contents of any make variable by
# using the target debug-<varname>. So for example, make debug-junk will
# display the contents of the junk variable.

debug-% :
	@echo $* = $($*)

#-------------------------------------------------------------------------
# Clean up junk
#-------------------------------------------------------------------------

clean :
	rm -rf *~ \#* *.vcd $(junk)

.PHONY : clean

