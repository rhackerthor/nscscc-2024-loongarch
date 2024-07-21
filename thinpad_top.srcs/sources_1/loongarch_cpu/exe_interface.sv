`include "define.sv"
interface EXEInterface (
  input logic clk,
  input logic rst
);

  /* pipeline ctrl */
  logic valid;
  logic valid_in;
  logic allowin;
  logic ready_go;
  logic [7:0] cnt;

  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  /* immediate */
  logic [`W_DATA] imm;
  /* reg file */
  logic [`W_DATA   ] rf_rdata1;
  logic [`W_DATA   ] rf_rdata2;
  logic [`W_DATA   ] rf_wdata;
  logic [`W_RF_ADDR] rf_waddr;
  logic              rf_we;
  /* alu */
  logic [`W_ALU_OP] alu_op;
  logic [`W_DATA  ] alu_in1;
  logic [`W_DATA  ] alu_in2;
  logic [`W_DATA  ] alu_result;
  /* mem */
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_mask;
  /* flag */
  logic [`W_STORE] store_flag;
  logic [`W_LOAD ] load_flag;
    
endinterface