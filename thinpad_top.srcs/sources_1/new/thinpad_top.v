`default_nettype none

module thinpad_top(
    input wire clk_50M,              //50MHz 时钟输入
    input wire clk_11M0592,          //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,            //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,            //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,     //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,        //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,          //16位LED，输出时1点亮
    output wire[7:0]  dpy0,          //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,          //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,   //ExtRAM数据
    output wire[19:0] ext_ram_addr,  //ExtRAM地址
    output wire[3:0] ext_ram_be_n,   //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,        //ExtRAM片选，低有效
    output wire ext_ram_oe_n,        //ExtRAM读使能，低有效
    output wire ext_ram_we_n,        //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,     //红色像素，3位
    output wire[2:0] video_green,   //绿色像素，3位
    output wire[1:0] video_blue,    //蓝色像素，2位
    output wire video_hsync,        //行同步（水平同步）信号
    output wire video_vsync,        //场同步（垂直同步）信号
    output wire video_clk,          //像素时钟输出
    output wire video_de            //行数据有效信号，用于区分消隐区
);

  /* 控制时钟信号 */
  wire locked, clk_10M, clk_20M, clk_60M, clk_95M;
  pll_example clock_gen 
   (
    // Clock in ports
    .clk_in1(clk_50M),  // 外部时钟输入
    // Clock out ports
    .clk_out1(clk_60M), // 时钟输出1，频率在IP配置界面中设置
    .clk_out2(clk_95M), // 时钟输出2，频率在IP配置界面中设置
    // Status and control signals
    .reset(reset_btn),  // PLL复位输入
    .locked(locked)     // PLL锁定指示输出，"1"表示时钟稳定，
                        // 后级电路复位信号应当由它生成（见下）
   );

  // 选择要使用的时钟
  wire clk;
  reg reset_of_clk;
  // 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
  assign clk = clk_95M;
  always@(posedge clk or negedge locked) begin
      if(~locked) reset_of_clk <= 1'b1;
      else        reset_of_clk <= 1'b0;
  end

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
  wire        iftech_stop;

  wire is_base_ram;
  wire is_ext_ram;
  wire is_uart_stat;
  wire is_uart_data;

  wire        debug_wb_valid;
  wire        debug_wb_rf_we;
  wire [31:0] debug_wb_pc;
  wire [ 4:0] debug_wb_rf_waddr;
  wire [31:0] debug_wb_rf_wdata;

  RamUartCtrl RamUartCtrl0 (
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
    .base_ram_data_io (base_ram_data ),
    .base_ram_addr_o  (base_ram_addr ),
    .base_ram_be_n_o  (base_ram_be_n ),
    .base_ram_ce_n_o  (base_ram_ce_n ),
    .base_ram_oe_n_o  (base_ram_oe_n ),
    .base_ram_we_n_o  (base_ram_we_n ),
    .ext_ram_data_io  (ext_ram_data  ),
    .ext_ram_addr_o   (ext_ram_addr  ),
    .ext_ram_be_n_o   (ext_ram_be_n  ),
    .ext_ram_ce_n_o   (ext_ram_ce_n  ),
    .ext_ram_oe_n_o   (ext_ram_oe_n  ),
    .ext_ram_we_n_o   (ext_ram_we_n  ),
    .rxd_i            (rxd           ),
    .txd_o            (txd           ),
    .is_base_ram_i    (is_base_ram   ),
    .is_ext_ram_i     (is_ext_ram    ),
    .is_uart_stat_i   (is_uart_stat  ),
    .is_uart_data_i   (is_uart_data  )

  );

  LoongCpu LoongCpu0 (
    .clk                 (clk              ),
    .rst                 (reset_of_clk     ),
    .inst_ram_rdata_i    (cpu_base_rdata   ),
    .inst_ram_addr_o     (cpu_base_addr    ),
    .inst_ram_ce_o       (cpu_base_ce      ),
    .data_ram_rdata_i    (cpu_ext_rdata    ),
    .data_ram_wdata_o    (cpu_ext_wdata    ),
    .data_ram_addr_o     (cpu_ext_addr     ),
    .data_ram_be_o       (cpu_ext_be       ),
    .data_ram_ce_o       (cpu_ext_ce       ),
    .data_ram_oe_o       (cpu_ext_oe       ),
    .data_ram_we_o       (cpu_ext_we       ),
    .is_base_ram_o       (is_base_ram      ),
    .is_ext_ram_o        (is_ext_ram       ),
    .is_uart_stat_o      (is_uart_stat     ),
    .is_uart_data_o      (is_uart_data     ),
    .debug_wb_valid_o    (debug_wb_valid   ),
    .debug_wb_rf_we_o    (debug_wb_rf_we   ),
    .debug_wb_pc_o       (debug_wb_pc      ),
    .debug_wb_rf_waddr_o (debug_wb_rf_waddr),
    .debug_wb_rf_wdata_o (debug_wb_rf_wdata)
  );

endmodule
