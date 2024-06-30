`include "define.sv"
module LoongCpu (
  input  logic clk,
  input  logic rst,
  /* inst ram */
  input  logic [`W_DATA  ] inst_ram_rdata_i,
  output logic [`W_DATA  ] inst_ram_addr_o,
  output logic             inst_ram_ce_o,
  /* data ram */
  input  logic [`W_DATA  ] data_ram_rdata_i,
  output logic [`W_DATA  ] data_ram_wdata_o,
  output logic [`W_DATA  ] data_ram_addr_o,
  output logic [`W_RAM_BE] data_ram_be_o,
  output logic             data_ram_ce_o,
  output logic             data_ram_oe_o,
  output logic             data_ram_we_o,
  /* valid in */
  input  logic to_if_valid_i
);

endmodule