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
  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  /* immediate */
  logic [`W_DATA  ] imm;
  /* reg file */
  logic [`W_DATA   ] rf_wdata;
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
  logic [`W_DATA] b_bl_pc; // B,BL无条件跳转pc
  logic [`W_DATA] jirl_pc; // JIRL无条件跳转pc
  logic [`W_DATA] comp_pc; // 有条件跳转pc
  /* exe */
  logic [`W_ALU_OP] alu_op;
  logic sel_alu_in2;
  logic [`W_SEL_ALU_IN2] sel_alu_in2;
  /* mem */
  logic [`W_DATA  ] ram_data;
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_be;
  logic             ram_oe;
  logic             ram_we;
  logic [`W_ST] store;
  logic [`W_LD] load;
  /* wb */
  logic sel_wb_data;
  /* unsigned */
  logic uflag;

  modport IF (
    input  clk,
    input  rst,
    /* data */
    output pc,
    output inst
  );

  modport ID (
    input  clk,
    input  rst,
    /* data */
    input  pc,
    input  inst,
    output d_inst,
    output imm,
    input  rf_rdata1,
    input  rf_rdata2,
    output rf_waddr,
    output rf_raddr1,
    output rf_raddr2,
    output rf_we,
    output rf_oe1,
    output rf_oe2,
    output sel_next_pc,
    output b_bl_pc,
    output jump_pc,
    output branch_pc,
    output alu_op,
    output sel_alu_in1,
    output sel_alu_in2,
    output store,
    output load,
    output sel_wb_data,
    output uflag
  );

  modport EXE (
    input  clk,
    input  rst,
    /* data */
    input  pc,
    input  inst,
    input  imm,
    input  rf_rdata1,
    input  rf_rdata2,
    input  rf_waddr,
    input  rf_we,
    input  alu_op,
    input  sel_alu_in1,
    input  sel_alu_in2,
    input  sel_wb_data,
    input  uflag,
    output alu_result
    output ram_addr,
    output ram_be,
    output ram_oe,
    output ram_we
  );

  modport MEM (
    input  clk,
    input  rst,
    /* data */
    input  pc,
    input  inst,
    input  imm,
    input  rf_rdata1,
    input  rf_rdata2,
    input  rf_waddr,
    input  rf_we,
    input  alu_result,
    input  sel_wb_data,
    output ram_data,
    input  ram_addr,
    input  ram_be,
    input  ram_oe,
    input  ram_we
  );

  modport WB (
    input  clk,
    input  rst,
    /* data */
    input  pc,
    input  inst,
    output rf_wdata,
    input  rf_waddr,
    input  rf_we,
    input  alu_result,
    input  sel_wb_data,
    input  ram_data,
    input  ram_addr,
    input  ram_be
  );
  
endinterface