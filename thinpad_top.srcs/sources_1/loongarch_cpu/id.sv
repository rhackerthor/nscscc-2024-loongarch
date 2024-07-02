`include "define.sv"
module ID (
  PipeLineData U_IF,
  PipeLineData U_ID,
  __PipeLineCtrl U_Pipe
);

  /* 流水线寄存器 */
  always_ff @(posedge U_ID.clk) begin
    if (U_ID.rst == `V_TRUE) begin
      U_Pipe.valid_id <= `V_FALSE;
    end
    else if (U_Pipe.br_cancle == `V_TRUE) begin
      U_Pipe.valid_id <= `V_FALSE;
    end
    else if (U_Pipe.allowin_id == `V_TRUE) begin
      U_Pipe.valid_id <= U_Pipe.if_to_id_valid;
    end
    if (U_Pipe.if_to_id_valid == `V_TRUE && U_Pipe.allowin_id == `V_TRUE) begin
      U_ID.pc   <= U_IF.pc;
      U_ID.inst <= U_IF.inst;
    end
  end
  /* 生成decode inst */
  logic [63:0] opcode_31_26, opcode_25_20;
  logic [15:0] opcode_25_22;
  logic [31:0] opcode_19_15;
  decoder_6_64 d_opcode_31_26 (U_ID.inst[31:26], opcode_31_26);
  decoder_6_64 d_opcode_25_20 (U_ID.inst[25:20], opcode_25_20);
  decoder_4_16 d_opcode_25_22 (U_ID.inst[25:22], opcode_25_22);
  decoder_5_32 d_opcode_19_15 (U_ID.inst[19:15], opcode_19_15);
  logic inst_add_w;
  logic inst_sub_w;
  logic inst_and;
  logic inst_or;
  logic inst_xor;
  logic inst_mul_w;
  logic inst_srai_w;
  logic inst_srli_w;
  logic inst_slli_w;
  logic inst_sltui;
  logic inst_addi_w;
  logic inst_andi;
  logic inst_ori;
  logic inst_ld_b;
  logic inst_ld_w;
  logic inst_st_b;
  logic inst_st_w;
  logic inst_lu12i_w;
  logic inst_pcaddu12i;
  logic inst_jirl;
  logic inst_b;
  logic inst_bl;
  logic inst_beq;
  logic inst_bne;
  logic inst_bge;
  assign inst_add_w     =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b00000];
  assign inst_sub_w     =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b00010];
  assign inst_and       =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b01001];
  assign inst_or        =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b01010];
  assign inst_xor       =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b01011];
  assign inst_mul_w     =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b11000];
  assign inst_srai_w    =  opcode_31_26[6'b000000] & opcode_25_20[6'b000100] & opcode_19_15[5'b10001];
  assign inst_srli_w    =  opcode_31_26[6'b000000] & opcode_25_20[6'b000100] & opcode_19_15[5'b01001];
  assign inst_slli_w    =  opcode_31_26[6'b000000] & opcode_25_20[6'b000100] & opcode_19_15[5'b00001];
  assign inst_sltui     =  opcode_31_26[6'b000000] & opcode_25_22[4'b1001];
  assign inst_addi_w    =  opcode_31_26[6'b000000] & opcode_25_22[4'b1010];
  assign inst_andi      =  opcode_31_26[6'b000000] & opcode_25_22[4'b1101];
  assign inst_ori       =  opcode_31_26[6'b000000] & opcode_25_22[4'b1110];
  assign inst_ld_b      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0000];
  assign inst_ld_w      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0010];
  assign inst_st_b      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0100];
  assign inst_st_w      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0110];
  assign inst_lu12i_w   =  opcode_31_26[6'b000101] & ~U_ID.inst[25];
  assign inst_pcaddu12i =  opcode_31_26[6'b000111] & ~U_ID.inst[25];
  assign inst_jirl      =  opcode_31_26[6'b010011];
  assign inst_b         =  opcode_31_26[6'b010100];
  assign inst_bl        =  opcode_31_26[6'b010101];
  assign inst_beq       =  opcode_31_26[6'b010110];
  assign inst_bne       =  opcode_31_26[6'b010111];
  assign inst_bge       =  opcode_31_26[6'b011001];
  /* immediate */
  logic [`W_SEL_IMM] sel_imm;
  assign sel_imm[`V_UI5 ] = |{inst_slli_w, inst_srli_w, inst_srai_w};
  assign sel_imm[`V_UI12] = |{inst_andi, inst_ori};
  assign sel_imm[`V_SI12] = |{inst_addi_w, inst_sltui, inst_st_b, inst_st_w, inst_ld_b, inst_ld_w};
  assign sel_imm[`V_SI16] = |{inst_beq, inst_bne, inst_bge, inst_jirl};
  assign sel_imm[`V_SI20] = |{inst_lu12i_w, inst_pcaddu12i};
  assign sel_imm[`V_SI26] = |{inst_b, inst_bl};
  logic [`W_DATA] u_imm_5;
  logic [`W_DATA] u_imm_12;
  logic [`W_DATA] s_imm_12;
  logic [`W_DATA] s_imm_16;
  logic [`W_DATA] s_imm_20;
  logic [`W_DATA] s_imm_26;
  assign u_imm_5  = {27'b0, U_ID.inst[19:15]};
  assign u_imm_12 = {20'b0, U_ID.inst[21:10]};
  assign s_imm_12 = {{20{U_ID.inst[21]}}, U_ID.inst[21:10]};
  assign s_imm_16 = {{16{U_ID.inst[25]}}, U_ID.inst[25:10]};
  assign s_imm_20 = {U_ID.inst[24: 5], {12{1'b0}}};
  assign s_imm_26 = {{6{U_ID.inst[9]}}, U_ID.inst[9:0], U_ID.inst[25:10]};
  always_ff @(*) begin
    case (sel_imm)
      `V__UI5 : begin U_ID.imm <= u_imm_5; end 
      `V__UI12: begin U_ID.imm <= u_imm_12; end 
      `V__SI12: begin U_ID.imm <= s_imm_12; end 
      `V__SI16: begin U_ID.imm <= s_imm_16; end 
      `V__SI20: begin U_ID.imm <= s_imm_20; end 
      `V__SI26: begin U_ID.imm <= s_imm_26; end 
      default : begin U_ID.imm <= `V_ZERO; end 
    endcase
  end
  /* 译码reg file相关信号 */
  logic is_rd;
  assign is_rd = |{inst_st_b, inst_st_w, inst_beq, inst_bne, inst_bge};
  assign U_ID.rf_waddr  = U_ID.inst[`W_RF_RD];
  assign U_ID.rf_raddr1 = U_ID.inst[`W_RF_RJ];
  assign U_ID.rf_raddr2 = is_rd == `V_FALSE ? U_ID.inst[`W_RF_RK] : U_ID.inst[`W_RF_RD];
  assign U_ID.rf_we  = &{~inst_b, ~inst_beq, ~inst_bge, ~inst_bne, ~inst_st_b, ~inst_st_w};
  assign U_ID.rf_oe1 = &{~inst_b, ~inst_bl, ~inst_lu12i_w, ~inst_pcaddu12i};
  assign U_ID.rf_oe2 = |{inst_add_w, inst_sub_w, inst_and, inst_or, inst_xor, inst_beq, inst_bne, inst_bge, inst_st_b, inst_st_w};
  /* 分支跳转相关 */
  assign U_ID.sel_next_pc[`V_SEQ ] = &{~U_ID.sel_next_pc[`V_COMP:`V_B_BL]};
  assign U_ID.sel_next_pc[`V_B_BL] = |{inst_b, inst_bl};
  assign U_ID.sel_next_pc[`V_JUMP] = inst_jirl;
  assign U_ID.sel_next_pc[`V_COMP] = (inst_beq == `V_TRUE && U_ID.rf_rdata1 == U_ID.rf_rdata2) |
                                     (inst_bne == `V_TRUE && U_ID.rf_rdata1 != U_ID.rf_rdata2) |
                                     (inst_bge == `V_TRUE && U_ID.rf_rdata1 >= U_ID.rf_rdata2);
  assign U_ID.b_bl_pc = U_ID.pc + {s_imm_26[29:0], 2'b0};
  assign U_ID.jump_pc = U_ID.rf_rdata1 + {s_imm_16[29:0], 2'b0};
  assign U_ID.comp_pc = U_ID.pc + {s_imm_16[29:0], 2'b0};
  /* alu */
  assign U_ID.alu_op[`V_ADD ] = |{inst_add_w, inst_addi_w, inst_bl, inst_jirl, inst_pcaddu12i};
  assign U_ID.alu_op[`V_SUB ] = inst_sub_w;
  assign U_ID.alu_op[`V_AND ] = |{inst_and, inst_andi};
  assign U_ID.alu_op[`V_OR  ] = |{inst_or, inst_ori};
  assign U_ID.alu_op[`V_XOR ] = inst_xor;
  assign U_ID.alu_op[`V_MUL ] = inst_mul_w;
  assign U_ID.alu_op[`V_SLL ] = inst_slli_w;
  assign U_ID.alu_op[`V_SRL ] = inst_srli_w;
  assign U_ID.alu_op[`V_SRA ] = inst_srai_w;
  assign U_ID.alu_op[`V_SLTU] = inst_sltui;
  assign U_ID.alu_op[`V_LUI ] = inst_lu12i_w;
  /* sel alu in2 */
  assign U_ID.sel_alu_in1 = |{inst_bl, inst_jirl, inst_pcaddu12i};
  /* sel alu in2 */
  assign U_ID.sel_alu_in2[`V_IS_RK  ] = |{inst_add_w, inst_sub_w, inst_and, inst_or, inst_xor, inst_mul_w};
  assign U_ID.sel_alu_in2[`V_IS_IMM ] = |{inst_addi_w, inst_andi, inst_ori, inst_slli_w, inst_srli_w, inst_srai_w, inst_sltui, inst_lu12i_w};
  assign U_ID.sel_alu_in2[`V_IS_FORE] = |{inst_bl, inst_jirl};
  /* ram */
  assign U_ID.store[`V_ST_B] = inst_st_b;
  assign U_ID.store[`V_ST_W] = inst_st_w;
  assign U_ID.load[`V_LD_B] = inst_ld_b;
  assign U_ID.load[`V_LD_W] = inst_ld_w;
  /* jump and comp */
  assign U_ID.branch = |{inst_jirl, inst_beq, inst_bne, inst_bge};
  /* unsigned */
  assign U_ID.uflag = inst_sltui;

endmodule