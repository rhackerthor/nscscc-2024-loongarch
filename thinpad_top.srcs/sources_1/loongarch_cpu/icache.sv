`include "define.sv"
module IC (
  IcacheIterface U_IC,
  IFInterface    U_IF,
  RamInterface   U_RAM
);

  always @(posedge U_IC.clk) begin
    if (U_IC.rst) begin
      for (int i = 0; i < `V_ICACHE; i = i + 1) begin
        U_IC.pc[i]   <= `V_ZERO;
        U_IC.inst[i] <= `V_ZERO;
      end
      U_IC.we <= `V_ZERO;
    end
    else begin
      if (U_IC.miss) begin
        U_IC.pc[U_IF.next_pc[`W_VADDR]] <= U_IF.next_pc;
        U_IC.we <= `V_TRUE;
      end
      else if (U_IC.we) begin
        U_IC.inst[U_IF.next_pc[`W_VADDR]] <= U_RAM.inst_ram_rdata;
        U_IC.we <= `V_FALSE;
      end
    end
  end
  U_IF.inst = U_IC.inst[U_IF.pc[`W_VADDR]];

  always @(*) begin
    if (U_IC.rst) begin
      U_IC.miss = `V_FALSE;
    end
    else if ((U_IF.next_pc != U_IC.pc[U_IF.next_pc[`W_VADDR]])) begin
      U_IC.miss = `V_TRUE;
    end
    else begin
      U_IC.miss = `V_FALSE;
    end
  end

endmodule