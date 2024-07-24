`include "define.sv"
module EXE (
  IDInterface  U_ID,
  EXEInterface U_EXE,
  RamInterface U_RAM
);

  /* pipeline ctrl */
  always @(posedge U_EXE.clk) begin
    if (U_EXE.rst) begin
      U_EXE.valid <= `V_FALSE;
    end
    else if (U_EXE.allowin) begin
      U_EXE.valid <= U_EXE.valid_in;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_EXE.clk) begin
    if (U_EXE.rst) begin
      U_EXE.pc         <= `V_ZERO;
      U_EXE.inst       <= `V_ZERO;
      U_EXE.imm        <= `V_ZERO;
      U_EXE.rf_rdata1  <= `V_ZERO;
      U_EXE.rf_rdata2  <= `V_ZERO;
      U_EXE.rf_waddr   <= `V_ZERO;
      U_EXE.rf_we      <= `V_ZERO;
      U_EXE.alu_op     <= `V_ZERO;
      U_EXE.alu_in1    <= `V_ZERO;
      U_EXE.alu_in2    <= `V_ZERO;
      U_EXE.load_flag  <= `V_ZERO;
      U_EXE.store_flag <= `V_ZERO;
      U_EXE.cnt        <= `V_ZERO;
    end
    else if (U_EXE.valid_in && U_EXE.allowin) begin
      U_EXE.pc         <= U_ID.pc;
      U_EXE.inst       <= U_ID.inst;
      U_EXE.imm        <= U_ID.imm;
      U_EXE.rf_rdata1  <= U_ID.rf_rdata1;
      U_EXE.rf_rdata2  <= U_ID.rf_rdata2;
      U_EXE.rf_waddr   <= U_ID.rf_waddr;
      U_EXE.rf_we      <= U_ID.rf_we;
      U_EXE.alu_op     <= U_ID.alu_op;
      U_EXE.alu_in1    <= U_ID.alu_in1;
      U_EXE.alu_in2    <= U_ID.alu_in2;
      U_EXE.load_flag  <= U_ID.load_flag;
      U_EXE.store_flag <= U_ID.store_flag;
      U_EXE.cnt        <= 1;
    end
    else begin
      U_EXE.cnt <= {U_EXE.cnt[6:0], U_EXE.cnt[7]};
    end
  end

  /* 发送读写请求 */
  always @(*) begin
    if ((U_EXE.store_flag == `V__ST_W) || (U_EXE.load_flag == `V__LD_W)) begin
      U_EXE.ram_mask       = `V_ONE;
      U_RAM.data_ram_wdata = U_EXE.rf_rdata2;
    end
    else if ((U_EXE.store_flag == `V__ST_B) || (U_EXE.load_flag == `V__LD_B))  begin
      case (U_EXE.ram_addr[1:0])
        2'b00: begin U_EXE.ram_mask = 4'b0001; U_RAM.data_ram_wdata = {4{U_EXE.rf_rdata2[ 7: 0]}}; end
        2'b01: begin U_EXE.ram_mask = 4'b0010; U_RAM.data_ram_wdata = {4{U_EXE.rf_rdata2[15: 8]}}; end
        2'b10: begin U_EXE.ram_mask = 4'b0100; U_RAM.data_ram_wdata = {4{U_EXE.rf_rdata2[23:16]}}; end
        2'b11: begin U_EXE.ram_mask = 4'b1000; U_RAM.data_ram_wdata = {4{U_EXE.rf_rdata2[31:24]}}; end
      endcase
    end
    else begin
      U_EXE.ram_mask       = `V_ONE;
      U_RAM.data_ram_wdata = `V_ZERO;
    end
  end
  assign U_EXE.ram_addr      = U_EXE.rf_rdata1 + U_EXE.imm;
  assign U_EXE.ram_valid     = (U_RAM.is_uart_stat || U_RAM.is_uart_data) ? U_EXE.cnt[0] : |U_EXE.cnt[1:0];
  assign U_RAM.data_ram_addr = U_EXE.ram_addr;
  assign U_RAM.data_ram_be   = (|U_EXE.load_flag == `V_TRUE) ? `V_ONE : U_EXE.ram_mask;
  assign U_RAM.data_ram_ce   = (|{U_EXE.load_flag, U_EXE.store_flag}) && U_EXE.ram_valid;
  assign U_RAM.data_ram_oe   = (|U_EXE.load_flag) && U_EXE.ram_valid;
  assign U_RAM.data_ram_we   = (|U_EXE.store_flag) && U_EXE.ram_valid;

  assign U_RAM.is_base_ram   = (`V_BASE_RAM_BEGIN <= U_EXE.ram_addr) && (U_EXE.ram_addr <= `V_BASE_RAM_END);
  assign U_RAM.is_ext_ram    = (`V_EXT_RAM_BEGIN <= U_EXE.ram_addr) && (U_EXE.ram_addr <= `V_EXT_RAM_END);
  assign U_RAM.is_uart_stat  = U_EXE.ram_addr == `V_UART_STAT;
  assign U_RAM.is_uart_data  = U_EXE.ram_addr == `V_UART_DATA;
  assign U_RAM.is_uart       = U_RAM.is_uart_data || U_RAM.is_uart_stat;
  assign U_RAM.inst_ram_busy = U_RAM.is_base_ram && U_RAM.data_ram_ce;

  /* 计算 */
  logic [`W_DATA] add_result;
  logic [`W_DATA] sub_result;
  logic [`W_DATA] and_result;
  logic [`W_DATA] or_result;
  logic [`W_DATA] xor_result;
  logic [`W_DATA] mul_result;
  logic [`W_DATA] sll_result;
  logic [`W_DATA] srl_result;
  logic [`W_DATA] sra_result;
  logic [`W_DATA] slui_result;
  logic [`W_DATA] lui_result;
  /* mul result */
  logic [63:0] signed_mul_result;
  assign signed_mul_result = $signed(U_EXE.alu_in1) * $signed(U_EXE.alu_in2);
  /* alu result */
  assign add_result  = U_EXE.alu_in1 + U_EXE.alu_in2;                              
  assign sub_result  = U_EXE.alu_in1 + (~U_EXE.alu_in2) + 1;                       
  assign and_result  = U_EXE.alu_in1 & U_EXE.alu_in2;                              
  assign or_result   = U_EXE.alu_in1 | U_EXE.alu_in2;                              
  assign xor_result  = U_EXE.alu_in1 ^ U_EXE.alu_in2;                              
  assign mul_result  = signed_mul_result[31:0];
  assign sll_result  = U_EXE.alu_in1 << U_EXE.alu_in2[4:0];                        
  assign srl_result  = U_EXE.alu_in1 >> U_EXE.alu_in2[4:0];                        
  assign sra_result  = $signed(U_EXE.alu_in1) >>> U_EXE.alu_in2[4:0];              
  assign slui_result = $unsigned(U_EXE.alu_in1) < $unsigned(U_EXE.alu_in2) ? 1 : 0;
  assign lui_result  = U_EXE.alu_in2;                                              
  always @(*) begin
    case (U_EXE.alu_op)
      `V__ADD : begin U_EXE.alu_result = add_result;  end 
      `V__SUB : begin U_EXE.alu_result = sub_result;  end
      `V__AND : begin U_EXE.alu_result = and_result;  end
      `V__OR  : begin U_EXE.alu_result = or_result;   end
      `V__XOR : begin U_EXE.alu_result = xor_result;  end
      `V__MUL : begin U_EXE.alu_result = mul_result;  end
      `V__SLL : begin U_EXE.alu_result = sll_result;  end
      `V__SRL : begin U_EXE.alu_result = srl_result;  end
      `V__SRA : begin U_EXE.alu_result = sra_result;  end
      `V__SLTU: begin U_EXE.alu_result = slui_result; end
      `V__LUI : begin U_EXE.alu_result = lui_result;  end
      default : begin U_EXE.alu_result =  `V_ZERO;    end
    endcase
  end

endmodule