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
      U_IC.valid <= U_IC.valid_in;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      U_IC.pc  <= `V_ZERO;
      U_IC.cnt <= `V_ZERO;
    end
    else if (U_IC.valid_in && U_IC.allowin) begin
      U_IC.pc  <= U_IF.next_pc;
      U_IC.cnt <= 1;
    end
    else begin
      U_IC.cnt <= {U_IC.cnt[6:0], U_IC.cnt[7]};
    end
  end

  logic miss_stop;
  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      for (int i = 0; i < `V_ICACHE; i = i + 1) begin
        U_IC.tag[i]  <= `V_ZERO;
        U_IC.data[i] <= `V_ZERO;
      end
      U_IC.we   <= `V_FALSE;
      miss_stop <= `V_FALSE;
    end
    else begin
      if (U_IC.miss && ~miss_stop) begin
        miss_stop <= `V_TRUE;
      end
      if (miss_stop) begin
        miss_stop <= `V_FALSE;
        U_IC.we <= `V_TRUE;
        U_IC.tag[U_IC.pc[`W_VADDR]] <= U_IC.pc;
      end
      if (U_IC.we) begin
        U_IC.we <= `V_FALSE;
        U_IC.data[U_IC.pc[`W_VADDR]] <= U_RAM.inst_ram_rdata;
      end
    end
  end

  always @(*) begin
    if (U_RAM.inst_ram_busy) begin
      U_IC.miss = `V_FALSE;
    end
    else if (U_IC.pc != U_IC.tag[U_IC.pc[`W_VADDR]]) begin
      U_IC.miss = `V_TRUE;
    end
    else begin
      U_IC.miss = `V_FALSE;
    end
  end

  /* 输出inst ram地址 */
  assign U_RAM.inst_ram_addr = U_IC.pc;
  assign U_RAM.inst_ram_ce = U_IF.allowin && (~U_RAM.inst_ram_busy);
  assign U_IC.inst = U_IC.we ? U_RAM.inst_ram_rdata : U_IC.data[U_IC.pc[`W_VADDR]];
  Decode Decode_IC (U_IC.inst, U_IC_D);

endmodule