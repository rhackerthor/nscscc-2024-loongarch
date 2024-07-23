interface IcacheIterface (
  input logic clk,
  input logic rst
);

  logic [`W_ICACHE] pc;
  logic [`W_ICACHE] inst;
  logic we;
  logic cache_miss;

endinterface