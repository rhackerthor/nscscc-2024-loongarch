module EXE (
  PipeLine.ID U_ID,
  PipeLine.EXE U_EXE,
  Ram U_RAM
);

  /* 流水线寄存器 */
  always_ff @(posedge U_EXE.clk) begin
    if (U_EXE.rst == `V_TRUE) begin
      U_EXE.valid <= `V_FALSE;
    end
    else if (U_EXE.allownin == `V_TRUE) begin
      U_EXE.valid <= U_EXE.validin;
    end
    if (U_EXE.allownin == `V_TRUE) begin
      U_EXE.pc        <= U_ID.pc;
      U_EXE.inst      <= U_ID.inst;
      U_EXE.d_inst    <= U_ID.d_inst;
      U_EXE.imm       <= U_ID.imm;
      U_EXE.rf_rdata1 <= U_ID.rf_rdata1;
      U_EXE.rf_rdata2 <= U_ID.rf_rdata2;
      U_EXE.rf_waddr  <= U_ID.rf_waddr;
    end
  end
  /* 发送读写请求 */
  assign U_EXE.ram_addr = U_ID.rf_rdata1 + U_ID.imm;
  always_ff @(*) begin
    U_EXE.ram_be <= `V_ONE;
    if (`V_ST_W == `V_TRUE || `V_LD_W == `V_TRUE) begin
      U_EXE.ram_be <= `V_ONE;
    end
    else if (`V_ST_B == `V_TRUE || `V_LD_B == `V_TRUE)  begin
      case (U_EXE.ram_addr[1:0])
        2'b00: begin U_EXE.ram_be <= 4'b0001; end
        2'b01: begin U_EXE.ram_be <= 4'b0010; end
        2'b10: begin U_EXE.ram_be <= 4'b0100; end
        2'b11: begin U_EXE.ram_be <= 4'b1000; end
        default: begin U_EXE.ram_be <= `V_ONE; end
      endcase
    end
  end
  assign U_EXE.ram_oe = `V_LD_B | `V_LD_W;
  assign U_EXE.ram_we = `V_ST_B | `V_ST_W;
  assign U_RAM.data_ram_wdata = U_EXE.ram_data;


endmodule