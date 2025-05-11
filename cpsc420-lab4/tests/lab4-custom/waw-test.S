//=========================================================================
// waw-test.S
//=========================================================================
// Test case for Write-After-Write (WAW) scenario that executes correctly on both
// processors because enough time elapses between the writes.

#include "parc-macros.h"

        TEST_PARC_BEGIN

        // Initialize registers
        li    $2, 10             // Source value
        
        // First write to $3
        addu  $3, $2, 5          // $3 = 10 + 5 = 15

        // Create a long delay between writes using multiple operations
        addu  $4, $2, $2         // $4 = 10 + 10 = 20
        addu  $5, $4, $4         // $5 = 20 + 20 = 40
        addu  $6, $5, $5         // $6 = 40 + 40 = 80
        addu  $7, $6, $6         // $7 = 80 + 80 = 160
        addu  $8, $7, $7         // $8 = 160 + 160 = 320
        
        // Second write to $3 (WAW hazard with first write)
        // By the time this executes, the first write to $3 is complete
        addu  $3, $2, 10         // $3 = 10 + 10 = 20

        // Verify the final value
        TEST_CHECK_EQ($3, 20)
        
        TEST_PARC_END