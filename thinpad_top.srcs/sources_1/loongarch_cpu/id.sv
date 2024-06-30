`include "define.sv"
module ID (
  PipeLineData.IF U_IF,
  PipeLineData.ID U_ID,
  PipeLineCtrl U_Pipe
);

  /* 流水线寄存器 */
  always_ff @(posedge U_ID.clk) begin
    if (U_ID.rst == `V_TRUE) begin
      U_Pipe.valid_id <= `V_FALSE;
    end
    else if (U_Pipe.allownin_id == `V_TRUE) begin
      U_Pipe.valid_id <= U_Pipe.if_to_id_valid;
    end
    if (U_Pipe.if_to_id_valid == `V_TRUE && U_Pipe.allownin_id == `V_TRUE) begin
      U_ID.pc   <= U_IF.pc;
      U_ID.inst <= U_IF.inst;
    end
  end
  /* 生成decode inst */
  logic [63:0] d_opcode_31_26, d_opcode_25_20;
  logic [15:0] d_opcode_25_22;
  logic [31:0] d_opcode_19_15;
  decoder_6_64 d_opcode_31_26 (U_ID.inst[31:26], opcode_31_26);
  decoder_6_64 d_opcode_25_20 (U_ID.inst[25:20], opcode_25_20);
  decoder_4_16 d_opcode_25_22 (U_ID.inst[25:22], opcode_25_22);
  decoder_5_32 d_opcode_19_15 (U_ID.inst[19:15], opcode_19_15);
  logic inst_add_w     =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b00000];
  logic inst_sub_w     =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b00010];
  logic inst_and       =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b01001];
  logic inst_or        =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b01010];
  logic inst_xor       =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b01011];
  logic inst_mul_w     =  opcode_31_26[6'b000000] & opcode_25_20[6'b000001] & opcode_19_15[5'b11000];
  logic inst_srai_w    =  opcode_31_26[6'b000000] & opcode_25_20[6'b000100] & opcode_19_15[5'b10001];
  logic inst_srli_w    =  opcode_31_26[6'b000000] & opcode_25_20[6'b000100] & opcode_19_15[5'b01001];
  logic inst_slli_w    =  opcode_31_26[6'b000000] & opcode_25_20[6'b000100] & opcode_19_15[5'b00001];
  logic inst_sltui     =  opcode_31_26[6'b000000] & opcode_25_22[4'b1001];
  logic inst_addi_w    =  opcode_31_26[6'b000000] & opcode_25_22[4'b1010];
  logic inst_andi      =  opcode_31_26[6'b000000] & opcode_25_22[4'b1101];
  logic inst_ori       =  opcode_31_26[6'b000000] & opcode_25_22[4'b1110];
  logic inst_ld_b      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0000];
  logic inst_ld_w      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0010];
  logic inst_st_b      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0100];
  logic inst_st_w      =  opcode_31_26[6'b001010] & opcode_25_22[4'b0110];
  logic inst_lu12i_w   =  opcode_31_26[6'b000101] & ~inst[25];
  logic inst_pcaddu12i =  opcode_31_26[6'b000111] & ~inst[25];
  logic inst_jirl      =  opcode_31_26[6'b010011];
  logic inst_b         =  opcode_31_26[6'b010100];
  logic inst_bl        =  opcode_31_26[6'b010101];
  logic inst_beq       =  opcode_31_26[6'b010110];
  logic inst_bne       =  opcode_31_26[6'b010111];
  logic inst_bge       =  opcode_31_26[6'b011001];
  /* immediate */
  logic [`W_SEL_IMM] sel_imm;
  assign sel_imm[`V_UI5 ] = |{inst_slli_w, inst_srli_w, inst_srai_w};
  assign sel_imm[`V_UI12] = |{inst_andi, inst_ori};
  assign sel_imm[`V_SI12] = |{inst_addi_w, inst_sltui, inst_st_b, inst_st_w, inst_ld_b, inst_ld_w};
  assign sel_imm[`V_SI16] = |{inst_beq, inst_bne, inst_bge, inst_jirl};
  assign sel_imm[`V_SI20] = |{inst_lu12i_w, inst_pcaddu12i};
  assign sel_imm[`V_SI26] = |{inst_b, inst_bl};
  logic [`W_DATA] u_imm_5  = {{27'b0, U_ID.inst[19:15]};
  logic [`W_DATA] u_imm_12 = {{20'b0, U_ID.inst[21:10]};
  logic [`W_DATA] s_imm_12 = {{20{U_ID.inst[21]}}, U_ID.inst[21:10]};
  logic [`W_DATA] s_imm_16 = {{16{U_ID.inst[25]}}, U_ID.inst[25:10]};
  logic [`W_DATA] s_imm_20 = {U_ID.inst[24: 5], {12{1'b0}}};
  logic [`W_DATA] s_imm_26 = {{6{U_ID.inst[9]}}, U_ID.inst[9:0], U_ID.inst[25:10]};
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
  assign is_rd = {inst_st_b, inst_st_w, inst_beq, inst_bne, inst_bge};
  assign U_ID.rf_waddr  = U_ID.inst[`W_RF_RD];
  assign U_ID.rf_raddr1 = U_ID.inst[`W_RF_RJ];
  assign U_ID.rf_raddr2 = is_rd == `V_FALSE ? U_ID.inst[`W_RF_RK] : U_ID.inst[`W_RF_RD];
  assign U_ID.rf_we  = &{~inst_b, ~inst_beq, ~inst_bge, ~inst_bne, ~inst_st_b, ~inst_st_w};
  assign U_ID.rf_oe1 = &{~inst_b, ~inst_bl, ~inst_lu12i_w, ~inst_pcaddu12i};
  assign U_ID.rf_oe2 = |{inst_add_w, inst_sub_w, inst_and, inst_or, inst_xor, inst_mul_w, inst_st_b, inst_st_w};
  /* 分支跳转相关 */
  assign U_ID.sel_next_pc[`V_SEQ ] = |{sel_next_pc[`V_COMP:`V_B_BL]};
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
  assign U_ID.sel_alu_in2[`V_IS_RK  ] = |{inst_add_w, inst_sub_w, inst_and, inst_or, inst_xor, inst_mul};
  assign U_ID.sel_alu_in2[`V_IS_IMM ] = |{inst_addi_w, inst_andi, inst_ori, inst_slli_w, inst_srli_w, inst_srai_w, inst_sltui, inst_lu12i_w};
  assign U_ID.sel_alu_in2[`V_IS_FORE] = |{inst_bl, inst_jirl};
  /* ram */
  assign U_ID.store[`V_ST_B] = inst_st_b;
  assign U_ID.store[`V_ST_W] = inst_st_w;
  assign U_ID.store[`V_LD_B] = inst_ld_b;
  assign U_ID.store[`V_LD_W] = inst_ld_w;
  /* sel write back data */
  assign sel_wb_data = |{inst_ld_b, inst_ld_w};
  /* unsigned */
  assign uflag = inst_sltui;

endmodule

module decoder_4_16 (
	input  logic [ 3:0] in,
	output logic [15:0] out
	);

	genvar i;
	generate for(i = 0 ; i < 16; i = i + 1) begin : gen_for_dec_4_16
		assign out[i] = (in == i);
	end endgenerate

endmodule

module decoder_5_32 (
	input  logic [ 4:0] in,
	output logic [31:0] out
	);

	genvar i;
	generate for(i = 0 ; i < 32; i = i + 1) begin : gen_for_dec_5_32
		assign out[i] = (in == i);
	end endgenerate

endmodule

module decoder_6_64 (
	input  logic [ 5:0] in,
	output logic [63:0] out
	);

	genvar i;
	generate for(i = 0 ; i < 64; i = i + 1) begin : gen_for_dec_6_64
		assign out[i] = (in == i);
	end endgenerate

endmodule
