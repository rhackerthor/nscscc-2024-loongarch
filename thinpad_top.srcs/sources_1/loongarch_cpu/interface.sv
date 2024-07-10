`include "define.sv"
interface Ram (
  input  logic [`W_DATA  ] inst_ram_rdata,
  output logic [`W_DATA  ] inst_ram_addr,
  output logic             inst_ram_ce,
  /* data ram */
  input  logic [`W_DATA  ] data_ram_rdata,
  output logic [`W_DATA  ] data_ram_wdata,
  output logic [`W_DATA  ] data_ram_addr,
  output logic [`W_RAM_BE] data_ram_be,
  output logic             data_ram_ce,
  output logic             data_ram_oe,
  output logic             data_ram_we
);

endinterface

interface PipeLineData (
  input  logic clk,
  input  logic rst
);
  /* pipeline ctrl */
  logic valid;
  logic valid_in;
  logic allowin;
  logic ready_go;
  logic br_cancle;
  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  /* immediate */
  logic [`W_DATA] imm;
  /* reg file */
  logic [`W_DATA   ] rf_wdata;
  logic [`W_DATA   ] rf_rdata1;
  logic [`W_DATA   ] rf_rdata2;
  logic [`W_DATA   ] pre_rf_rdata1;
  logic [`W_DATA   ] pre_rf_rdata2;
  logic [`W_RF_ADDR] rf_waddr;
  logic [`W_RF_ADDR] rf_raddr1;
  logic [`W_RF_ADDR] rf_raddr2;
  logic              rf_we;
  logic              rf_oe1;
  logic              rf_oe2;
  /* branch */
  logic [`W_SEL_NEXT_PC] sel_next_pc;
  logic [`W_DATA] b_bl_pc; // B,BL无条件跳转pc
  logic [`W_DATA] jump_pc; // JIRL无条件跳转pc
  logic [`W_DATA] comp_pc; // 有条件跳转pc
  /* exe */
  logic [`W_ALU_OP] alu_op;
  logic sel_alu_in1;
  logic [`W_SEL_ALU_IN2] sel_alu_in2;
  logic [`W_DATA] alu_result;
  /* mem */
  logic [`W_DATA  ] ram_data;
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_be;
  logic             ram_oe;
  logic             ram_we;
  /* d_inst */
  logic [`W_STORE] store;
  logic [`W_LOAD ] load;
  logic branch;
  /* unsigned */
  logic uflag;

endinterface