`include "define.sv"
interface IFInterface (
  input logic clk,
  input logic rst
);

  /* pipeline ctrl signal */
  logic valid;
  logic valid_in;
  logic allowin;
  logic ready_go;
  logic [7:0] cnt;
  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  logic [`W_DATA] next_pc;
  logic           branch_flag;

  modport master (
    input  clk,
    input  rst,
    input  valid_in,
    input  allowin,
    input  ready_go,
    output cnt,
    output valid,
    output pc,
    output inst,
    output next_pc,
    output branch_flag
  );

  modport slave (
    output valid_in,
    output allowin,
    output ready_go,
    input  cnt,
    input  valid,
    input  pc,
    input  inst,
    input  next_pc,
    input  branch_flag
  );

endinterface