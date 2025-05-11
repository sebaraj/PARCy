//=========================================================================
// rob-bypass-test.S
//=========================================================================
// Test case for bypassing a value from the ROB that has been written back
// but not yet committed.

#include "parc-macros.h"

        TEST_PARC_BEGIN

        // Initialize registers
        li    $2, 10             // Source value
        li    $3, 0              // Will hold result
        li    $4, 0              // Will be used for verification

        // Create sequence where a long-latency instruction is followed
        // by instructions that depend on its result
        
        // First instruction will take a long time to complete
        div   $5, $2, 2          // Long latency operation, result = 5
        
        // Shorter operations that follow
        addu  $3, $5, 15         // Depends on div result, $3 = 5 + 15 = 20
        
        // This instruction depends on the addu, which depends on div
        // The addu may finish and writeback before div commits
        // Success requires bypassing from ROB
        addu  $4, $3, 5          // $4 = $3 + 5 = 25
        
        // Check the final result
        TEST_CHECK_EQ($4, 25)
        
        TEST_PARC_END