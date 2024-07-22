`include "define.sv"
module WB (
  EXEInterface   U_EXE,
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
    end
    else if (U_WB.valid_in && U_WB.allowin) begin
      U_WB.pc         <= U_EXE.pc;
      U_WB.inst       <= U_EXE.inst;
      U_WB.rf_waddr   <= U_EXE.rf_waddr;
      U_WB.rf_we      <= U_EXE.rf_we;
      U_WB.alu_result <= U_EXE.alu_result;
      U_WB.ram_mask   <= U_EXE.ram_mask;
      U_WB.load_flag  <= U_EXE.load_flag;
    end
  end

  /* mem */
  always @(*) begin
    case (U_WB.ram_mask) 
      4'b0001: begin U_WB.ram_data = {{24{U_RAM.data_ram_rdata[ 7]}}, U_RAM.data_ram_rdata[ 7: 0]}; end
      4'b0010: begin U_WB.ram_data = {{24{U_RAM.data_ram_rdata[15]}}, U_RAM.data_ram_rdata[15: 8]}; end
      4'b0100: begin U_WB.ram_data = {{24{U_RAM.data_ram_rdata[23]}}, U_RAM.data_ram_rdata[23:16]}; end
      4'b1000: begin U_WB.ram_data = {{24{U_RAM.data_ram_rdata[31]}}, U_RAM.data_ram_rdata[31:24]}; end
      4'b1111: begin U_WB.ram_data = U_RAM.data_ram_rdata; end
      default: begin U_WB.ram_data = `V_ZERO;              end
    endcase
  end

  /* write back */
  always @(*) begin
    if (|U_WB.load_flag) begin
      U_WB.rf_wdata <= U_WB.ram_data;
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