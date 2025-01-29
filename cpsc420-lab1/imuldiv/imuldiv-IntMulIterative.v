//========================================================================
// Lab 1 - Iterative Mul Unit
//========================================================================

`ifndef PARC_INT_MUL_ITERATIVE_V
`define PARC_INT_MUL_ITERATIVE_V

module imuldiv_IntMulIterative (
    input clk,
    input reset,

    input  [31:0] mulreq_msg_a,
    input  [31:0] mulreq_msg_b,
    input         mulreq_val,
    output        mulreq_rdy,

    output [63:0] mulresp_msg_result,
    output        mulresp_val,
    input         mulresp_rdy
);

  // control <--> datapath interface
  // would be easier to have control logic for lsb/b[0] in datapath module to
  // avoid having to pass it through control module,
  // but in order to separate control and datapath...
  wire perform_shift_op;
  wire perform_add_op;
  wire counter_decr;
  wire counter_is_zero;
  wire lsb;
  wire perform_load;



  imuldiv_IntMulIterativeDpath dpath (
      .clk               (clk),
      .reset             (reset),
      .mulreq_msg_a      (mulreq_msg_a),
      .mulreq_msg_b      (mulreq_msg_b),
      .mulreq_val        (mulreq_val),
      .mulreq_rdy        (mulreq_rdy),
      .mulresp_msg_result(mulresp_msg_result),
      .mulresp_val       (mulresp_val),
      .mulresp_rdy       (mulresp_rdy),

      .perform_shift_op(perform_shift_op),
      .perform_add_op  (perform_add_op),
      .counter_decr    (counter_decr),
      .counter_is_zero (counter_is_zero),
      .lsb             (lsb),
      .perform_load    (perform_load)

  );

  imuldiv_IntMulIterativeCtrl ctrl (
      .clk        (clk),
      .reset      (reset),
      .mulreq_val (mulreq_val),
      .mulreq_rdy (mulreq_rdy),
      .mulresp_val(mulresp_val),
      .mulresp_rdy(mulresp_rdy),

      .perform_shift_op(perform_shift_op),
      .perform_add_op  (perform_add_op),
      .counter_decr    (counter_decr),
      .counter_is_zero (counter_is_zero),
      .lsb             (lsb),
      .perform_load    (perform_load)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeDpath (
    input clk,
    input reset,

    input  [31:0] mulreq_msg_a,  // Operand A
    input  [31:0] mulreq_msg_b,  // Operand B
    input         mulreq_val,    // Request val Signal
    output        mulreq_rdy,    // Request rdy Signal

    output [63:0] mulresp_msg_result,  // Result of operation
    output        mulresp_val,         // Response val Signal
    input         mulresp_rdy,         // Response rdy Signal

    input  perform_shift_op,
    input  perform_add_op,
    input  counter_decr,
    input  perform_load,
    output counter_is_zero,
    output lsb
);

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg [63:0] a_reg;  // Register for storing operand A
  reg [31:0] b_reg;  // Register for storing operand B
  assign lsb = b_reg[0];

  // reg         val_reg;  // Register for storing valid bit

  // copied from commented code below
  wire        sign_bit_a = mulreq_msg_a[31];
  wire        sign_bit_b = mulreq_msg_b[31];
  // wire        sign_bit_result = sign_bit_a ^ sign_bit_b;
  // reg         sign_a_reg;
  // reg         sign_b_reg;
  reg         sign_result_reg;

  wire [31:0] unsigned_a = (sign_bit_a) ? (~mulreq_msg_a + 1'b1) : mulreq_msg_a;
  wire [31:0] unsigned_b = (sign_bit_b) ? (~mulreq_msg_b + 1'b1) : mulreq_msg_b;

  // new
  reg  [ 4:0] counter_reg;  // 32 op cycles
  assign counter_is_zero = (counter_reg == 5'd0);

  reg  [63:0] result_reg;
  wire [63:0] signed_result = (sign_result_reg) ? (~result_reg + 1'b1) : result_reg;
  assign mulresp_msg_result = signed_result;


  always @(posedge clk) begin
    if (reset) begin
      result_reg <= 64'b0;
      counter_reg <= 5'd31;
      a_reg <= 64'b0;
      b_reg <= 32'b0;
      sign_result_reg <= 1'b0;
    end else begin
      if (perform_load) begin
        result_reg <= 64'b0;
        counter_reg <= 5'd31;
        a_reg <= {32'b0, unsigned_a};
        b_reg <= unsigned_b;
        sign_result_reg <= sign_bit_a ^ sign_bit_b;
      end
      if (perform_shift_op) begin
        a_reg <= a_reg << 1;
        b_reg <= b_reg >> 1;
      end
      if (perform_add_op) begin
        result_reg <= result_reg + a_reg;
      end
      if (counter_decr) begin
        counter_reg <= counter_reg - 1;
      end
    end
  end



  // Stall the pipeline if the response interface is not ready
  // if (mulresp_rdy) begin
  // a_reg   <= mulreq_msg_a;
  // b_reg   <= mulreq_msg_b;
  // val_reg <= mulreq_val;
  // end

  // end

  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  // Extract sign bits

  // wire sign_bit_a = a_reg[31];
  // wire sign_bit_b = b_reg[31];

  // Unsign operands if necessary

  // wire [31:0] unsigned_a = (sign_bit_a) ? (~a_reg + 1'b1) : a_reg;
  // wire [31:0] unsigned_b = (sign_bit_b) ? (~b_reg + 1'b1) : b_reg;

  // Computation logic

  // wire [63:0] unsigned_result = unsigned_a * unsigned_b;

  // Determine whether or not result is signed. Usually the result is
  // signed if one and only one of the input operands is signed. In other
  // words, the result is signed if the xor of the sign bits of the input
  // operands is true. Remainder opeartions are a bit trickier, and here
  // we simply assume that the result is signed if the dividend for the
  // rem operation is signed.

  // wire is_result_signed = sign_bit_a ^ sign_bit_b;
  //
  // assign mulresp_msg_result = (is_result_signed) ? (~unsigned_result + 1'b1) : unsigned_result;

  // Set the val/rdy signals. The request is ready when the response is
  // ready, and the response is valid when there is valid data in the
  // input registers.

  // assign mulreq_rdy = mulresp_rdy;
  // assign mulresp_val = val_reg;

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeCtrl (
    input      clk,
    input      reset,
    input      mulreq_val,
    output reg mulreq_rdy,
    output reg mulresp_val,
    input      mulresp_rdy,

    input counter_is_zero,
    input lsb,

    // confirm wires/regs; regs needed since used in always block?
    output reg  perform_shift_op,
    output wire perform_add_op,
    output reg  counter_decr,
    output reg  perform_load
);

  // need temp state?
  reg [1:0] state, next_state;
  assign perform_add_op = lsb;
  reg perform_load_op_reg;

  always @(posedge clk) begin
    if (reset) begin
      state <= 0;
    end else begin
      state <= next_state;
    end
  end

  always @* begin
    next_state = state;
    perform_shift_op = 0;
    counter_decr = 0;
    perform_load = 0;
    mulreq_rdy = 0;
    mulresp_val = 0;
    case (state)
      0: begin
        mulreq_rdy = 1;
        if (mulreq_val) begin
          next_state   = 1;
          perform_load = 1;
        end
      end
      1: begin
        perform_shift_op = 1;
        counter_decr = 1;
        if (counter_is_zero) next_state = 2;
      end
      2: begin
        mulresp_val = 1;
        if (mulresp_rdy) begin
          next_state = 0;
        end
      end
    endcase
  end

endmodule

`endif

