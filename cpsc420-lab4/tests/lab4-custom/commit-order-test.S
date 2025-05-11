//=========================================================================
// commit-order-test.S
//=========================================================================
// This test creates a dependency chain where instruction order is critical.
// Without a reorder buffer (ROB), instructions might commit in the wrong order
// causing incorrect results.

#include "parc-macros.h"

        TEST_PARC_BEGIN

        // Load initial values
        li    $2, 10             // Initial value
        li    $3, 20             // Value to add
        li    $4, 0              // Will be used to check results

        // Create a situation where a later instruction
        // depends on an earlier one, but the earlier one
        // is likely to finish later in an OOO processor
        div   $5, $2, 2          // Long-latency operation (division)
        addu  $6, $3, 5          // Fast operation

        // This instruction depends on both previous results
        // and will only be correct if they commit in order
        addu  $4, $5, $6         // $4 = ($2/2) + ($3+5)

        // Check the result - should be 5 + 25 = 30
        // This will fail on out-of-order execution without a ROB
        TEST_CHECK_EQ($4, 30)

        TEST_PARC_END