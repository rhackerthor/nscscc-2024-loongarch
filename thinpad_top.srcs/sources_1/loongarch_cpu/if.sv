`include "define.sv"
module IF (
  IFInterface U_IF,
  ICInterface U_IC,
  IDInterface U_ID
);

  /* pipeline ctrl */
  always @(posedge U_IF.clk) begin
    if (U_IF.rst) begin
      U_IF.valid <= `V_TRUE;
    end
    else if (U_IF.allowin) begin
      U_IF.valid <= U_IF.validin;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_IF.clk) begin
    if (U_IF.rst) begin
      U_IF.pc <= `V_RST_PC;
    end
    else if (U_IF.validin && U_IF.allowin) begin
      U_IF.pc <= U_IF.next_pc;
    end
  end

  /* 计算next pc */
  logic [`W_VADDR] tag;
  assign tag = U_IF.pc[`W_VADDR];
  assign U_IF.branch_flag = U_ID.branch_cancle;
  always @(*) begin
    if (U_IF.rst) begin 
      U_IF.next_pc = `V_ZERO;
    end
    else if (U_IF.branch_flag) begin 
      U_IF.next_pc = U_ID.branch_pc;
    end
    else if (U_IC.cache_valid[tag] && (|U_IC.bp_state[tag][3:2])) begin
      U_IF.next_pc = U_IC.bp_pc[tag];
    end
    else begin 
      U_IF.next_pc = U_IF.pc + 32'h4;
    end
  end  


endmodule