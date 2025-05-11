//========================================================================
// parc-macros.h
//========================================================================

#ifndef PARC_MACROS_H
#define PARC_MACROS_H

//------------------------------------------------------------------------
// TEST_PARC_BEGIN
//------------------------------------------------------------------------
// Create a memory location for the tohost value and an entry point
// where the test should start.

#define TEST_PARC_BEGIN                                                 \
    .text;                                                              \
    .align  4;                                                          \
    .global _test;                                                      \
    .ent    _test;                                                      \
_test:                                                                  \

//------------------------------------------------------------------------
// TEST_PARC_END
//------------------------------------------------------------------------
// Assumes that the result is in register number 29. Also assume that
// the linker script places the _tohost array in the first 2^16 bytes of
// memory so that we can access it with just the %lo() assembler
// builtin. This avoids needing lui to also be implemented. We add a
// bunch of nops after the pass fail sections with the hope that someone
// can implement just addiu and sw and then get that working first. The
// bne won't do anything, and the test harness will hopefully detect the
// update to _tohost soon after changing it.

#define TEST_PARC_END                                                   \
_pass:                                                                  \
    addiu  $29, $0, 1;                                                  \
                                                                        \
_fail:                                                                  \
    li     $2,  1;                                                      \
    mtc0   $29, $21;                                                    \
1:  bne    $0, $2, 1b;                                                  \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop;                   \
                                                                        \
    .end _test                                                          \

//------------------------------------------------------------------------
// TEST_CHECK_EQ
//------------------------------------------------------------------------
// Check if the given register has the given value, and fail if not.
// Saves the line number in register $29 for use by the TEST_END macro.

#define TEST_CHECK_EQ( reg_, value_ )                                   \
    li    $29, __LINE__;                                                \
    bne   reg_, value_, _fail;                                          \

//------------------------------------------------------------------------
// TEST_CHECK_FAIL
//------------------------------------------------------------------------
// Force this test to fail. Saves the line number in register $29 for
// use by the TEST_END macro.

#define TEST_CHECK_FAIL                                                 \
    li    $29, __LINE__;                                                \
    bne   $29, $0, _fail;                                               \

//------------------------------------------------------------------------
// TEST_INSERT_NOPS
//------------------------------------------------------------------------
// Macro which expands to a variable number of nops.

#define TEST_INSERT_NOPS_0
#define TEST_INSERT_NOPS_1  nop; TEST_INSERT_NOPS_0
#define TEST_INSERT_NOPS_2  nop; TEST_INSERT_NOPS_1
#define TEST_INSERT_NOPS_3  nop; TEST_INSERT_NOPS_2
#define TEST_INSERT_NOPS_4  nop; TEST_INSERT_NOPS_3
#define TEST_INSERT_NOPS_5  nop; TEST_INSERT_NOPS_4
#define TEST_INSERT_NOPS_6  nop; TEST_INSERT_NOPS_5
#define TEST_INSERT_NOPS_7  nop; TEST_INSERT_NOPS_6
#define TEST_INSERT_NOPS_8  nop; TEST_INSERT_NOPS_7
#define TEST_INSERT_NOPS_9  nop; TEST_INSERT_NOPS_8
#define TEST_INSERT_NOPS_10 nop; TEST_INSERT_NOPS_9

#define TEST_INSERT_NOPS_H0( nops_ ) \
  TEST_INSERT_NOPS_ ## nops_

#define TEST_INSERT_NOPS( nops_ ) \
  TEST_INSERT_NOPS_H0( nops_ )

#endif /* PARC_MACROS_H */