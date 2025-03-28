//========================================================================
// parcv2-mul-pipe.S
//========================================================================
// Tests pipelined multiplication with back-to-back operations

#include "parc-macros.h"

        TEST_PARC_BEGIN

        //--------------------------------------------------------------------
        // Basic back-to-back multiply tests
        //--------------------------------------------------------------------

        // Simple back-to-back multiplies
        TEST_RR_OP( mul,  3,  4,  12 )  // 3 * 4 = 12
        TEST_RR_OP( mul,  5,  6,  30 )  // 5 * 6 = 30 (immediately after)
        TEST_RR_OP( mul,  7,  8,  56 )  // 7 * 8 = 56 (immediately after)

        // Back-to-back with result forwarding
        li    $2, 3
        li    $3, 4
        mul   $4, $2, $3      // 3 * 4 = 12
        mul   $5, $4, $3      // 12 * 4 = 48 (using previous result)
        mul   $6, $5, $3      // 48 * 4 = 192 (using previous result)
        TEST_CHECK_EQ( $4, 12 )
        TEST_CHECK_EQ( $5, 48 )
        TEST_CHECK_EQ( $6, 192 )

        TEST_PARC_END
