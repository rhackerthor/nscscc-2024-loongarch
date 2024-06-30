`include "define.sv"
module WB (
  PipeLineData.MEM U_MEM,
  PipeLineData.WB U_WB,
  PipeLineCtrl U_Pipe
);

  /* 流水线寄存器 */
  always_ff @(posedge U_WB.clk) begin
    if (U_WB.rst == `V_TRUE) begin
      U_Pipe.valid_wb <= `V_FALSE;
    end
    else if (U_Pipe.allownin_wb == `V_TRUE) begin
      U_Pipe.valid_wb <= U_Pipe.mem_to_wb_valid;
    end
    if (U_Pipe.mem_to_wb_valid == `V_TRUE && U_Pipe.allownin_wb == `V_TRUE) begin
      U_WB.pc          <= U_MEM.pc;
      U_WB.inst        <= U_MEM.inst;
      U_WB.imm         <= U_MEM.imm;
      U_WB.rf_rdata1   <= U_MEM.rf_rdata1;
      U_WB.rf_rdata2   <= U_MEM.rf_rdata2;
      U_WB.rf_waddr    <= U_MEM.rf_waddr;
      U_WB.rf_we       <= U_MEM.rf_we;
      U_WB.alu_result  <= U_MEM.alu_result;
      U_WB.sel_wb_data <= U_MEM.sel_wb_data;
      U_WB.ram_data    <= U_MEM.ram_data;
      U_WB.ram_addr    <= U_MEM.ram_addr;
      U_WB.ram_be      <= U_MEM.ram_be;
      U_WB.ram_oe      <= U_MEM.ram_oe;
      U_WB.ram_we      <= U_MEM.ram_we;
    end
  end
  /* mem */
  assign U_WB.ram_data = U_WB.sel_wb_data ? U_WB.ram_data : U_WB.alu_result;

endmodule