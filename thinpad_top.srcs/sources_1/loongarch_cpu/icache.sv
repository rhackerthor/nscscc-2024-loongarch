`include "define.sv"
module IC (
  IFInterface  U_IF,
  ICInterface  U_IC,
  RamInterface U_RAM
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

  logic [`W_DATA] inst_r;
  logic inst_ram_ce_r;
  always @(posedge U_IC.clk) begin
    if (U_IC.cnt[0]) begin
      inst_r <= U_RAM.inst_ram_rdata;
    end
    inst_ram_ce_r <= U_RAM.inst_ram_ce;
  end
  assign U_IC.inst = ~inst_ram_ce_r ? inst_r : U_RAM.inst_ram_rdata;

endmodule