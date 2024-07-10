module top (
  input  logic clk,
  output logic rst
);

  wire [31:0] cpu_base_rdata;
  wire [31:0] cpu_base_addr;
  wire        cpu_base_ce;

  wire [31:0] cpu_ext_rdata;
  wire [31:0] cpu_ext_wdata;
  wire [31:0] cpu_ext_addr;
  wire [ 3:0] cpu_ext_be;
  wire        cpu_ext_ce;
  wire        cpu_ext_oe;
  wire        cpu_ext_we;
  wire        to_if_valid;

/*   RamUartCtrl RamUartCtrl0 (
    .clk              (clk           ),
    .rst              (reset_of_clk  ),
    .cpu_base_rdata_o (cpu_base_rdata),
    .cpu_base_addr_i  (cpu_base_addr ),
    .cpu_base_ce_i    (cpu_base_ce   ),
    .cpu_ext_rdata_o  (cpu_ext_rdata ),
    .cpu_ext_wdata_i  (cpu_ext_wdata ),
    .cpu_ext_addr_i   (cpu_ext_addr  ),
    .cpu_ext_be_i     (cpu_ext_be    ),
    .cpu_ext_ce_i     (cpu_ext_ce    ),
    .cpu_ext_oe_i     (cpu_ext_oe    ),
    .cpu_ext_we_i     (cpu_ext_we    ),
    .to_if_valid_o    (to_if_valid   )
  ); */

  LoongCpu LoongCpu (
    .clk              (clk           ),
    .rst              (rst           ),
    .inst_ram_rdata_i (cpu_base_rdata),
    .inst_ram_addr_o  (cpu_base_addr ),
    .inst_ram_ce_o    (cpu_base_ce   ),
    .data_ram_rdata_i (cpu_ext_rdata ),
    .data_ram_wdata_o (cpu_ext_wdata ),
    .data_ram_addr_o  (cpu_ext_addr  ),
    .data_ram_be_o    (cpu_ext_be    ),
    .data_ram_ce_o    (cpu_ext_ce    ),
    .data_ram_oe_o    (cpu_ext_oe    ),
    .data_ram_we_o    (cpu_ext_we    ),
    .to_if_valid_i    (to_if_valid   )
  );

endmodule