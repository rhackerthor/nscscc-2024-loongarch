interface ICInterface (
  input logic clk,
  input logic rst
);

  logic [`W_DATA] pc [`W_ICACHE];
  logic [`W_DATA] inst [`W_ICACHE];
  logic we;
  logic miss;

endinterface