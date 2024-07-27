`include "define.sv"
module WB (
  MEMInterface   U_MEM,
  WBInterface    U_WB,
  RamInterface   U_RAM,
  DebugInterface U_DEBUG
);

  /* pipeline ctrl */
  always_ff @(posedge U_WB.clk) begin
    if (U_WB.rst) begin
      U_WB.valid <= `V_FALSE;
    end
    else if (U_WB.allowin) begin
      U_WB.valid <= U_WB.valid_in;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_WB.clk) begin
    if (U_WB.rst) begin
      U_WB.pc         <= `V_ZERO;
      U_WB.inst       <= `V_ZERO;
      U_WB.rf_waddr   <= `V_ZERO;
      U_WB.rf_we      <= `V_ZERO;
      U_WB.alu_result <= `V_ZERO;
      U_WB.ram_mask   <= `V_ZERO;
      U_WB.load_flag  <= `V_ZERO;
      U_WB.ram_rdata  <= `V_ZERO;
    end
    else if (U_WB.valid_in && U_WB.allowin) begin
      U_WB.pc         <= U_MEM.pc;
      U_WB.inst       <= U_MEM.inst;
      U_WB.rf_waddr   <= U_MEM.rf_waddr;
      U_WB.rf_we      <= U_MEM.rf_we;
      U_WB.alu_result <= U_MEM.alu_result;
      U_WB.ram_mask   <= U_MEM.ram_mask;
      U_WB.load_flag  <= U_MEM.load_flag;
      U_WB.ram_rdata  <= U_MEM.ram_rdata;
    end
  end

  /* write back */
  always @(*) begin
    if (|U_WB.load_flag) begin
      U_WB.rf_wdata <= U_WB.ram_rdata;
    end
    else begin
      U_WB.rf_wdata <= U_WB.alu_result;
    end
  end

  always @(posedge U_WB.clk) begin
    U_DEBUG.valid <= U_WB.valid;
    if (U_WB.valid) begin
      U_DEBUG.rf_we    <= U_WB.rf_we;
      U_DEBUG.pc       <= U_WB.pc;
      U_DEBUG.rf_waddr <= U_WB.rf_waddr;
      U_DEBUG.rf_wdata <= U_WB.rf_wdata;
    end
  end

endmodule