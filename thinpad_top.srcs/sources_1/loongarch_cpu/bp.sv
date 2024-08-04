`include "define.sv"
module BP (
  ICInterface U_IC,
  IDInterface U_ID,
  DecodeInterface U_D,
  input logic [`W_DATA] s_imm_16,
  input logic [`W_DATA] s_imm_26
);

  /* sel branch pc */
  logic [`W_DATA] branch_pc;
  logic           branch_flag;
  logic [`W_DATA] b_bl_pc;
  logic [`W_DATA] jirl_pc;
  logic [`W_DATA] comp_pc;

  assign b_bl_pc = U_ID.pc + {s_imm_26[29:0], 2'b0};
  assign jirl_pc = U_ID.rf_rdata1 + {s_imm_16[29:0], 2'b0};
  assign comp_pc = U_ID.pc + {s_imm_16[29:0], 2'b0};
  always @(*) begin
    if (U_D._b || U_D._bl) begin
      branch_flag = `V_TRUE;
      U_ID.branch_pc = b_bl_pc;
    end
    else if (U_D._jirl) begin
      branch_flag = `V_TRUE;
      U_ID.branch_pc = jirl_pc;
    end
    else if (U_D._beq && (U_ID.rf_rdata1 == U_ID.rf_rdata2)) begin
      branch_flag = `V_TRUE;
      U_ID.branch_pc = comp_pc;
    end
    else if (U_D._bne && (U_ID.rf_rdata1 != U_ID.rf_rdata2)) begin
      branch_flag = `V_TRUE;
      U_ID.branch_pc = comp_pc;
    end
    else if (U_D._bge && ($signed(U_ID.rf_rdata1) >= $signed(U_ID.rf_rdata2))) begin
      branch_flag = `V_TRUE;
      U_ID.branch_pc = comp_pc;
    end
    else begin
      branch_flag = `V_FALSE;
      U_ID.branch_pc = U_ID.pc + 32'h4;
    end
  end
  assign U_ID.branch_flag = (U_IC.bp_state != branch_flag);

  logic [`W_VADDR] tag;
  assign tag = U_ID.pc[`W_VADDR];
  always @(posedge U_ID.clk) begin
    if (U_ID.rst) begin
      for (int i = 0; i < `V_ICACHE; i = i + 1) begin
        U_IC.bp_pc[i] <= `V_ZERO;
      end
      U_IC.bp_state <= `V_ZERO;
    end
    else begin
      U_IC.bp_pc[tag] <= U_ID.branch_pc;
      U_IC.bp_state[tag] <= branch_flag;
    end
  end
  
endmodule