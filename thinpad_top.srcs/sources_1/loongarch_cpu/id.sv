`include "define.sv"
module ID (
  IFInterface U_IF,
  IDInterface U_ID
);

  /* pipeline ctrl */
  always_ff @(posedge U_ID.clk) begin
    if (U_ID.rst == `V_TRUE) begin
      U_ID.valid <= `V_FALSE;
    end
    else if (U_ID.branch_cancle == `V_TRUE) begin
      U_ID.valid <= `V_FALSE;
    end
    else if (U_ID.allowin == `V_TRUE) begin
      U_ID.valid <= U_ID.valid_in;
    end
  end

  /* 流水线寄存器 */
  always_ff @(posedge U_ID.clk) begin
    if (U_ID.valid_in == `V_TRUE && U_ID.allowin == `V_TRUE) begin
      U_ID.pc   <= U_IF.pc;
      U_ID.inst <= U_IF.inst;
    end
  end

  /* decode */ 
  DecodeInterface U_D ();
  Decode Decode0 (U_ID.inst, U_D);

  /* immediate */
  logic [`W_SEL_IMM] sel_imm;
  assign sel_imm[`V_UI5 ] = |{U_D._slli_w, U_D._srli_w, U_D._srai_w};
  assign sel_imm[`V_UI12] = |{U_D._andi, U_D._ori, U_D._xori};
  assign sel_imm[`V_SI12] = |{U_D._addi_w, U_D._sltui, U_D._slti, U_D._st_b, U_D._st_w, U_D._ld_b, U_D._ld_w};
  assign sel_imm[`V_SI16] = |{U_D._beq, U_D._bne, U_D._blt, U_D._bge, U_D._bltu, U_D._bgeu, U_D._jirl};
  assign sel_imm[`V_SI20] = |{U_D._lu12i_w, U_D._pcaddu12i};
  assign sel_imm[`V_SI26] = |{U_D._b, U_D._bl};
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
  always_ff @(*) begin
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
  logic is_rd;
  assign is_rd = |{U_D._st_b, U_D._st_w, U_D._beq, U_D._bne, U_D._bge, U_D._bgeu, U_D._bltu};
  assign U_ID.rf_waddr  = U_ID.inst[`W_RF_RD];
  assign U_ID.rf_raddr1 = U_ID.inst[`W_RF_RJ];
  assign U_ID.rf_raddr2 = ~is_rd ? U_ID.inst[`W_RF_RK] : U_ID.inst[`W_RF_RD];
  assign U_ID.rf_we  = &{~U_D._b, ~U_D._beq, ~U_D._bge, ~U_D._blt, ~U_D._bltu, ~U_D._bgeu, ~U_D._bne, ~U_D._st_b, ~U_D._st_w};
  assign U_ID.rf_oe1 = &{~U_D._b, ~U_D._bl, ~U_D._lu12i_w, ~U_D._pcaddu12i};
  assign U_ID.rf_oe2 = |{
                          U_D._add_w, U_D._sub_w, U_D._and, U_D._or, U_D._xor, U_D._nor,
                          U_D._beq, U_D._bne, U_D._bge, U_D._bgeu, U_D._blt, U_D._bltu,
                          U_D._sll_w, U_D._srl_w, U_D._sra_w, U_D._slt, U_D._sltu,
                          U_D._st_b, U_D._st_w
                        };

  always @(*) begin
    if (U_ID.rst) begin
      U_ID.branch_flag = `V_FALSE;
      U_ID.branch_pc   = `V_ZERO;
      U_ID.jirl_flag   = `V_FALSE;
      U_ID.comp_flag   = `V_FALSE;
    end
    else begin
      if (U_D._b && U_D._bl) begin
        U_ID.branch_flag = `V_TRUE;
        U_ID.branch_pc   = U_ID.pc + {s_imm_16[29:0], 2'b0};
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
  assign U_ID.alu_op[`V_XOR ] = |{U_D._xor, U_D._xori};
  assign U_ID.alu_op[`V_MUL ] = U_D._mul_w;
  assign U_ID.alu_op[`V_SLL ] = |{U_D._sll_w, U_D._slli_w};
  assign U_ID.alu_op[`V_SRL ] = |{U_D._srl_w, U_D._srli_w};
  assign U_ID.alu_op[`V_SRA ] = |{U_D._sra_w, U_D._srai_w};
  assign U_ID.alu_op[`V_SLT ] = |{U_D._slt, U_D._slti};
  assign U_ID.alu_op[`V_SLTU] = |{U_D._sltu, U_D._sltui};
  assign U_ID.alu_op[`V_LUI ] = U_D._lu12i_w;

  logic sel_alu_in1;
  logic [`W_SEL_ALU_IN2] sel_alu_in2;
  /* sel alu in1 */
  assign sel_alu_in1 = |{U_D._bl, U_D._jirl, U_D._pcaddu12i};
  /* sel alu in2 */
  assign sel_alu_in2[`V_IS_RK  ] = |{
                                      U_D._add_w, U_D._sub_w, U_D._mul_w,
                                      U_D._and, U_D._or, U_D._xor, U_D._nor, U_D._sltu
                                    };
  assign sel_alu_in2[`V_IS_IMM ] = |{
                                      U_D._addi_w, U_D._andi, U_D._ori, U_D._xori,
                                      U_D._slli_w, U_D._srli_w, U_D._srai_w,
                                      U_D._slti, U_D._sltui, U_D._lu12i_w, U_D._pcaddu12i
                                    };
  assign sel_alu_in2[`V_IS_FOUE] = |{U_D._bl, U_D._jirl};
  always @(*) begin
    U_ID.alu_in1 = sel_alu_in1 ? U_ID.pc : U_ID.rf_rdata1;
    case (sel_alu_in2)
      `V__IS_RK  : begin U_ID.alu_in2 = U_ID.rf_rdata2; end
      `V__IS_IMM : begin U_ID.alu_in2 = U_ID.imm;       end
      `V__IS_FOUE: begin U_ID.alu_in2 = 32'h0000_0004;  end
      default    : begin U_ID.alu_in2 = `V_ZERO;        end
    endcase
  end

  /* ram */
  assign U_ID.store_flag[`V_ST_B] = U_D._st_b;
  assign U_ID.store_flag[`V_ST_W] = U_D._st_w;
  assign U_ID.load_flag[`V_LD_B]  = U_D._ld_b;
  assign U_ID.load_flag[`V_LD_W]  = U_D._ld_w;

endmodule