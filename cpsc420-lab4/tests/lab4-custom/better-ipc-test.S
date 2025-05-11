//=========================================================================
// better-ipc-test.S
//=========================================================================
// Test case where pv2byp has better IPC than pv2ooo and pv2spec processors.
// This is possible because pv2ooo has the overhead of ROB management,
// which can slow down execution for simple independent instructions.

#include "parc-macros.h"

        TEST_PARC_BEGIN

        // Initialize registers with different values
        li    $2, 1
        li    $3, 2
        li    $4, 3
        li    $5, 4
        li    $6, 5
        
        // Series of completely independent ALU operations
        // These can all execute in parallel in both bypass and OOO
        // But OOO has overhead from ROB management
        addu  $7, $2, $3         // $7 = 1 + 2 = 3
        addu  $8, $3, $4         // $8 = 2 + 3 = 5
        addu  $9, $4, $5         // $9 = 3 + 4 = 7
        addu  $10, $5, $6        // $10 = 4 + 5 = 9
        addu  $11, $6, $2        // $11 = 5 + 1 = 6
        
        // Verify results of all operations
        TEST_CHECK_EQ($7, 3)
        TEST_CHECK_EQ($8, 5)
        TEST_CHECK_EQ($9, 7)
        TEST_CHECK_EQ($10, 9)
        TEST_CHECK_EQ($11, 6)
        
        TEST_PARC_END