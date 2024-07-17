`include "define.sv"
module EXE (
  IDInterface  U_ID,
  EXEInterface U_EXE,
  RamInterface U_RAM
);

  /* pipeline ctrl */
  always @(posedge U_EXE.clk) begin
    if (U_EXE.rst == `V_TRUE) begin
      U_EXE.valid <= `V_FALSE;
    end
    else if (U_EXE.allowin == `V_TRUE) begin
      U_EXE.valid <= U_EXE.valid_in;
    end
  end

  /* 流水线寄存器 */
  always @(posedge U_EXE.clk) begin
    if (U_EXE.valid_in == `V_TRUE && U_EXE.allowin == `V_TRUE) begin
      U_EXE.pc            <= U_ID.pc;
      U_EXE.inst          <= U_ID.inst;
      U_EXE.imm           <= U_ID.imm;
      U_EXE.rf_rdata1     <= U_ID.rf_rdata1;
      U_EXE.rf_rdata2     <= U_ID.rf_rdata2;
      U_EXE.rf_waddr      <= U_ID.rf_waddr;
      U_EXE.rf_we         <= U_ID.rf_we;
      U_EXE.alu_op        <= U_ID.alu_op;
      U_EXE.alu_in1       <= U_ID.alu_in1;
      U_EXE.alu_in2       <= U_ID.alu_in2;
      U_EXE.load_flag     <= U_ID.load_flag;
      U_EXE.store_flag    <= U_ID.store_flag;
      U_EXE.unsigned_flag <= U_ID.unsigned_flag;
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
  assign U_RAM.data_ram_addr = U_EXE.ram_addr;
  assign U_RAM.data_ram_be   = (|U_EXE.load_flag == `V_TRUE) ? `V_ONE : U_EXE.ram_mask;
  assign U_RAM.data_ram_ce   = |{U_EXE.load_flag, U_EXE.store_flag} & U_EXE.valid;
  assign U_RAM.data_ram_oe   = |U_EXE.load_flag & U_EXE.valid;
  assign U_RAM.data_ram_we   = |U_EXE.store_flag & U_EXE.valid;

  /* 计算 */
  always @(*) begin
    case (U_EXE.alu_op)
      `V__ADD : begin U_EXE.alu_result =  U_EXE.alu_in1 + U_EXE.alu_in2;                 end 
      `V__SUB : begin U_EXE.alu_result =  U_EXE.alu_in1 + (~U_EXE.alu_in2) + 1;          end
      `V__AND : begin U_EXE.alu_result =  U_EXE.alu_in1 & U_EXE.alu_in2;                 end
      `V__OR  : begin U_EXE.alu_result =  U_EXE.alu_in1 | U_EXE.alu_in2;                 end
      `V__NOR : begin U_EXE.alu_result =  ~(U_EXE.alu_in1 | U_EXE.alu_in2);              end
      `V__XOR : begin U_EXE.alu_result =  U_EXE.alu_in1 ^ U_EXE.alu_in2;                 end
      `V__MUL : begin U_EXE.alu_result =  U_EXE.alu_in1 * U_EXE.alu_in2;                 end
      `V__SLL : begin U_EXE.alu_result =  U_EXE.alu_in1 << U_EXE.alu_in2[4:0];           end
      `V__SRL : begin U_EXE.alu_result =  U_EXE.alu_in1 >> U_EXE.alu_in2[4:0];           end
      `V__SRA : begin U_EXE.alu_result =  $signed(U_EXE.alu_in1) <<< U_EXE.alu_in2[4:0]; end
      `V__SLTU: begin U_EXE.alu_result =  U_EXE.alu_in1 < U_EXE.alu_in2;                 end
      `V__LUI : begin U_EXE.alu_result =  U_EXE.alu_in2;                                 end
      default : begin U_EXE.alu_result =  `V_ZERO;                                       end
    endcase
  end
  /* rf_wdata */
  assign U_EXE.rf_wdata = U_EXE.alu_result;

endmodule