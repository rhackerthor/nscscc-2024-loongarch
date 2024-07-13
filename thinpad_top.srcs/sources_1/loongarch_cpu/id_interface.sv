`include "define.sv"
interface IDInterface (
  input logic clk,
  input logic rst
);

  /* pipeline ctrl signal */
  logic valid;
  logic valid_in;
  logic allowin;
  logic ready_go;
  logic branch_cancle;

  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  /* immediate */
  logic [`W_DATA] imm;
  /* reg file */
  logic [`W_DATA   ] rf_rdata1;
  logic [`W_DATA   ] rf_rdata2;
  logic [`W_RF_ADDR] rf_waddr;
  logic [`W_RF_ADDR] rf_raddr1;
  logic [`W_RF_ADDR] rf_raddr2;
  logic              rf_we;
  logic              rf_oe1;
  logic              rf_oe2;
  /* branch */
  logic [`W_SEL_NEXT_PC] sel_next_pc;
  logic [`W_DATA       ] b_bl_pc; // B,BL无条件跳转pc
  logic [`W_DATA       ] jump_pc; // JIRL无条件跳转pc
  logic [`W_DATA       ] comp_pc; // 有条件跳转pc
  /* alu */
  logic [`W_ALU_OP     ] alu_op;
  logic                  sel_alu_in1;
  logic [`W_SEL_ALU_IN2] sel_alu_in2;
  /* flag */
  logic [`W_STORE] store_flag;
  logic [`W_LOAD ] load_flag;
  logic            branch_flag;
  logic            unsigned_flag;

endinterface