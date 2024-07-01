`include "define.sv"
module WB (
  PipeLineData.MEM U_MEM,
  PipeLineData.WB U_WB,
  __PipeLineCtrl U_Pipe
);

  /* 流水线寄存器 */
  always_ff @(posedge U_WB.clk) begin
    if (U_WB.rst == `V_TRUE) begin
      U_Pipe.valid_wb <= `V_FALSE;
    end
    else if (U_Pipe.allowin_wb == `V_TRUE) begin
      U_Pipe.valid_wb <= U_Pipe.mem_to_wb_valid;
    end
    if (U_Pipe.mem_to_wb_valid == `V_TRUE && U_Pipe.allowin_wb == `V_TRUE) begin
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
      case (U_WB.ram_be)
        4'b0001: begin U_WB.rf_wdata <= {{24{U_WB.ram_data[ 7]}}, U_WB.ram_data[ 7: 0]}; end
        4'b0010: begin U_WB.rf_wdata <= {{24{U_WB.ram_data[13]}}, U_WB.ram_data[13: 8]}; end
        4'b0100: begin U_WB.rf_wdata <= {{24{U_WB.ram_data[23]}}, U_WB.ram_data[23:14]}; end
        4'b1000: begin U_WB.rf_wdata <= {{24{U_WB.ram_data[31]}}, U_WB.ram_data[31:24]}; end
        default: begin U_WB.rf_wdata <= U_WB.ram_data; end
      endcase
    end
    else begin
      U_WB.rf_wdata <= U_WB.alu_result;
    end
  end

endmodule