`include "define.sv"
interface RamInterface (
  /* inst ram */
  input  logic [`W_DATA  ] inst_ram_rdata,
  output logic [`W_DATA  ] inst_ram_addr,
  output logic             inst_ram_ce,
  /* data ram */
  input  logic [`W_DATA  ] data_ram_rdata,
  output logic [`W_DATA  ] data_ram_wdata,
  output logic [`W_DATA  ] data_ram_addr,
  output logic [`W_RAM_BE] data_ram_be,
  output logic             data_ram_ce,
  output logic             data_ram_oe,
  output logic             data_ram_we,
  /* addr range */
  output logic             is_base_ram,
  output logic             is_ext_ram,
  output logic             is_uart_stat,
  output logic             is_uart_data
);

  logic inst_ram_busy;

endinterface