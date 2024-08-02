interface ICInterface (
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
  /* icache */
  logic [`W_DATA] tag [`W_ICACHE];
  logic [`W_DATA] data [`W_ICACHE];
  logic we;
  logic miss;

endinterface