//==========================================================================
// Out‑of‑Order Core ‒ Reorder Buffer with Speculation (16‑entry, 1‑wide)
//==========================================================================
//  * One allocate + one fill + one commit per cycle
//  * Head  : oldest entry that may commit
//  * Tail  : next free entry that may be allocated
//  * full  : (tail==head) && valid[head]
//  * empty : (tail==head) && !valid[head]
//  * Added speculation support:
//    - Speculative bit for each entry
//    - Interface to handle branch outcomes
//    - Ability to invalidate speculative instructions on misprediction
//==========================================================================

`ifndef PARC_CORE_REORDERBUFFER_V
`define PARC_CORE_REORDERBUFFER_V

module parc_CoreReorderBuffer
(
  input         clk,
  input         reset,

  //--------------------------------------------------------------------
  // Allocate (Decode -> ROB)
  //--------------------------------------------------------------------
  input         rob_alloc_req_val,
  output        rob_alloc_req_rdy,
  input  [ 4:0] rob_alloc_req_preg,
  output [ 3:0] rob_alloc_resp_slot,
  
  // Speculation interface for allocation
  input         rob_alloc_spec,   // Whether newly allocated instruction is speculative

  //--------------------------------------------------------------------
  // Fill (Writeback -> ROB)
  //--------------------------------------------------------------------
  input         rob_fill_val,
  input  [ 3:0] rob_fill_slot,

  //--------------------------------------------------------------------
  // Commit (ROB -> Commit / RF)
  //--------------------------------------------------------------------
  output        rob_commit_wen,
  output [ 3:0] rob_commit_slot,
  output [ 4:0] rob_commit_rf_waddr,
  
  //--------------------------------------------------------------------
  // Branch Resolution (from Execute stage)
  //--------------------------------------------------------------------
  input         br_resolved_val,  // Whether a branch was resolved this cycle
  input         br_resolved_dir,  // Direction of resolved branch (taken or not taken)
  input         br_mispredict     // Whether branch was mispredicted
);

  //----------------------------------------------------------------------
  // Parameters
  //----------------------------------------------------------------------

  localparam ROB_ENTRIES = 16;
  localparam PTR_W       = 4;            // log2(ROB_ENTRIES)

  //----------------------------------------------------------------------
  // Storage
  //----------------------------------------------------------------------

  // Per‑entry arrays (array‑of‑reg style for clean synthesis)
  reg                  valid   [0:ROB_ENTRIES-1]; // entry in use
  reg                  pending [0:ROB_ENTRIES-1]; // result not ready
  reg        [4:0]     preg    [0:ROB_ENTRIES-1]; // dest physical reg
  reg                  spec    [0:ROB_ENTRIES-1]; // is speculative

  reg [PTR_W-1:0] head_ptr;  // commit pointer
  reg [PTR_W-1:0] tail_ptr;  // allocate pointer

  //----------------------------------------------------------------------
  // Derived flags
  //----------------------------------------------------------------------

  wire rob_empty = (head_ptr == tail_ptr) && (~valid[head_ptr]);
  wire rob_full  = (head_ptr == tail_ptr) &&   valid[head_ptr];

  // Allocate handshake
  assign rob_alloc_req_rdy   = ~rob_full;
  assign rob_alloc_resp_slot = tail_ptr;

  wire alloc_fire = rob_alloc_req_val & rob_alloc_req_rdy;
  wire fill_fire  = rob_fill_val;

  // Commit when head entry is valid **and** its result is ready **and** not speculative
  // For proper speculation handling, we shouldn't commit speculative instructions
  wire commit_ready = valid[head_ptr] & ~pending[head_ptr] & ~spec[head_ptr];

  assign rob_commit_wen      = commit_ready;
  assign rob_commit_slot     = head_ptr;
  assign rob_commit_rf_waddr = preg[head_ptr];

  //----------------------------------------------------------------------
  // Sequential update
  //----------------------------------------------------------------------

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

      //------------------------------------------------------------------
      // Fill path (clear pending bit)
      //------------------------------------------------------------------
      if (fill_fire) begin
        pending[rob_fill_slot] <= 1'b0;
      end

      //------------------------------------------------------------------
      // Branch resolution - handle speculative instructions
      //------------------------------------------------------------------
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
          // This is the key for branch handling - after resolution, instructions
          // are no longer speculative and can commit
          for (i = 0; i < ROB_ENTRIES; i = i + 1) begin
            if (valid[i] && spec[i]) begin
              spec[i] <= 1'b0;
            end
          end
        end
      end

      //------------------------------------------------------------------
      // Commit path (retire oldest ready)
      //------------------------------------------------------------------
      if (commit_ready) begin
        valid[head_ptr] <= 1'b0;            // free entry
        head_ptr        <= head_ptr + 1'b1; // move to next
      end

      //------------------------------------------------------------------
      // Allocate path (insert new entry)
      //------------------------------------------------------------------
      if (alloc_fire) begin
        valid  [tail_ptr] <= 1'b1;
        pending[tail_ptr] <= 1'b1;          // will be ready later
        preg   [tail_ptr] <= rob_alloc_req_preg;
        spec   [tail_ptr] <= rob_alloc_spec; // Set speculative flag
        tail_ptr          <= tail_ptr + 1'b1;
      end

    end
  end

endmodule

`endif // PARC_CORE_REORDERBUFFER_V