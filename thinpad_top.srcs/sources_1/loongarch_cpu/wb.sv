`include "define.sv"
module WB (
  PipeLineData U_MEM,
  PipeLineData U_WB
);

  /* 流水线寄存器 */
  always_ff @(posedge U_WB.clk) begin
    if (U_WB.rst == `V_TRUE) begin
      U_WB.valid <= `V_FALSE;
    end
    else if (U_WB.allowin == `V_TRUE) begin
      U_WB.valid <= U_WB.valid_in;
    end
    if (U_WB.valid_in == `V_TRUE && U_WB.allowin == `V_TRUE) begin
      U_WB.pc         <= U_MEM.pc;
      U_WB.inst       <= U_MEM.inst;
      U_WB.rf_waddr   <= U_MEM.rf_waddr;
      U_WB.rf_we      <= U_MEM.rf_we;
      U_WB.alu_result <= U_MEM.alu_result;
      U_WB.load       <= U_MEM.load;
      U_WB.branch     <= U_MEM.branch;
      U_WB.ram_data   <= U_MEM.ram_data;
      U_WB.ram_addr   <= U_MEM.ram_addr;
      U_WB.ram_be     <= U_MEM.ram_be;
    end
  end
  /* write back */
  always_ff @(*) begin
    if (|U_WB.load == `V_TRUE) begin
      U_WB.rf_wdata <= U_WB.ram_data;
    end
    else begin
      U_WB.rf_wdata <= U_WB.alu_result;
    end
  end

endmodule