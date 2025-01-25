//========================================================================
// Lab 1 - Iterative Div Unit
//========================================================================

`ifndef PARC_INT_DIV_ITERATIVE_V
`define PARC_INT_DIV_ITERATIVE_V

`include "imuldiv-DivReqMsg.v"

module imuldiv_IntDivIterative (

    input clk,
    input reset,

    input         divreq_msg_fn,
    input  [31:0] divreq_msg_a,
    input  [31:0] divreq_msg_b,
    input         divreq_val,
    output        divreq_rdy,

    output [63:0] divresp_msg_result,
    output        divresp_val,
    input         divresp_rdy
);

  // control <---> datapath interface
  wire perform_shift_op;
  // wire perform_buffer_op;
  wire counter_decr;
  wire counter_is_zero;
  // wire diff_a_b_less_than_zero;
  wire perform_load;

  imuldiv_IntDivIterativeDpath dpath (
      .clk               (clk),
      .reset             (reset),
      .divreq_msg_fn     (divreq_msg_fn),
      .divreq_msg_a      (divreq_msg_a),
      .divreq_msg_b      (divreq_msg_b),
      .divreq_val        (divreq_val),
      .divreq_rdy        (divreq_rdy),
      .divresp_msg_result(divresp_msg_result),
      .divresp_val       (divresp_val),
      .divresp_rdy       (divresp_rdy),

      .perform_shift_op(perform_shift_op),
      // .perform_buffer_op      (perform_buffer_op),
      .counter_decr    (counter_decr),
      .counter_is_zero (counter_is_zero),
      // .diff_a_b_less_than_zero(diff_a_b_less_than_zero),
      .perform_load    (perform_load)
  );

  imuldiv_IntDivIterativeCtrl ctrl (
      .clk        (clk),
      .reset      (reset),
      .divreq_val (divreq_val),
      .divreq_rdy (divreq_rdy),
      .divresp_val(divresp_val),
      .divresp_rdy(divresp_rdy),

      .perform_shift_op(perform_shift_op),
      // .perform_buffer_op      (perform_buffer_op),
      .counter_decr    (counter_decr),
      .counter_is_zero (counter_is_zero),
      // .diff_a_b_less_than_zero(diff_a_b_less_than_zero),
      .perform_load    (perform_load)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeDpath (
    input clk,
    input reset,

    input         divreq_msg_fn,  // Function of MulDiv Unit
    input  [31:0] divreq_msg_a,   // Operand A
    input  [31:0] divreq_msg_b,   // Operand B
    input         divreq_val,     // Request val Signal
    output        divreq_rdy,     // Request rdy Signal

    output [63:0] divresp_msg_result,  // Result of operation
    output        divresp_val,         // Response val Signal
    input         divresp_rdy,         // Response rdy Signal

    input  perform_shift_op,
    // input  perform_buffer_op,
    input  counter_decr,
    input  perform_load,
    output counter_is_zero
    // output diff_a_b_less_than_zero
);

  reg [64:0] a_reg;
  reg [64:0] b_reg;
  reg [64:0] diff;

  wire sign_bit_a = divreq_msg_a[31];
  wire sign_bit_b = divreq_msg_b[31];
  reg sign_result_reg;

  reg [4:0] counter_reg;

  reg fn_reg = divreq_msg_fn;

  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= 5'd31;
      a_reg <= 65'b0;
      b_reg <= 65'b0;
      sign_result_reg <= 1'b0;

    end else begin
      if (perform_load) begin
        counter_reg <= 5'd31;
        a_reg <= {33'b0, divreq_msg_a};
        b_reg <= {1'b0, divreq_msg_b, 32'b0};

        // TODO: finish
      end
      if (perform_shift_op) begin
        a_reg <= a_reg << 1;
        diff = A - B;
        if (A < B) begin
          a_reg <= {diff[64:1], 1'b1};
        end
      end
      if (counter_decr) begin
        counter_reg <= counter_reg - 1;
      end
    end
  end

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  // reg        fn_reg;  // Register for storing function
  // reg [31:0] a_reg;  // Register for storing operand A
  // reg [31:0] b_reg;  // Register for storing operand B
  // reg        val_reg;  // Register for storing valid bit
  //
  // always @(posedge clk) begin
  //
  //   // Stall the pipeline if the response interface is not ready
  //   if (divresp_rdy) begin
  //     fn_reg  <= divreq_msg_fn;
  //     a_reg   <= divreq_msg_a;
  //     b_reg   <= divreq_msg_b;
  //     val_reg <= divreq_val;
  //   end
  //
  // end
  //
  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  // Extract sign bits

  // wire sign_bit_a = a_reg[31];
  // wire sign_bit_b = b_reg[31];
  //
  // // Unsign operands if necessary
  //
  // wire [31:0] unsigned_a = (sign_bit_a) ? (~a_reg + 1'b1) : a_reg;
  // wire [31:0] unsigned_b = (sign_bit_b) ? (~b_reg + 1'b1) : b_reg;
  //
  // // Computation logic
  //
  // wire [31:0] unsigned_quotient
  //   = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED )   ? unsigned_a / unsigned_b
  //   : ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? a_reg / b_reg
  //   :                                                   32'bx;
  //
  // wire [31:0] unsigned_remainder
  //   = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED )   ? unsigned_a % unsigned_b
  //   : ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? a_reg % b_reg
  //   :                                                   32'bx;
  //
  // // Determine whether or not result is signed. Usually the result is
  // // signed if one and only one of the input operands is signed. In other
  // // words, the result is signed if the xor of the sign bits of the input
  // // operands is true. Remainder opeartions are a bit trickier, and here
  // // we simply assume that the result is signed if the dividend for the
  // // rem operation is signed.
  //
  // wire is_result_signed_div = sign_bit_a ^ sign_bit_b;
  // wire is_result_signed_rem = sign_bit_a;
  //
  // // Sign the final results if necessary
  //
  // wire [31:0] signed_quotient = (fn_reg ==
  // `IMULDIV_DIVREQ_MSG_FUNC_SIGNED
  // && is_result_signed_div) ? ~unsigned_quotient + 1'b1 : unsigned_quotient;
  //
  // wire [31:0] signed_remainder = (fn_reg ==
  // `IMULDIV_DIVREQ_MSG_FUNC_SIGNED
  // && is_result_signed_rem) ? ~unsigned_remainder + 1'b1 : unsigned_remainder;
  //
  // assign divresp_msg_result = {signed_remainder, signed_quotient};
  //
  // // Set the val/rdy signals. The request is ready when the response is
  // // ready, and the response is valid when there is valid data in the
  // // input registers.
  //
  // assign divreq_rdy = divresp_rdy;
  // assign divresp_val = val_reg;
  //

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl (
    test
);

endmodule

`endif
