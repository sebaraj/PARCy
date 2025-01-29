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
  wire perform_shift_op_div;
  // wire perform_buffer_op;
  wire counter_decr_div;
  wire counter_is_zero_div;
  // wire diff_a_b_less_than_zero;
  wire perform_load_div;

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

      .perform_shift_op_div(perform_shift_op_div),
      // .perform_buffer_op      (perform_buffer_op),
      .counter_decr_div    (counter_decr_div),
      .counter_is_zero_div (counter_is_zero_div),
      // .diff_a_b_less_than_zero(diff_a_b_less_than_zero),
      .perform_load_div    (perform_load_div)
  );

  imuldiv_IntDivIterativeCtrl ctrl (
      .clk        (clk),
      .reset      (reset),
      .divreq_val (divreq_val),
      .divreq_rdy (divreq_rdy),
      .divresp_val(divresp_val),
      .divresp_rdy(divresp_rdy),

      .perform_shift_op_div(perform_shift_op_div),
      // .perform_buffer_op      (perform_buffer_op),
      .counter_decr_div    (counter_decr_div),
      .counter_is_zero_div (counter_is_zero_div),
      // .diff_a_b_less_than_zero(diff_a_b_less_than_zero),
      .perform_load_div    (perform_load_div)
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

    input  perform_shift_op_div,
    // input  perform_buffer_op,
    input  counter_decr_div,
    input  perform_load_div,
    output counter_is_zero_div
    // output diff_a_b_less_than_zero
);

  reg [64:0] a_reg;
  reg [64:0] b_reg;
  reg [64:0] diff;

  wire sign_bit_a = divreq_msg_a[31];
  wire sign_bit_b = divreq_msg_b[31];
  wire [31:0] unsigned_a = (sign_bit_a && sign_op) ? (~divreq_msg_a + 1'b1) : divreq_msg_a;
  wire [31:0] unsigned_b = (sign_bit_b && sign_op) ? (~divreq_msg_b + 1'b1) : divreq_msg_b;
  reg sign_a_reg;
  reg sign_b_reg;

  wire sign_op = (divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED);
  reg sign_result_reg;

  wire [64:0] a_shifted = a_reg << 1;

  wire [64:0] diff_a_b = a_shifted - b_reg;

  reg [4:0] counter_reg;

  wire [31:0] unsigned_quotient = a_reg[31:0];
  wire [31:0] unsigned_remainder = a_reg[63:32];

  wire [31:0] output_quotient = ((sign_a_reg ^ sign_b_reg) & sign_result_reg) ? (~unsigned_quotient + 1'b1) : unsigned_quotient;
  wire [31:0] output_remainder = (sign_a_reg & sign_result_reg) ? (~unsigned_remainder + 1'b1) : unsigned_remainder;

  assign counter_is_zero_div = (counter_reg == 5'd0);
  assign divresp_msg_result  = {output_remainder, output_quotient};

  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= 5'd31;
      a_reg <= 65'b0;
      b_reg <= 65'b0;
      diff <= 65'b0;
      sign_result_reg <= 1'b0;
      sign_a_reg <= 1'b0;
      sign_b_reg <= 1'b0;

    end else begin
      if (perform_load_div) begin
        counter_reg <= 5'd31;
        a_reg <= {33'b0, unsigned_a};
        b_reg <= {1'b0, unsigned_b, 32'b0};
        sign_a_reg <= sign_bit_a;
        sign_b_reg <= sign_bit_b;
        sign_result_reg <= sign_op;
      end
      if (perform_shift_op_div) begin
        a_reg <= (diff_a_b[64] == 0) ? {diff_a_b[64:1], 1'b1} : a_shifted;
      end
      if (counter_decr_div) begin
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


endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl (
    input clk,
    input reset,

    input divreq_val,  // Request val Signal
    output reg divreq_rdy,  // Request rdy Signal

    output reg divresp_val,  // Response val Signal
    input divresp_rdy,  // Response rdy Signal

    output reg perform_shift_op_div,
    output reg counter_decr_div,
    output reg perform_load_div,
    input counter_is_zero_div
);

  reg [1:0] state_div, next_state_div;

  always @(posedge clk) begin
    if (reset) begin
      state_div <= 0;
    end else begin
      // update state at every clock posedge
      state_div <= next_state_div;
    end
  end

  always @* begin
    next_state_div = state_div;
    // reset control signals/regs
    perform_load_div = 0;
    perform_shift_op_div = 0;
    counter_decr_div = 0;
    divreq_rdy = 0;
    divresp_val = 0;
    case (state_div)
      0: begin
        divreq_rdy = 1;
        if (divreq_val) begin
          next_state_div   = 1;
          perform_load_div = 1;
        end
      end
      1: begin
        // combine this to one signal? but it's easier to read this way...
        perform_shift_op_div = 1;
        counter_decr_div = 1;
        if (counter_is_zero_div) begin
          next_state_div = 2;
        end
      end
      2: begin
        divresp_val = 1;
        if (divresp_rdy) begin
          next_state_div = 0;
        end
      end
      default: begin
        next_state_div = 0;
      end
    endcase

  end

endmodule

`endif
