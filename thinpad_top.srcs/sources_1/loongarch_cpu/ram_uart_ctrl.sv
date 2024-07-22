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
  /* uart */
  input  logic               rxd_i,
  output logic               txd_o,
  /* addr range */
  input  logic               is_base_ram_i,
  input  logic               is_ext_ram_i,
  input  logic               is_uart_stat_i,
  input  logic               is_uart_data_i
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
  logic [`W_UART_DATA] rxd_data;
  logic [`W_UART_DATA] txd_data;
  logic                txd_busy;
  logic                txd_start;
  logic                rxd_ready;
  logic                rxd_clear;
  logic [`W_DATA     ] uart_rdata;
  /* fifo rxd */
  logic                rxd_fifo_we;
  logic                rxd_fifo_full;
  logic [`W_UART_DATA] rxd_fifo_din;
  logic                rxd_fifo_oe;
  logic                rxd_fifo_empty;
  logic [`W_UART_DATA] rxd_fifo_dout;
  /* fifo txd */
  logic                txd_fifo_we;
  logic                txd_fifo_full;
  logic [`W_UART_DATA] txd_fifo_din;
  logic                txd_fifo_oe;
  logic                txd_fifo_empty;
  logic [`W_UART_DATA] txd_fifo_dout;

  logic uart_flag, base_flag, ext_flag;

  /* uart */
  assign txd_fifo_oe  = txd_start;
  assign txd_start    = (~txd_busy) && (~txd_fifo_empty);
  assign txd_data     = txd_fifo_dout;
  assign rxd_fifo_we  = rxd_clear;
  assign rxd_fifo_din = rxd_data;
  assign rxd_clear    = rst || (rxd_ready && (~rxd_fifo_full));
  async_receiver #(.ClkFrequency(`V_FREQUENCY), .Baud(`V_BITRATE)) //接收模块
    ext_uart_r(
       .clk(clk),                      //外部时钟信号
       .RxD(rxd_i),                    //外部串行信号输入
       .RxD_data_ready(rxd_ready),     //数据接收到标志
       .RxD_clear(rxd_clear),          //清除接收标志
       .RxD_data(rxd_data)             //接收到的一字节数据
    );

  async_transmitter #(.ClkFrequency(`V_FREQUENCY), .Baud(`V_BITRATE)) //发送模块
    ext_uart_t(
      .clk(clk),                        //外部时钟信号
      .TxD(txd_o),                      //串行信号输出
      .TxD_busy(txd_busy),              //发送器忙状态指示
      .TxD_start(txd_start),            //开始发送信号
      .TxD_data(txd_data)               //待发送的数据
    );
  
  fifo_generator_0 RXD_FIFO (
    .rst   (rst           ),
    .clk   (clk           ),
    .wr_en (rxd_fifo_we   ),
    .din   (rxd_fifo_din  ),
    .full  (rxd_fifo_full ),
    .rd_en (rxd_fifo_oe   ),
    .dout  (rxd_fifo_dout ),
    .empty (rxd_fifo_empty)
  );

  fifo_generator_0 TXD_FIFO (
    .rst   (rst           ),
    .clk   (clk           ),
    .wr_en (txd_fifo_we   ),
    .din   (txd_fifo_din  ),
    .full  (txd_fifo_full ),
    .rd_en (txd_fifo_oe   ),
    .dout  (txd_fifo_dout ),
    .empty (txd_fifo_empty)
  );

  always_ff @(*) begin
    if (is_uart_stat_i && cpu_ext_oe_i) begin
      txd_fifo_we  <= `V_FALSE;
      txd_fifo_din <= `V_ZERO;
      rxd_fifo_oe  <= `V_FALSE;
      uart_flag    <= `V_TRUE;
      uart_rdata   <= {30'b0, ~rxd_fifo_empty, ~txd_fifo_full};
    end
    else if (is_uart_data_i && cpu_ext_we_i) begin
      txd_fifo_we  <= `V_TRUE;
      txd_fifo_din <= cpu_ext_wdata_i[7:0];
      rxd_fifo_oe  <= `V_FALSE;
      uart_flag    <= `V_FALSE;
      uart_rdata   <= `V_ZERO;
    end
    else if (is_uart_data_i && cpu_ext_oe_i) begin
      txd_fifo_we  <= `V_FALSE;
      txd_fifo_din <= `V_ZERO;
      rxd_fifo_oe  <= `V_TRUE;
      uart_flag    <= `V_TRUE;
      uart_rdata   <= {24'b0, rxd_fifo_dout};
    end
    else begin
      txd_fifo_we  <= `V_FALSE;
      txd_fifo_din <= `V_ZERO;
      rxd_fifo_oe  <= `V_FALSE;
      uart_flag    <= `V_ZERO;
      uart_rdata   <= `V_ZERO;
    end
  end

  /* base ram */
  assign base_ram_data_io = ~base_ram_we_n_o ? base_ram_wdata_r : 32'bzzzz_zzzz;
  assign base_ram_addr_o  = base_ram_addr_r;
  assign base_ram_be_n_o  = base_ram_be_n_r;
  assign base_ram_ce_n_o  = base_ram_ce_n_r;
  assign base_ram_oe_n_o  = base_ram_oe_n_r;
  assign base_ram_we_n_o  = base_ram_we_n_r;
  always @(*) begin
    /* 复位值 */
    if (rst) begin
      base_ram_wdata_r <= `V_ZERO;
      base_ram_addr_r  <= `V_ZERO;
      base_ram_be_n_r  <= `V_ONE;
      base_ram_ce_n_r  <= `V_ONE;
      base_ram_oe_n_r  <= `V_ONE;
      base_ram_we_n_r  <= `V_ONE;
      base_flag        <= `V_ZERO;
    end
    /* 访存阶段访问base ram */
    else if (is_base_ram_i && cpu_ext_ce_i) begin
      base_ram_wdata_r <= cpu_ext_wdata_i;
      base_ram_addr_r  <= cpu_ext_addr_i[21:2];
      base_ram_be_n_r  <= ~cpu_ext_be_i;
      base_ram_ce_n_r  <= ~cpu_ext_ce_i;
      base_ram_oe_n_r  <= ~cpu_ext_oe_i;
      base_ram_we_n_r  <= ~cpu_ext_we_i;
      base_flag        <= `V_TRUE;
    end
    else begin
      base_ram_wdata_r <= `V_ZERO;
      base_ram_addr_r  <= cpu_base_addr_i[21:2];
      base_ram_be_n_r  <= `V_ZERO;
      base_ram_ce_n_r  <= ~cpu_base_ce_i;
      base_ram_oe_n_r  <= ~cpu_base_ce_i;
      base_ram_we_n_r  <= `V_ONE;
      base_flag        <= `V_FALSE;
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
    if (rst) begin
      ext_ram_wdata_r = `V_ZERO;
      ext_ram_addr_r  = `V_ZERO;
      ext_ram_be_n_r  = `V_ONE;
      ext_ram_ce_n_r  = `V_ONE;
      ext_ram_oe_n_r  = `V_ONE;
      ext_ram_we_n_r  = `V_ONE;
      ext_flag        = `V_FALSE;
    end
    /* 访存阶段访问ext ram */
    else if (is_ext_ram_i && cpu_ext_ce_i) begin
      ext_ram_wdata_r = cpu_ext_wdata_i;
      ext_ram_addr_r  = cpu_ext_addr_i[21:2];
      ext_ram_be_n_r  = ~cpu_ext_be_i;
      ext_ram_ce_n_r  = ~cpu_ext_ce_i;
      ext_ram_oe_n_r  = ~cpu_ext_oe_i;
      ext_ram_we_n_r  = ~cpu_ext_we_i;
      ext_flag        = `V_TRUE;
    end
    else begin
      ext_ram_wdata_r = `V_ZERO;
      ext_ram_addr_r  = `V_ZERO;
      ext_ram_be_n_r  = `V_ONE;
      ext_ram_ce_n_r  = `V_ONE;
      ext_ram_oe_n_r  = `V_ONE;
      ext_ram_we_n_r  = `V_ONE;
      ext_flag        = `V_FALSE;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      base_ram_rdata_r = `V_ZERO;
      ext_ram_rdata_r  <= `V_ZERO;
    end
    else begin
      if (cpu_base_ce_i) begin
        base_ram_rdata_r <= base_ram_data_io;
      end
      else begin
        base_ram_rdata_r <= base_ram_rdata_r;
      end

      if (cpu_ext_oe_i) begin
        if      (uart_flag) begin ext_ram_rdata_r <= uart_rdata;       end
        else if (base_flag) begin ext_ram_rdata_r <= base_ram_data_io; end
        else if (ext_flag ) begin ext_ram_rdata_r <= ext_ram_data_io;  end
        else                begin ext_ram_rdata_r <= ext_ram_rdata_r;  end
      end
      else begin ext_ram_rdata_r <= ext_ram_rdata_r; end
    end
  end

  /* 读内存 */
  assign cpu_base_rdata_o = base_ram_rdata_r;
  assign cpu_ext_rdata_o  = ext_ram_rdata_r;

endmodule