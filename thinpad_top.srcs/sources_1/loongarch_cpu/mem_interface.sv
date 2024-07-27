`include "define.sv"
interface MEMInterface (
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
  /* reg file */
  logic [`W_RF_ADDR] rf_waddr;
  logic              rf_we;
  /* alu */
  logic [`W_DATA] alu_result;
  /* mem */
  logic             ram_valid;
  logic [`W_DATA  ] ram_wdata;
  logic [`W_DATA  ] ram_rdata;
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_mask;
  /* flag */
  logic [`W_LOAD ] load_flag;
  logic [`W_STORE] store_flag;


endinterface