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

  // wires between control and datapath
  wire counter_zero;
  wire do_shift;
  wire dec_counter;
  wire load_operands;



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
      .counter_zero      (counter_zero),
      .do_shift          (do_shift),
      .dec_counter       (dec_counter),
      .load_operands     (load_operands)
  );

  imuldiv_IntDivIterativeCtrl ctrl (
      .clk          (clk),
      .reset        (reset),
      .divreq_val   (divreq_val),
      .divreq_rdy   (divreq_rdy),
      .divresp_rdy  (divresp_rdy),
      .divresp_val  (divresp_val),
      .counter_zero (counter_zero),
      .do_shift     (do_shift),
      .dec_counter  (dec_counter),
      .load_operands(load_operands)


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

    // Control signals
    input load_operands,
    input do_shift,
    input dec_counter,

    output counter_zero
);

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg         fn_reg;  // Register for storing function
  reg  [31:0] a_reg;  // Register for storing operand A
  reg  [31:0] b_reg;  // Register for storing operand B
  reg  [ 4:0] counter_reg;  // Register for storing counter, 2^5 = 32 so 5 bits needed 

  reg         is_op_signed_reg;
  reg  [64:0] remainder_quotient;  // Register for storing result
  reg  [64:0] divisor_reg;  // need this too right (check)
  wire [64:0] shifted = remainder_quotient << 1;
  wire [64:0] sub_out = shifted - divisor_reg;

  reg         sign_bit_a;
  reg         sign_bit_b;







  wire        is_op_signed = (divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED);  //  check


  // unsign if fn_reg says so THIS IS THE ISSUE IT USES THE NEXT MESSAGE


  wire [31:0] unsigned_a = (divreq_msg_a[31] && is_op_signed) ? (~divreq_msg_a + 1) : divreq_msg_a;
  wire [31:0] unsigned_b = (divreq_msg_b[31] && is_op_signed) ? (~divreq_msg_b + 1) : divreq_msg_b;

  /*   always @( posedge clk ) begin

    // Stall the pipeline if the response interface is not ready
    if ( divresp_rdy ) begin
      fn_reg  <= divreq_msg_fn;
      a_reg   <= divreq_msg_a;
      b_reg   <= divreq_msg_b;
      val_reg <= divreq_val;
    end

  end */

  always @(posedge clk) begin
    if (reset) begin
      a_reg              <= 32'b0;
      b_reg              <= 32'b0;
      fn_reg             <= 1'b0;
      is_op_signed_reg   <= 1'b0;
      remainder_quotient <= 65'b0;
      divisor_reg        <= 65'b0;
      counter_reg        <= 5'd31;
      sign_bit_a         <= 1'b0;
      sign_bit_b         <= 1'b0;
      // more
    end else begin
      // if fsm says load load
      if (load_operands) begin
        fn_reg             <= divreq_msg_fn;  // 1 will be signed, 0 will be unsigned
        //val_reg <= divreq_val;
        // determine if the operation is signed or not
        is_op_signed_reg   <= is_op_signed;
        a_reg              <= unsigned_a;
        b_reg              <= unsigned_b;  // need these?
        sign_bit_a         <= divreq_msg_a[31];
        sign_bit_b         <= divreq_msg_b[31];
        counter_reg        <= 5'd31;
        //  we initialize the right-half of quotient with operand A and the left-half of divisor with operand B
        remainder_quotient <= {33'b0, unsigned_a};  // same as reg_a in dataflow can changename
        divisor_reg        <= {1'b0, unsigned_b, 32'b0};  // need 31 for alignment right

      end else if (do_shift) begin
        // shift the remainder left by 1
        //shifted = remainder_quotient << 1; // what is up with non blocking/blocking here

        // sub_out = shifted - divisor_reg;
        // is the result negative?
        if (sub_out[64] == 1'b1) begin
          // if neg follow fsm add divisor back
          remainder_quotient <= {shifted[64:1], 1'b0};
        end else begin
          // not neg keep the result and set the lsb to 1
          remainder_quotient <= {sub_out[64:1], 1'b1};
        end

        if (dec_counter) begin
          counter_reg <= counter_reg - 1;
        end
      end




    end

  end
  assign counter_zero = (counter_reg == 5'd0);

  // figure out signs
  wire [31:0] raw_quotient = remainder_quotient[31:0];  // this is dif that flowpath given but works
  wire [31:0] raw_remainder = remainder_quotient[63:32];


  // only sign the quotient if the operation is signed
  wire should_sign_quotient = (sign_bit_a ^ sign_bit_b) & is_op_signed_reg;
  wire should_sign_remainder = sign_bit_a & is_op_signed_reg;

  wire [31:0] final_quotient = should_sign_quotient ? ~raw_quotient + 1'b1 : raw_quotient;
  wire [31:0] final_remainder = should_sign_remainder ? ~raw_remainder + 1'b1 : raw_remainder;
  assign divresp_msg_result = {final_remainder, final_quotient};







  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  // Extract sign bits

  /* wire sign_bit_a = a_reg[31];
  wire sign_bit_b = b_reg[31];

  // Unsign operands if necessary

  wire [31:0] unsigned_a = ( sign_bit_a ) ? (~a_reg + 1'b1) : a_reg;
  wire [31:0] unsigned_b = ( sign_bit_b ) ? (~b_reg + 1'b1) : b_reg;

  // Computation logic

  wire [31:0] unsigned_quotient
    = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED )   ? unsigned_a / unsigned_b
    : ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? a_reg / b_reg
    :                                                   32'bx;

  wire [31:0] unsigned_remainder
    = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED )   ? unsigned_a % unsigned_b
    : ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? a_reg % b_reg
    :                                                   32'bx;

  // Determine whether or not result is signed. Usually the result is
  // signed if one and only one of the input operands is signed. In other
  // words, the result is signed if the xor of the sign bits of the input
  // operands is true. Remainder opeartions are a bit trickier, and here
  // we simply assume that the result is signed if the dividend for the
  // rem operation is signed.

  wire is_result_signed_div = sign_bit_a ^ sign_bit_b;
  wire is_result_signed_rem = sign_bit_a;

  // Sign the final results if necessary

  wire [31:0] signed_quotient
    = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED
     && is_result_signed_div ) ? ~unsigned_quotient + 1'b1
    :                            unsigned_quotient;

  wire [31:0] signed_remainder
    = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED
     && is_result_signed_rem )   ? ~unsigned_remainder + 1'b1
   :                              unsigned_remainder;

  assign divresp_msg_result = { signed_remainder, signed_quotient };

  // Set the val/rdy signals. The request is ready when the response is
  // ready, and the response is valid when there is valid data in the
  // input registers.
 */
  //assign divreq_rdy  = divresp_rdy;

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl (
    input clk,
    input reset,

    // val rdy inputs from the divreq side
    input divreq_val,
    output reg   divreq_rdy, // this is an inner module and I want to use it in an always block so its reg, right? https://blog.waynejohnson.net/doku.php/verilog_wire_and_reg

    // val rdy inputs from the divresp side
    input      divresp_rdy,
    output reg divresp_val,

    input counter_zero,

    output reg do_shift,
    output reg dec_counter,
    output reg load_operands


);
  localparam STATE_IDLE = 2'd0, STATE_EXEC = 2'd1, STATE_DONE = 2'd2, STATE_4_UNUSED = 2'd3;

  // Register to store the current state
  reg [1:0] CurrentState;
  reg [1:0] NextState;

  // per Muhammad initialize registers to be assigned to the output wires for use in the always FSM
  reg load_operands_reg;


  // from fsm tutoiral
  always @(posedge clk) begin
    if (reset) begin
      CurrentState <= STATE_IDLE;
    end else begin
      CurrentState <= NextState;
    end
  end

  always @(*) begin
    //defaults
    NextState     = CurrentState;
    divreq_rdy    = 1'b0;
    divresp_val   = 1'b0;
    dec_counter   = 1'b0;
    do_shift      = 1'b0;
    load_operands = 1'b0;

    // add more

    case (CurrentState)
      STATE_IDLE: begin
        divreq_rdy  = 1'b1;  // ready for new request 
        divresp_val = 1'b0;  // not ready for response
        if (divreq_val && divreq_rdy) begin
          // load the datapath reg and move to exec in same state per Muhammad suggestion
          load_operands = 1'b1;
          NextState    = STATE_EXEC;
        end
      end
      STATE_EXEC: begin
        do_shift = 1'b1;  // always shift
        dec_counter = 1'b1;
        if (counter_zero) NextState = STATE_DONE;
      end

      STATE_DONE: begin
        divresp_val = 1'b1;  // final val ready
        if (divresp_rdy) NextState = STATE_IDLE;
      end

      STATE_4_UNUSED: begin
        NextState = STATE_IDLE;  // check
      end

    endcase
  end








endmodule

`endif

