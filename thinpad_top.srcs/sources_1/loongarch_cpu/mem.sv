`include "define.sv"
module MEM (
  PipeLineData U_EXE,
  PipeLineData U_MEM,
  __PipeLineCtrl U_Pipe,
  Ram U_RAM
);

  /* 流水线寄存器 */
  always_ff @(posedge U_MEM.clk) begin
    if (U_MEM.rst == `V_TRUE) begin
      U_Pipe.valid_mem <= `V_FALSE;
    end
    else if (U_Pipe.allowin_mem == `V_TRUE) begin
      U_Pipe.valid_mem <= U_Pipe.exe_to_mem_valid;
    end
    if (U_Pipe.exe_to_mem_valid == `V_TRUE && U_Pipe.allowin_mem == `V_TRUE) begin
      U_MEM.pc         <= U_EXE.pc;
      U_MEM.inst       <= U_EXE.inst;
      U_MEM.imm        <= U_EXE.imm;
      U_MEM.rf_rdata1  <= U_EXE.rf_rdata1;
      U_MEM.rf_rdata2  <= U_EXE.rf_rdata2;
      U_MEM.rf_waddr   <= U_EXE.rf_waddr;
      U_MEM.rf_we      <= U_EXE.rf_we;
      U_MEM.alu_result <= U_EXE.alu_result;
      U_MEM.branch     <= U_EXE.branch;
      U_MEM.load       <= U_EXE.load;
      U_MEM.ram_addr   <= U_EXE.ram_addr;
      U_MEM.ram_be     <= U_EXE.ram_be;
      U_MEM.ram_oe     <= U_EXE.ram_oe;
      U_MEM.ram_we     <= U_EXE.ram_we;
    end
  end
  /* mem */
  assign U_MEM.ram_data = U_RAM.data_ram_rdata;

endmodule