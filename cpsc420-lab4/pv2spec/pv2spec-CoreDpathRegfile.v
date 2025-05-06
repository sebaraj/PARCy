//=========================================================================
// 5-Stage PARC Register File
//=========================================================================

`ifndef PARC_CORE_DPATH_REGFILE_V
`define PARC_CORE_DPATH_REGFILE_V

module parc_CoreDpathRegfile
(
  input         clk,
  input  [ 4:0] raddr0,  // Read 0 address (combinational input)
  output [31:0] rdata0,  // Read 0 data (combinational on raddr)
  input  [ 4:0] raddr1,  // Read 1 address (combinational input)
  output [31:0] rdata1,  // Read 1 data (combinational on raddr)
  input         wen_p,   // Write enable (sample on rising clk edge)
  input  [ 4:0] waddr_p, // Write address (sample on rising clk edge)
  input  [31:0] wdata_p, // Write data (sample on rising clk edge)
  // Commit interface for ROB writeback
  input         wen_c,   // Commit write enable
  input  [ 4:0] waddr_c, // Commit write address
  input  [31:0] wdata_c  // Commit write data
);

  // We use an array of 32 bit register for the regfile itself
  reg [31:0] registers[31:0];

  // Combinational read ports with bypass logic
  // Prioritize commit stage (C) bypassing over pipeline stage (P) bypassing
  assign rdata0 = (raddr0 == 0) ? 32'b0 : 
                  (wen_c && (raddr0 == waddr_c)) ? wdata_c :
                  (wen_p && (raddr0 == waddr_p)) ? wdata_p :
                  registers[raddr0];
                  
  assign rdata1 = (raddr1 == 0) ? 32'b0 : 
                  (wen_c && (raddr1 == waddr_c)) ? wdata_c :
                  (wen_p && (raddr1 == waddr_p)) ? wdata_p :
                  registers[raddr1];

  // Write port is active when either write enable is asserted
  // Commit stage has priority over pipeline stage
  always @(posedge clk)
  begin
    if (wen_c && (waddr_c != 5'b0))
      registers[waddr_c] <= wdata_c;
    else if (wen_p && (waddr_p != 5'b0))
      registers[waddr_p] <= wdata_p;
  end

endmodule

`endif

