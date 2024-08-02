`include "define.sv"
module MEM (
  EXEInterface U_EXE,
  MEMInterface U_MEM,
  RamInterface U_RAM
);

  /* pipeline ctrl */
  always @(posedge U_MEM.clk) begin
    if (U_MEM.rst) begin
      U_MEM.valid <= `V_FALSE;
    end
    else if (U_MEM.allowin) begin
      U_MEM.valid <= U_MEM.validin;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_MEM.clk) begin
    if (U_MEM.rst) begin
      U_MEM.pc         <= `V_ZERO;
      U_MEM.inst       <= `V_ZERO;
      U_MEM.rf_waddr   <= `V_ZERO;
      U_MEM.rf_we      <= `V_ZERO;
      U_MEM.alu_result <= `V_ZERO;
      U_MEM.ram_wdata  <= `V_ZERO;
      U_MEM.ram_addr   <= `V_ZERO;
      U_MEM.ram_mask   <= `V_ZERO;
      U_MEM.load_flag  <= `V_ZERO;
      U_MEM.store_flag <= `V_ZERO;
      U_MEM.cnt        <= `V_ZERO;
    end
    else if (U_MEM.validin && U_MEM.allowin) begin
      U_MEM.pc         <= U_EXE.pc;
      U_MEM.inst       <= U_EXE.inst;
      U_MEM.rf_waddr   <= U_EXE.rf_waddr;
      U_MEM.rf_we      <= U_EXE.rf_we;
      U_MEM.alu_result <= U_EXE.alu_result;
      U_MEM.ram_wdata  <= U_EXE.ram_wdata;
      U_MEM.ram_addr   <= U_EXE.ram_addr;
      U_MEM.ram_mask   <= U_EXE.ram_mask;
      U_MEM.load_flag  <= U_EXE.load_flag;
      U_MEM.store_flag <= U_EXE.store_flag;
      U_MEM.cnt        <= 1;
    end
    else begin
      U_MEM.cnt <= {U_MEM.cnt[10:0], U_MEM.cnt[11]};
    end
  end

  assign U_RAM.data_ram_wdata = U_MEM.ram_wdata;
  assign U_RAM.data_ram_addr  = U_MEM.ram_addr;
  assign U_RAM.data_ram_be    = |{U_MEM.load_flag} ? `V_ONE : U_MEM.ram_mask;
  assign U_RAM.data_ram_ce    = |{U_MEM.load_flag, U_MEM.store_flag} && U_MEM.ram_valid;
  assign U_RAM.data_ram_oe    = |{U_MEM.load_flag} && U_MEM.ram_valid;
  assign U_RAM.data_ram_we    = |{U_MEM.store_flag} && U_MEM.ram_valid;

  assign U_RAM.is_base_ram   = (`V_BASE_RAM_BEGIN <= U_MEM.ram_addr) && (U_MEM.ram_addr <= `V_BASE_RAM_END);
  assign U_RAM.is_ext_ram    = (`V_EXT_RAM_BEGIN <= U_MEM.ram_addr) && (U_MEM.ram_addr <= `V_EXT_RAM_END);
  assign U_RAM.is_uart_stat  = U_MEM.ram_addr == `V_UART_STAT;
  assign U_RAM.is_uart_data  = U_MEM.ram_addr == `V_UART_DATA;
  assign U_RAM.is_uart       = U_RAM.is_uart_data || U_RAM.is_uart_stat;
  assign U_RAM.inst_ram_busy = U_RAM.is_base_ram && U_RAM.data_ram_ce;

  assign U_MEM.ram_valid = (U_RAM.is_uart_stat || U_RAM.is_uart_data) ? U_MEM.cnt[0] : |U_MEM.cnt[3:0];
  
endmodule