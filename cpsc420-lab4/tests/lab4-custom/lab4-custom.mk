#=========================================================================
# lab4-custom.mk
#=========================================================================
# This is the makefile for the custom lab4 tests.

lab4_custom_tests = \
  commit-order-test \
  rob-bypass-test \
  waw-test \
  better-ipc-test \

lab4_custom_asm_tests = $(filter-out $(lab4_custom_debug_tests), $(lab4_custom_tests))

lab4_custom_asm_test_srcs    = $(addsuffix .S,  $(lab4_custom_asm_tests))
lab4_custom_asm_test_objs    = $(addsuffix .o,  $(lab4_custom_asm_tests))
lab4_custom_asm_test_dumps   = $(addsuffix .d,  $(lab4_custom_asm_tests))
lab4_custom_asm_test_vmhs    = $(addsuffix .vmh,$(lab4_custom_asm_tests))
lab4_custom_asm_test_vcdgzs  = $(addsuffix .vcd.gz,$(lab4_custom_asm_tests))
lab4_custom_asm_test_vpds    = $(addsuffix .vpd,$(lab4_custom_asm_tests))
lab4_custom_asm_test_bin     = $(addsuffix .bin,$(lab4_custom_asm_tests))

lab4_custom_debug_test_srcs    = $(addsuffix .S,  $(lab4_custom_debug_tests))
lab4_custom_debug_test_objs    = $(addsuffix .o,  $(lab4_custom_debug_tests))
lab4_custom_debug_test_dumps   = $(addsuffix .d,  $(lab4_custom_debug_tests))
lab4_custom_debug_test_vmhs    = $(addsuffix .vmh,$(lab4_custom_debug_tests))
lab4_custom_debug_test_vcdgzs  = $(addsuffix .vcd.gz,$(lab4_custom_debug_tests))
lab4_custom_debug_test_vpds    = $(addsuffix .vpd,$(lab4_custom_debug_tests))
lab4_custom_debug_test_bin     = $(addsuffix .bin,$(lab4_custom_debug_tests))

lab4_custom_srcs := $(lab4_custom_asm_test_srcs) $(lab4_custom_debug_test_srcs)
lab4_custom_objs := $(lab4_custom_asm_test_objs) $(lab4_custom_debug_test_objs)
lab4_custom_dumps := $(lab4_custom_asm_test_dumps) $(lab4_custom_debug_test_dumps)
lab4_custom_vmhs := $(lab4_custom_asm_test_vmhs) $(lab4_custom_debug_test_vmhs)
lab4_custom_vcdgzs := $(lab4_custom_asm_test_vcdgzs) $(lab4_custom_debug_test_vcdgzs)
lab4_custom_vpds := $(lab4_custom_asm_test_vpds) $(lab4_custom_debug_test_vpds)
lab4_custom_bins := $(lab4_custom_asm_test_bin) $(lab4_custom_debug_test_bin)