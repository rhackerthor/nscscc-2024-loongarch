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
  logic [`W_DATA   ] rf_rdata1;
  logic [`W_DATA   ] rf_rdata2;
  logic [`W_DATA   ] rf_wdata;
  logic [`W_RF_ADDR] rf_waddr;
  logic              rf_we;
  /* alu */
  logic [`W_DATA       ] alu_result;
  /* mem */
  logic [`W_DATA  ] ram_data;
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_mask;
  /* flag */
  logic [`W_LOAD ] load_flag;

  /* 流水线寄存器 */
  always_ff @(posedge clk) begin
    if (rst == `V_TRUE) begin
      valid <= `V_FALSE;
    end
    else if (allowin == `V_TRUE) begin
      valid <= valid_in;
    end
  end

  modport master (
    input  clk,
    input  rst,
    input  valid_in,
    input  allowin,
    input  ready_go,
    input  valid,
    output pc,
    output inst,
    output rf_rdata1,
    output rf_rdata2,
    output rf_wdata,
    output rf_waddr,
    output rf_we,
    output alu_result,
    output ram_data,
    output ram_addr,
    output ram_mask,
    output load_flag
  );

  modport slave (
    output valid_in,
    output allowin,
    output ready_go,
    input  valid,
    input  pc,
    input  inst,
    input  rf_rdata1,
    input  rf_rdata2,
    input  rf_wdata,
    input  rf_waddr,
    input  rf_we,
    input  alu_result,
    input  ram_data,
    input  ram_addr,
    input  ram_mask,
    input  load_flag
  );
    
endinterface