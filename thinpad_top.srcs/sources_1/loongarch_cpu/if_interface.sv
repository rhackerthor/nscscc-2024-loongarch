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
  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;

endinterface