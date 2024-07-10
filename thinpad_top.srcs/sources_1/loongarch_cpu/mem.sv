`include "define.sv"
module MEM (
  PipeLineData U_EXE,
  PipeLineData U_MEM,
  Ram U_RAM
);

  /* 流水线寄存器 */
  always_ff @(posedge U_MEM.clk) begin
    if (U_MEM.rst == `V_TRUE) begin
      U_MEM.valid <= `V_FALSE;
    end
    else if (U_MEM.allowin == `V_TRUE) begin
      U_MEM.valid <= U_MEM.valid_in;
    end
    if (U_MEM.valid_in == `V_TRUE && U_MEM.allowin == `V_TRUE) begin
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
  // assign U_MEM.ram_data = U_RAM.data_ram_rdata;
  always_ff @(*) begin
    case (U_MEM.ram_be) 
      4'b0001: begin U_MEM.ram_data = {{24{U_RAM.data_ram_rdata[ 7]}}, U_RAM.data_ram_rdata[ 7: 0]}; end
      4'b0010: begin U_MEM.ram_data = {{24{U_RAM.data_ram_rdata[15]}}, U_RAM.data_ram_rdata[15: 8]}; end
      4'b0100: begin U_MEM.ram_data = {{24{U_RAM.data_ram_rdata[23]}}, U_RAM.data_ram_rdata[23:16]}; end
      4'b1000: begin U_MEM.ram_data = {{24{U_RAM.data_ram_rdata[31]}}, U_RAM.data_ram_rdata[31:24]}; end
      4'b1111: begin U_MEM.ram_data = U_RAM.data_ram_rdata; end
      default: begin U_MEM.ram_data = `V_ZERO; end
    endcase
  end

endmodule