`include "define.sv"
module Icache (
  IcacheInterface U_IC,
  RamInterface    U_RAM
);
  logic [`W_ICACHE] vaddr;
  logic [`W_DATA] pre_pc;
  logic [`W_DATA] icache_rdata;

  assign vaddr = U_IC.addr[6:2];

  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      for (int i = 0; i < `V_ICACHE; i = i + 1) begin
        U_IC.pc[i]    <= `V_ZERO;
        U_IC.data[i]  <= `V_ZERO;
        pre_pc        <= `V_ZERO;
      end
    end
    else if (~U_IC.cache_valid) begin
      U_IC.pc[vaddr]         <= U_IC.addr;
      pre_pc                 <= U_IC.addr;
      U_IC.data[pre_pc[6:2]] <= U_RAM.inst_ram_rdata;
    end
  end 

  always @(*) begin
    if (U_IC.addr != U_IC.pc[vaddr]) begin
      U_IC.cache_valid = `V_FALSE;
    end
    else begin
      U_IC.cache_valid = `V_TRUE;
    end
  end

  assign U_RAM.inst_ram_addr = U_IC.addr;
  assign U_RAM.inst_ram_ce   = U_IC.ce;

endmodule