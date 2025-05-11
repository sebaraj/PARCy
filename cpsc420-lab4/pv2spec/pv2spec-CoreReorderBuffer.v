//=========================================================================
// 5-Stage PARC Scoreboard
//=========================================================================

`ifndef PARC_CORE_REORDERBUFFER_V
`define PARC_CORE_REORDERBUFFER_V

module parc_CoreReorderBuffer
(
  input         clk,
  input         reset,

  input         rob_alloc_req_val,
  output        rob_alloc_req_rdy,
  input  [ 4:0] rob_alloc_req_preg,
  output [ 3:0] rob_alloc_resp_slot,
  
  input         rob_alloc_spec,

  input         rob_fill_val,
  input  [ 3:0] rob_fill_slot,

  output        rob_commit_wen,
  output [ 3:0] rob_commit_slot,
  output [ 4:0] rob_commit_rf_waddr,
  
  input         br_resolved_val,
  input         br_resolved_dir,
  input         br_mispredict
);

  localparam ROB_ENTRIES = 16;
  localparam PTR_W = 4; // log2(ROB_ENTRIES)

  reg                  valid   [0:ROB_ENTRIES-1];
  reg                  pending [0:ROB_ENTRIES-1];
  reg        [4:0]     preg    [0:ROB_ENTRIES-1];
  reg                  spec    [0:ROB_ENTRIES-1]; // new bit if speculative

  reg [PTR_W-1:0] head_ptr;
  reg [PTR_W-1:0] tail_ptr;

  wire rob_empty = (head_ptr == tail_ptr) && (~valid[head_ptr]);
  wire rob_full  = (head_ptr == tail_ptr) &&   valid[head_ptr];

  assign rob_alloc_req_rdy   = ~rob_full;
  assign rob_alloc_resp_slot = tail_ptr;

  wire alloc_fire = rob_alloc_req_val & rob_alloc_req_rdy;
  wire fill_fire  = rob_fill_val;

  wire commit_ready = valid[head_ptr] & ~pending[head_ptr] & ~spec[head_ptr];

  assign rob_commit_wen      = commit_ready;
  assign rob_commit_slot     = head_ptr;
  assign rob_commit_rf_waddr = preg[head_ptr];

  integer i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      head_ptr <= 0;
      tail_ptr <= 0;
      for (i = 0; i < ROB_ENTRIES; i = i + 1) begin
        valid   [i] <= 1'b0;
        pending [i] <= 1'b0;
        preg    [i] <= 5'd0;
        spec    [i] <= 1'b0;
      end

    end else begin

      // Fill path (clear pending bit)
      if (fill_fire) begin
        pending[rob_fill_slot] <= 1'b0;
      end

      // Branch resolution - handle speculative instructions
      if (br_resolved_val) begin
        if (br_mispredict) begin
          // Misprediction: invalidate all speculative instructions
          for (i = 0; i < ROB_ENTRIES; i = i + 1) begin
            if (valid[i] && spec[i]) begin
              valid[i] <= 1'b0;
            end
          end
          // Do NOT reset tail_ptr to avoid stalls
        end else begin
          // Correct prediction: mark all speculative instructions as non-speculative
          for (i = 0; i < ROB_ENTRIES; i = i + 1) begin
            if (valid[i] && spec[i]) begin
              spec[i] <= 1'b0;
            end
          end
        end
      end

      // Commit path (retire oldest ready)
      if (commit_ready) begin
        valid[head_ptr] <= 1'b0;
        head_ptr        <= head_ptr + 1'b1;
      end

      // Allocate path (insert new entry)
      if (alloc_fire) begin
        valid  [tail_ptr] <= 1'b1;
        pending[tail_ptr] <= 1'b1;
        preg   [tail_ptr] <= rob_alloc_req_preg;
        spec   [tail_ptr] <= rob_alloc_spec;
        tail_ptr          <= tail_ptr + 1'b1;
      end

    end
  end

endmodule

`endif

