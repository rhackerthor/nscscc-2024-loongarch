`include "define.sv"
module ID (
  IFInterface.slave U_IF,
  IDInterface U_ID
);

  /* pipeline ctrl */
  always @(posedge U_ID.clk) begin
    if (U_ID.rst) begin
      U_ID.valid <= `V_FALSE;
    end
    else if (U_ID.branch_cancle) begin
      U_ID.valid <= `V_FALSE;
    end
    else if (U_ID.allowin) begin
      U_ID.valid <= U_ID.valid_in;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_ID.clk) begin
    if (U_ID.rst) begin
      U_ID.pc   <= `V_ZERO;
      U_ID.inst <= `V_ZERO;
    end
    else if (U_ID.valid_in && U_ID.allowin) begin
      U_ID.pc   <= U_IF.pc;
      U_ID.inst <= U_IF.inst;
    end
  end

  /* decode */ 
  /* 下面基本采用 */
  DecodeInterface U_D ();
  Decode Decode0 (U_ID.inst, U_D);

  /* immediate */
  logic [`W_SEL_IMM] sel_imm;
  assign sel_imm[`V_UI5] = |{
    U_D._srai_w, U_D._srli_w, U_D._slli_w
  };
  assign sel_imm[`V_UI12] = |{
    U_D._andi, U_D._ori
  };
  assign sel_imm[`V_SI12] = |{
    U_D._sltui, U_D._addi_w, U_D._ld_b, U_D._ld_w,
    U_D._st_b, U_D._st_w
  };
  assign sel_imm[`V_SI16] = |{
    U_D._jirl, U_D._beq, U_D._bne, U_D._bge
  };
  assign sel_imm[`V_SI20] = |{
    U_D._lu12i_w, U_D._pcaddu12i
  };
  assign sel_imm[`V_SI26] = |{
    U_D._b, U_D._bl
  };
  logic [`W_DATA] u_imm_5;
  logic [`W_DATA] u_imm_12;
  logic [`W_DATA] s_imm_12;
  logic [`W_DATA] s_imm_16;
  logic [`W_DATA] s_imm_20;
  logic [`W_DATA] s_imm_26;
  assign u_imm_5  = {27'b0, U_ID.inst[14:10]};
  assign u_imm_12 = {20'b0, U_ID.inst[21:10]};
  assign s_imm_12 = {{20{U_ID.inst[21]}}, U_ID.inst[21:10]};
  assign s_imm_16 = {{16{U_ID.inst[25]}}, U_ID.inst[25:10]};
  assign s_imm_20 = {U_ID.inst[24: 5], {12{1'b0}}};
  assign s_imm_26 = {{6{U_ID.inst[9]}}, U_ID.inst[9:0], U_ID.inst[25:10]};
  always @(*) begin
    case (sel_imm)
      `V__UI5 : begin U_ID.imm <= u_imm_5;  end 
      `V__UI12: begin U_ID.imm <= u_imm_12; end 
      `V__SI12: begin U_ID.imm <= s_imm_12; end 
      `V__SI16: begin U_ID.imm <= s_imm_16; end 
      `V__SI20: begin U_ID.imm <= s_imm_20; end 
      `V__SI26: begin U_ID.imm <= s_imm_26; end 
      default : begin U_ID.imm <= `V_ZERO;  end 
    endcase
  end

  /* 译码reg file相关信号 */
  logic rf_oe2_is_rd;
  assign rf_oe2_is_rd = |{
    U_D._st_b, U_D._st_w, U_D._beq, U_D._bne,
    U_D._bge
  };
  assign U_ID.rf_waddr  = U_D._bl ? 5'b00001 : U_ID.inst[`W_RF_RD];
  assign U_ID.rf_raddr1 = U_ID.inst[`W_RF_RJ];
  assign U_ID.rf_raddr2 = rf_oe2_is_rd ? U_ID.inst[`W_RF_RD] : U_ID.inst[`W_RF_RK];
  assign U_ID.rf_we  = |{
    U_D._add_w, U_D._sub_w, U_D._and, U_D._or,
    U_D._xor, U_D._mul_w, U_D._srai_w, U_D._srli_w,
    U_D._slli_w, U_D._sltui, U_D._addi_w, U_D._andi,
    U_D._ori, U_D._ld_b, U_D._ld_w, U_D._lu12i_w,
    U_D._pcaddu12i, U_D._jirl, U_D._bl
  };
  assign U_ID.rf_oe1 = |{
    U_D._add_w, U_D._sub_w, U_D._and, U_D._or,
    U_D._xor, U_D._mul_w, U_D._srai_w, U_D._srli_w,
    U_D._slli_w, U_D._sltui, U_D._addi_w, U_D._andi,
    U_D._ori, U_D._ld_b, U_D._ld_w, U_D._st_b,
    U_D._st_w, U_D._jirl, U_D._beq, U_D._bne,
    U_D._bge
  };
  assign U_ID.rf_oe2 = |{
    U_D._add_w, U_D._sub_w, U_D._and, U_D._or,
    U_D._xor, U_D._mul_w, U_D._st_b, U_D._st_w,
    U_D._beq, U_D._bne, U_D._bge
  };

  /* sel branch pc */
  always @(*) begin
    if (U_ID.rst) begin
      U_ID.branch_flag = `V_FALSE;
      U_ID.branch_pc   = `V_ZERO;
      U_ID.jirl_flag   = `V_FALSE;
      U_ID.comp_flag   = `V_FALSE;
    end
    else begin
      if (U_D._b || U_D._bl) begin
        U_ID.branch_flag = `V_TRUE;
        U_ID.branch_pc   = U_ID.pc + {s_imm_26[29:0], 2'b0};
        U_ID.jirl_flag   = `V_FALSE;
        U_ID.comp_flag   = `V_FALSE;
      end
      else if (U_D._jirl) begin
        U_ID.branch_flag = `V_TRUE;
        U_ID.branch_pc   = U_ID.rf_rdata1 + {s_imm_16[29:0], 2'b0};
        U_ID.jirl_flag   = `V_TRUE;
        U_ID.comp_flag   = `V_FALSE;
      end
      else if (U_D._beq && (U_ID.rf_rdata1 == U_ID.rf_rdata2)) begin
        U_ID.branch_flag = `V_TRUE;
        U_ID.branch_pc   = U_ID.pc + {s_imm_16[29:0], 2'b0};
        U_ID.jirl_flag   = `V_FALSE;
        U_ID.comp_flag   = `V_TRUE;
      end
      else if (U_D._bne && (U_ID.rf_rdata1 != U_ID.rf_rdata2)) begin
        U_ID.branch_flag = `V_TRUE;
        U_ID.branch_pc   = U_ID.pc + {s_imm_16[29:0], 2'b0};
        U_ID.jirl_flag   = `V_FALSE;
        U_ID.comp_flag   = `V_TRUE;
      end
      else if (U_D._bge && ($signed(U_ID.rf_rdata1) >= $signed(U_ID.rf_rdata2))) begin
        U_ID.branch_flag = `V_TRUE;
        U_ID.branch_pc   = U_ID.pc + {s_imm_16[29:0], 2'b0};
        U_ID.jirl_flag   = `V_FALSE;
        U_ID.comp_flag   = `V_TRUE;
      end
      else begin
        U_ID.branch_flag = `V_FALSE;
        U_ID.branch_pc   = `V_ZERO;
        U_ID.jirl_flag   = `V_FALSE;
        U_ID.comp_flag   = `V_FALSE;
      end
    end
  end

  /* alu */
  assign U_ID.alu_op[`V_ADD ] = |{U_D._add_w, U_D._addi_w, U_D._bl, U_D._jirl, U_D._pcaddu12i};
  assign U_ID.alu_op[`V_SUB ] = U_D._sub_w;
  assign U_ID.alu_op[`V_AND ] = |{U_D._and, U_D._andi};
  assign U_ID.alu_op[`V_OR  ] = |{U_D._or, U_D._ori};
  assign U_ID.alu_op[`V_XOR ] = U_D._xor;
  assign U_ID.alu_op[`V_MUL ] = U_D._mul_w;
  assign U_ID.alu_op[`V_SLL ] = U_D._slli_w;
  assign U_ID.alu_op[`V_SRL ] = U_D._srli_w;
  assign U_ID.alu_op[`V_SRA ] = U_D._srai_w;
  assign U_ID.alu_op[`V_SLTU] = U_D._sltui;
  assign U_ID.alu_op[`V_LUI ] = U_D._lu12i_w;

  logic sel_alu_in1;
  logic [`W_SEL_ALU_IN2] sel_alu_in2;
  /* sel alu in1: if alu in1 is pc */
  assign sel_alu_in1 = |{
    U_D._pcaddu12i, U_D._jirl, U_D._bl
  };
  assign U_ID.alu_in1 = sel_alu_in1 ? U_ID.pc : U_ID.rf_rdata1;

  /* sel alu in2 */
  /* if alu in2 is rk */
  assign sel_alu_in2[`V_IS_RK] = |{
    U_D._add_w, U_D._sub_w, U_D._and, U_D._or,
    U_D._xor, U_D._mul_w
  };
  /* if alu in2 is immediate */
  assign sel_alu_in2[`V_IS_IMM] = |{
    U_D._srai_w, U_D._srli_w, U_D._slli_w, U_D._sltui,
    U_D._addi_w, U_D._andi, U_D._ori, U_D._lu12i_w,
    U_D._pcaddu12i
  };
  assign sel_alu_in2[`V_IS_FOUR] = |{
    U_D._jirl, U_D._bl
  };
  always @(*) begin
    case (sel_alu_in2)
      `V__IS_RK  : begin U_ID.alu_in2 = U_ID.rf_rdata2; end
      `V__IS_IMM : begin U_ID.alu_in2 = U_ID.imm;       end
      `V__IS_FOUR: begin U_ID.alu_in2 = 32'h0000_0004;  end
      default    : begin U_ID.alu_in2 = `V_ZERO;        end
    endcase
  end

  /* ram */
  assign U_ID.store_flag[`V_ST_B] = U_D._st_b;
  assign U_ID.store_flag[`V_ST_W] = U_D._st_w;
  assign U_ID.load_flag[`V_LD_B]  = U_D._ld_b;
  assign U_ID.load_flag[`V_LD_W]  = U_D._ld_w;

endmodule