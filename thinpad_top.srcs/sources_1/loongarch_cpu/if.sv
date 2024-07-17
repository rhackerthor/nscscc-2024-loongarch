`include "define.sv"
module IF (
  IFInterface  U_IF,
  IDInterface  U_ID,
  IcacheInterface U_IC
);

  logic [`W_SEL_NEXT_PC] sel_next_pc;
  logic [`W_DATA       ] next_pc;
  logic [`W_DATA       ] seq_pc;

  /* pipeline ctrl */
  always @(posedge U_IF.clk) begin
    if (U_IF.rst == `V_TRUE) begin
      U_IF.valid <= `V_FALSE;
    end
    else if (U_IF.allowin == `V_TRUE) begin
      U_IF.valid <= U_IF.valid_in;
    end
  end

  /* 流水线寄存器 */
  always_ff @(posedge U_IF.clk) begin
    if (U_IF.rst == `V_TRUE) begin
      U_IF.pc <= `R_PC;
    end
    else if (U_IF.valid_in && U_IF.allowin == `V_TRUE) begin
      U_IF.pc <= next_pc;
    end
  end
  assign U_IF.inst = U_IC.data[U_IF.pc[6:2]];

  /* 计算next pc */
  assign seq_pc      = U_IF.pc + 32'h0000_0004;
  assign branch_flag = U_ID.branch_flag & U_ID.branch_cancle;
  always_ff @(*) begin
    if (U_IF.rst == `V_TRUE) begin
      next_pc = `V_ZERO;
    end
    else begin
      if (branch_flag) begin next_pc = U_ID.branch_pc; end
      else             begin next_pc = seq_pc;         end
    end
  end  

  /* 输出inst ram地址 */
  assign U_IC.addr = next_pc;
  assign U_IC.ce   = ~U_IF.rst & U_IF.allowin;

endmodule