`include "define.sv"
module IC (
  IFInterface     U_IF,
  ICInterface     U_IC,
  RamInterface    U_RAM,
  DecodeInterface U_IC_D
);

  /* pipeline ctrl */
  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      U_IC.valid <= `V_FALSE;
    end
    else if (U_IC.allowin) begin
      U_IC.valid <= U_IC.validin;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      U_IC.pc  <= `V_ZERO;
    end
    else if (U_IC.validin && U_IC.allowin) begin
      U_IC.pc  <= U_IF.next_pc;
    end
  end

  logic [2:0] miss_stop;
  logic [`W_VADDR] tag;
  assign tag = U_IC.pc[`W_VADDR];
  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      for (int i = 0; i < `V_ICACHE; i = i + 1) begin
        U_IC.tag[i]  <= `V_ZERO;
        U_IC.data[i] <= `V_ZERO;
      end
      U_IC.cache_valid <= `V_ZERO;
      U_IC.we   <= `V_FALSE;
      miss_stop <= 1;
    end
    else begin
      if (U_IC.miss) begin
        miss_stop <= {miss_stop[1:0], miss_stop[2]};
        U_IC.cache_valid[tag] <= `V_FALSE;
      end
      if (miss_stop[2]) begin
        U_IC.we <= `V_TRUE;
        U_IC.tag[tag] <= U_IC.pc;
      end
      if (U_IC.we) begin
        U_IC.we <= `V_FALSE;
        U_IC.data[tag] <= U_RAM.inst_ram_rdata;
        U_IC.cache_valid[tag] <= `V_TRUE;
      end
    end
  end

  always @(*) begin
    if (U_RAM.inst_ram_busy) begin
      U_IC.miss = `V_FALSE;
    end
    else if (U_IC.pc != U_IC.tag[tag]) begin
      U_IC.miss = `V_TRUE;
    end
    else begin
      U_IC.miss = `V_FALSE;
    end
  end

  /* 输出inst ram地址 */
  assign U_RAM.inst_ram_addr = U_IC.pc;
  assign U_RAM.inst_ram_ce = U_IF.allowin && (~U_RAM.inst_ram_busy) && U_IC.miss;
  assign U_IC.inst = U_IC.we ? U_RAM.inst_ram_rdata : U_IC.data[tag];
  Decode Decode_IC (U_IC.inst, U_IC_D);

endmodule