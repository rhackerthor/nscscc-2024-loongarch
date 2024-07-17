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
  logic           branch_flag;
  logic [`W_DATA] branch_pc;
  logic           jirl_flag;
  logic           comp_flag;
  /* alu */
  logic [`W_ALU_OP] alu_op;
  logic [`W_DATA] alu_in1;
  logic [`W_DATA] alu_in2;
  /* flag */
  logic [`W_STORE] store_flag;
  logic [`W_LOAD ] load_flag;
  logic            unsigned_flag;

endinterface