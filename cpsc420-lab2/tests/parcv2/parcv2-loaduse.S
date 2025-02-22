//========================================================================
// parcv2-loaduse.S
//========================================================================

#include "parc-macros.h"

        TEST_PARC_BEGIN

        //------------------------------------------------------------------------
        // Load–Use Hazard Tests
        // These tests do not insert any NOPs between a load and its use.
        // The pipeline must stall for the load–use hazard so that the correct
        // value is used by the following arithmetic instruction.
        //------------------------------------------------------------------------

        // Test 1: Load byte from tdata_0 offset 0 then immediately add 1.
        // tdata_0 holds 0xdeadbeef so lb from offset 0 yields 0xffffffef.
        // Adding 1 should produce 0xfffffff0.
        la    $2, tdata_0        // load base address of tdata_0
        lb    $3, 0($2)          // load byte; expected 0xffffffef
        addiu $4, $3, 1          // compute 0xffffffef + 1 = 0xfffffff0
        TEST_CHECK_EQ( $4, 0xfffffff0 )

        // Test 2: Load byte from tdata_0 offset 1 then immediately add 1.
        // Offset 1 of 0xdeadbeef yields 0xffffffbe adding 1 gives 0xffffffbf.
        la    $5, tdata_0
        lb    $6, 1($5)          // expected 0xffffffbe
        addiu $7, $6, 1          // compute 0xffffffbe + 1 = 0xffffffbf
        TEST_CHECK_EQ( $7, 0xffffffbf )

        // Test 3: Load byte from tdata_0 offset 2 then immediately add 2.
        // Offset 2 yields 0xffffffad adding 2 gives 0xffffffaf.
        la    $8, tdata_0
        lb    $9, 2($8)          // expected 0xffffffad
        addiu $10, $9, 2         // compute 0xffffffad + 2 = 0xffffffaf
        TEST_CHECK_EQ( $10, 0xffffffaf )

        // Test 4: Load byte from tdata_0 offset 3 then immediately subtract 1.
        // Offset 3 yields 0xffffffde subtracting 1 gives 0xffffffdd.
        la    $11, tdata_0
        lb    $12, 3($11)        // expected 0xffffffde
        addiu $13, $12, -1       // compute 0xffffffde - 1 = 0xffffffdd
        TEST_CHECK_EQ( $13, 0xffffffdd )

        //------------------------------------------------------------------------
        // Bypassing Tests
        // These tests insert one NOP (via the TEST_LD_*_BYP macros) so that
        // bypassing (and not stalling) can be verified.
        //------------------------------------------------------------------------

        TEST_LD_DEST_BYP( 1, lb, 0, tdata_0, 0xffffffef )
        TEST_LD_SRC0_BYP( 1, lb, 1, tdata_0, 0xffffffbe )

        TEST_PARC_END

        //------------------------------------------------------------------------
        // Test Data
        //------------------------------------------------------------------------
        .data
        .align 4

tdata_0: .word 0xdeadbeef

