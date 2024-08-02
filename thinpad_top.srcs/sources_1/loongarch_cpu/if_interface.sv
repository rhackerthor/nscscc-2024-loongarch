`include "define.sv"
interface IFInterface (
  input logic clk,
  input logic rst
);

  /* pipeline ctrl signal */
  logic valid;
  logic validin;
  logic allowin;
  logic ready_go;
  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;
  logic [`W_DATA] next_pc;
  logic           branch_flag;

endinterface