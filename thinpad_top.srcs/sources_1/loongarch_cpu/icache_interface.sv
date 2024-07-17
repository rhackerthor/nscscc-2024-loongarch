`include "define.sv"
interface IcacheInterface (
  input logic clk,
  input logic rst
);

  logic [`W_DATA] pc    [`W_ICACHE];
  logic [`W_DATA] data  [`W_ICACHE];
  logic [`W_ICACHE] cnt;

  logic [`W_DATA] rdata;
  logic [`W_DATA] addr;
  logic [`W_DATA] ce;

  logic cache_valid;

endinterface