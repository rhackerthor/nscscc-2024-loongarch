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

endinterface