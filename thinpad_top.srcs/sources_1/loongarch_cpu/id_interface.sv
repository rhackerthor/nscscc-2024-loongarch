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

  /* pipeline ctrl */
  always_ff @(posedge clk) begin
    if (rst == `V_TRUE) begin
      valid <= `V_FALSE;
    end
    else if (branch_cancle == `V_TRUE) begin
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
    input  branch_cancle,
    output valid,
    output pc,
    output inst,
    output imm,
    input  rf_rdata1,
    input  rf_rdata2,
    output rf_raddr1,
    output rf_raddr2,
    output rf_waddr,
    output rf_oe1,
    output rf_oe2,
    output rf_we,
    output sel_next_pc,
    output b_bl_pc,
    output jump_pc,
    output comp_pc,
    output alu_op,
    output sel_alu_in1,
    output sel_alu_in2,
    output load_flag,
    output store_flag,
    output branch_flag,
    output unsigned_flag
  );

  modport slave (
    output valid_in,
    output allowin,
    output ready_go,
    output branch_cancle,
    input  valid,
    input  pc,
    input  inst,
    input  imm,
    output rf_rdata1,
    output rf_rdata2,
    input  rf_raddr1,
    input  rf_raddr2,
    input  rf_waddr,
    input  rf_oe1,
    input  rf_oe2,
    input  rf_we,
    input  sel_next_pc,
    input  b_bl_pc,
    input  jump_pc,
    input  comp_pc,
    input  alu_op,
    input  sel_alu_in1,
    input  sel_alu_in2,
    input  load_flag,
    input  store_flag,
    input  branch_flag,
    input  unsigned_flag
  );
    
endinterface