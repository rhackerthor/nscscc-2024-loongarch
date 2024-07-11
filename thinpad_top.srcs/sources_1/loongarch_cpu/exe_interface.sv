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
  logic [`W_ALU_OP     ] alu_op;
  logic                  sel_alu_in1;
  logic [`W_SEL_ALU_IN2] sel_alu_in2;
  logic [`W_DATA       ] alu_result;
  /* mem */
  logic [`W_DATA  ] ram_data;
  logic [`W_DATA  ] ram_addr;
  logic [`W_RAM_BE] ram_mask;
  /* flag */
  logic [`W_STORE] store_flag;
  logic [`W_LOAD ] load_flag;
  logic            branch_flag;
  logic            unsigned_flag;

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
    output valid,
    output pc,
    output inst,
    output imm,
    output rf_rdata1,
    output rf_rdata2,
    output rf_wdata,
    output rf_waddr,
    output rf_we,
    output alu_op,
    output sel_alu_in1,
    output sel_alu_in2,
    output alu_result,
    output ram_data,
    output ram_addr,
    output ram_mask,
    output load_flag,
    output store_flag,
    output branch_flag,
    output unsigned_flag
  );

  modport slave (
    output valid_in,
    output allowin,
    output ready_go,
    input  valid,
    input  pc,
    input  inst,
    input  imm,
    input  rf_rdata1,
    input  rf_rdata2,
    input  rf_wdata,
    input  rf_waddr,
    input  rf_we,
    input  alu_op,
    input  sel_alu_in1,
    input  sel_alu_in2,
    input  alu_result,
    input  ram_data,
    input  ram_addr,
    input  ram_mask,
    input  load_flag,
    input  store_flag,
    input  branch_flag,
    input  unsigned_flag
  );
    
endinterface