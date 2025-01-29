//========================================================================
// Test for Div Unit
//========================================================================

`include "imuldiv-DivReqMsg.v"
`include "imuldiv-IntDivIterative.v"
`include "vc-TestSource.v"
`include "vc-TestSink.v"
`include "vc-Test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module imuldiv_IntDivIterative_helper
(
  input       clk,
  input       reset,
  output      done
);

  wire [64:0] src_msg;
  wire        src_msg_fn;
  wire [31:0] src_msg_a;
  wire [31:0] src_msg_b;
  wire        src_val;
  wire        src_rdy;
  wire        src_done;

  wire [63:0] sink_msg;
  wire        sink_val;
  wire        sink_rdy;
  wire        sink_done;

  assign done = src_done && sink_done;

  vc_TestSource#(65,3) src
  (
    .clk   (clk),
    .reset (reset),
    .bits  (src_msg),
    .val   (src_val),
    .rdy   (src_rdy),
    .done  (src_done)
  );

  imuldiv_DivReqMsgFromBits msgfrombits
  (
    .bits (src_msg),
    .func (src_msg_fn),
    .a    (src_msg_a),
    .b    (src_msg_b)
  );

  imuldiv_IntDivIterative idiv
  (
    .clk                 (clk),
    .reset               (reset),
    .divreq_msg_fn       (src_msg_fn),
    .divreq_msg_a        (src_msg_a),
    .divreq_msg_b        (src_msg_b),
    .divreq_val          (src_val),
    .divreq_rdy          (src_rdy),
    .divresp_msg_result  (sink_msg),
    .divresp_val         (sink_val),
    .divresp_rdy         (sink_rdy)
  );

  vc_TestSink#(64,3) sink
  (
    .clk   (clk),
    .reset (reset),
    .bits  (sink_msg),
    .val   (sink_val),
    .rdy   (sink_rdy),
    .done  (sink_done)
  );

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module tester;

  // VCD Dump
  initial begin
    $dumpfile("imuldiv-IntDivIterative.vcd");
    $dumpvars;
  end

  `VC_TEST_SUITE_BEGIN( "imuldiv-IntDivIterative" )

  reg  t0_reset = 1'b1;
  wire t0_done;

  imuldiv_IntDivIterative_helper t0
  (
    .clk   (clk),
    .reset (t0_reset),
    .done  (t0_done)
  );

  `VC_TEST_CASE_BEGIN( 1, "div/rem" )
  begin

    t0.src.m[ 0] = 65'h1_00000000_00000001; t0.sink.m[ 0] = 64'h00000000_00000000;
    t0.src.m[ 1] = 65'h1_00000001_00000001; t0.sink.m[ 1] = 64'h00000000_00000001;
    t0.src.m[ 2] = 65'h1_00000000_ffffffff; t0.sink.m[ 2] = 64'h00000000_00000000;
    t0.src.m[ 3] = 65'h1_ffffffff_ffffffff; t0.sink.m[ 3] = 64'h00000000_00000001;
    t0.src.m[ 4] = 65'h1_00000222_0000002a; t0.sink.m[ 4] = 64'h00000000_0000000d;
    t0.src.m[ 5] = 65'h1_0a01b044_ffffb146; t0.sink.m[ 5] = 64'h00000000_ffffdf76;
    t0.src.m[ 6] = 65'h1_00000032_00000222; t0.sink.m[ 6] = 64'h00000032_00000000;
    t0.src.m[ 7] = 65'h1_00000222_00000032; t0.sink.m[ 7] = 64'h0000002e_0000000a;
    t0.src.m[ 8] = 65'h1_0a01b044_ffffb14a; t0.sink.m[ 8] = 64'h00003372_ffffdf75;
    t0.src.m[ 9] = 65'h1_deadbeef_0000beef; t0.sink.m[ 9] = 64'hffffda72_ffffd353;
    t0.src.m[10] = 65'h1_f5fe4fbc_00004eb6; t0.sink.m[10] = 64'hffffcc8e_ffffdf75;
    t0.src.m[11] = 65'h1_f5fe4fbc_ffffb14a; t0.sink.m[11] = 64'hffffcc8e_0000208b;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Add Unsigned Test Case Here
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "divu/remu" )
  begin

    t0.src.m[ 1] = 67'h4_0000000b_00000003; t0.sink.m[ 1] = 64'h00000002_00000003;
    // Dividing by 1
    t0.src.m[ 2] = 67'h4_0000000a_00000001; t0.sink.m[ 2] = 64'h00000000_0000000a;
    // Dividing by a larger number than the dividend
    t0.src.m[ 3] = 67'h4_00000005_00000009; t0.sink.m[ 3] = 64'h00000005_00000000;
    // Dividing a number by itself
    t0.src.m[ 4] = 67'h4_00000007_00000007; t0.sink.m[ 4] = 64'h00000000_00000001;
    // Dividend is 0
    t0.src.m[ 5] = 67'h4_00000000_00000004; t0.sink.m[ 5] = 64'h00000000_00000000;
    // Divisor is 0 -- yields remainder = dividend, quotient = ffffffff
    t0.src.m[ 6] = 67'h4_00000007_00000000; t0.sink.m[ 6] = 64'h00000007_ffffffff;
    // Maximum possible dividend (32-bit example)
    t0.src.m[ 7] = 67'h4_ffffffff_00000002; t0.sink.m[ 7] = 64'h00000001_7fffffff;
    // Maximum divisor that is not zero
    t0.src.m[ 8] = 67'h4_0000000a_ffffffff; t0.sink.m[ 8] = 64'h0000000a_00000000;
    // Near-boundary values (2^n - 1 and 2^n)
    t0.src.m[ 9] = 67'h4_7fffffff_00000002; t0.sink.m[ 9] = 64'h00000001_3fffffff;
    // Dividend = 2^31, Divisor = 2
    t0.src.m[ 10] = 67'h4_80000000_00000002; t0.sink.m[ 10] = 64'h00000000_40000000;
    // Small dividends and divisors
    t0.src.m[ 11] = 67'h4_00000002_00000002; t0.sink.m[ 11] = 64'h00000000_00000001;
    t0.src.m[ 12] = 67'h4_00000001_00000002; t0.sink.m[ 12] = 64'h00000001_00000000;
    // Dividend = 0 and Divisor = 1
    t0.src.m[ 13] = 67'h4_00000000_00000001; t0.sink.m[13] = 64'h00000000_00000000;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2 /* replace with number of tests cases */ )

endmodule
