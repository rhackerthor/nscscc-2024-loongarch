`include "define.sv"
module RamUartCtrl (
  input  logic               clk,
  input  logic               rst,
  /* cpu -> base_sram */
  output logic [`W_DATA    ] cpu_base_rdata_o,
  input  logic [`W_DATA    ] cpu_base_addr_i,
  input  logic               cpu_base_ce_i,
  /* cpu -> ext_sram */
  output logic [`W_DATA    ] cpu_ext_rdata_o,
  input  logic [`W_DATA    ] cpu_ext_wdata_i,
  input  logic [`W_DATA    ] cpu_ext_addr_i,
  input  logic [`W_RAM_BE  ] cpu_ext_be_i,
  input  logic               cpu_ext_ce_i,
  input  logic               cpu_ext_oe_i,
  input  logic               cpu_ext_we_i,
  /* base_sram */
  inout  wire  [`W_DATA    ] base_ram_data_io,
  output logic [`W_RAM_ADDR] base_ram_addr_o,
  output logic [`W_RAM_BE  ] base_ram_be_n_o,
  output logic               base_ram_ce_n_o,
  output logic               base_ram_oe_n_o,
  output logic               base_ram_we_n_o,
  /* ext_sram */
  inout  wire  [`W_DATA    ] ext_ram_data_io,
  output logic [`W_RAM_ADDR] ext_ram_addr_o,
  output logic [`W_RAM_BE  ] ext_ram_be_n_o,
  output logic               ext_ram_ce_n_o,
  output logic               ext_ram_oe_n_o,
  output logic               ext_ram_we_n_o,
  /* 直连串口信号 */
  input  logic               rxd_i,
  output logic               txd_o,
  /* valid: IF流水级输入允许信号 */
  output logic               to_if_valid_o
);

  /* base 转接线 */
  logic [`W_DATA    ] base_ram_rdata_r;
  logic [`W_DATA    ] base_ram_wdata_r;
  logic [`W_RAM_ADDR] base_ram_addr_r;
  logic [`W_RAM_BE  ] base_ram_be_n_r;
  logic               base_ram_ce_n_r;
  logic               base_ram_oe_n_r;
  logic               base_ram_we_n_r;

  /* ext 转接线 */
  logic [`W_DATA    ] ext_ram_rdata_r;
  logic [`W_DATA    ] ext_ram_wdata_r;
  logic [`W_RAM_ADDR] ext_ram_addr_r;
  logic [`W_RAM_BE  ] ext_ram_be_n_r;
  logic               ext_ram_ce_n_r;
  logic               ext_ram_oe_n_r;
  logic               ext_ram_we_n_r;

  /* uart ctrl */
  logic [`W_DATA] uart_rdata;
  assign is_uart = `V_FALSE;

  /* 判断数据访存范围 */
  logic is_base_ram, is_ext_ram;
  logic is_uart_stat, is_uart_data, is_uart;
  assign is_base_ram = (`V_BASE_RAM_BEGIN <= cpu_ext_addr_i) && (cpu_ext_addr_i <= `V_BASE_RAM_END);
  assign is_ext_ram = (`V_EXT_RAM_BEGIN <= cpu_ext_addr_i) && (cpu_ext_addr_i <= `V_EXT_RAM_END);
  assign is_uart_stat = cpu_ext_addr_i == `V_UART_STAT;
  assign is_uart_data = cpu_ext_addr_i == `V_UART_DATA;

  /* base ram */
  assign base_ram_data_io = ~base_ram_we_n_o ? base_ram_wdata_r : 32'bzzzz_zzzz;
  assign base_ram_addr_o  = base_ram_addr_r;
  assign base_ram_be_n_o  = base_ram_be_n_r;
  assign base_ram_ce_n_o  = base_ram_ce_n_r;
  assign base_ram_oe_n_o  = base_ram_oe_n_r;
  assign base_ram_we_n_o  = base_ram_we_n_r;
  always @(*) begin
    /* 复位值 */
    if (rst == `V_TRUE) begin
      base_ram_rdata_r <= `V_ZERO;
      base_ram_wdata_r <= `V_ZERO;
      base_ram_addr_r  <= `V_ZERO;
      base_ram_be_n_r  <= `V_ONE;
      base_ram_ce_n_r  <= `V_ONE;
      base_ram_oe_n_r  <= `V_ONE;
      base_ram_we_n_r  <= `V_ONE;
      to_if_valid_o    <= `V_ZERO;
    end
    /* 访存阶段访问base ram */
    else if (is_base_ram == `V_TRUE) begin
      base_ram_rdata_r <= ~base_ram_oe_n_r ? base_ram_data_io : 32'b0;
      base_ram_wdata_r <= cpu_ext_wdata_i;
      base_ram_addr_r  <= cpu_ext_addr_i[21:2];
      base_ram_be_n_r  <= ~cpu_ext_be_i;
      base_ram_ce_n_r  <= ~cpu_ext_ce_i;
      base_ram_oe_n_r  <= ~cpu_ext_oe_i;
      base_ram_we_n_r  <= ~cpu_ext_we_i;
      to_if_valid_o    <= `V_ZERO;
    end
    else begin
      base_ram_rdata_r <= ~base_ram_oe_n_r ? base_ram_data_io : 32'b0;
      base_ram_wdata_r <= `V_ZERO;
      base_ram_addr_r  <= cpu_base_addr_i[21:2];
      base_ram_be_n_r  <= `V_ZERO;
      base_ram_ce_n_r  <= `V_ZERO;
      base_ram_oe_n_r  <= `V_ZERO;
      base_ram_we_n_r  <= `V_ONE;
      to_if_valid_o    <= `V_ONE;
    end
  end

  /* ext ram */
  assign ext_ram_data_io = ~ext_ram_we_n_o ? ext_ram_wdata_r : 32'bzzzz_zzzz;
  assign ext_ram_addr_o  = ext_ram_addr_r;
  assign ext_ram_be_n_o  = ext_ram_be_n_r;
  assign ext_ram_ce_n_o  = ext_ram_ce_n_r;
  assign ext_ram_oe_n_o  = ext_ram_oe_n_r;
  assign ext_ram_we_n_o  = ext_ram_we_n_r;
  always @(*) begin
    /* 复位值 */
    if (rst == `V_TRUE) begin
      ext_ram_rdata_r <= `V_ZERO;
      ext_ram_wdata_r <= `V_ZERO;
      ext_ram_addr_r  <= `V_ZERO;
      ext_ram_be_n_r  <= `V_ONE;
      ext_ram_ce_n_r  <= `V_ONE;
      ext_ram_oe_n_r  <= `V_ONE;
      ext_ram_we_n_r  <= `V_ONE;
    end
    /* 访存阶段访问ext ram */
    else if (is_ext_ram == `V_TRUE) begin
      ext_ram_rdata_r <= ~ext_ram_oe_n_r ? ext_ram_data_io : 32'b0;
      ext_ram_wdata_r <= cpu_ext_wdata_i;
      ext_ram_addr_r  <= cpu_ext_addr_i[21:2];
      ext_ram_be_n_r  <= ~cpu_ext_be_i;
      ext_ram_ce_n_r  <= ~cpu_ext_ce_i;
      ext_ram_oe_n_r  <= ~cpu_ext_oe_i;
      ext_ram_we_n_r  <= ~cpu_ext_we_i;
    end
    else begin
      ext_ram_rdata_r <= `V_ZERO;
      ext_ram_wdata_r <= `V_ZERO;
      ext_ram_addr_r  <= `V_ZERO;
      ext_ram_be_n_r  <= `V_ONE;
      ext_ram_ce_n_r  <= `V_ONE;
      ext_ram_oe_n_r  <= `V_ONE;
      ext_ram_we_n_r  <= `V_ONE;
    end
  end

  /* 读内存 */
  assign cpu_base_rdata_o = base_ram_rdata_r;
  assign cpu_ext_rdata_o = is_uart     ? uart_rdata :
                           is_base_ram ? base_ram_rdata_r :
                                         ext_ram_rdata_r;

  /* uart */

endmodule