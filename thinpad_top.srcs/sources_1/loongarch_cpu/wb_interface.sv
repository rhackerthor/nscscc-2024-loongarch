`include "define.sv"
interface WBInterface (
  input logic clk,
  input logic rst
);

  /* pipeline ctrl */
  logic valid;
  logic valid_in;
  logic allowin;
  logic ready_go;

  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  /* reg file */
  logic [`W_DATA   ] rf_wdata;
  logic [`W_RF_ADDR] rf_waddr;
  logic              rf_we;
  /* alu */
  logic [`W_DATA] alu_result;
  /* mem */
  logic [`W_DATA  ] ram_data;
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_mask;
  /* flag */
  logic [`W_LOAD ] load_flag;
    
endinterface