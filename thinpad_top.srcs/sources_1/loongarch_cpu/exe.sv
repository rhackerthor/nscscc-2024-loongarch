`include "define.sv"
module EXE (
  PipeLineData U_ID,
  PipeLineData U_EXE,
  Ram U_RAM
);

  /* 流水线寄存器 */
  always_ff @(posedge U_EXE.clk) begin
    if (U_EXE.rst == `V_TRUE) begin
      U_EXE.valid <= `V_FALSE;
    end
    else if (U_EXE.allowin == `V_TRUE) begin
      U_EXE.valid <= U_EXE.valid_in;
    end
    if (U_EXE.valid_in == `V_TRUE && U_EXE.allowin == `V_TRUE) begin
      U_EXE.pc          <= U_ID.pc;
      U_EXE.inst        <= U_ID.inst;
      U_EXE.imm         <= U_ID.imm;
      U_EXE.rf_rdata1   <= U_ID.rf_rdata1;
      U_EXE.rf_rdata2   <= U_ID.rf_rdata2;
      U_EXE.rf_waddr    <= U_ID.rf_waddr;
      U_EXE.rf_we       <= U_ID.rf_we;
      U_EXE.alu_op      <= U_ID.alu_op;
      U_EXE.sel_alu_in1 <= U_ID.sel_alu_in1;
      U_EXE.sel_alu_in2 <= U_ID.sel_alu_in2;
      U_EXE.uflag       <= U_ID.uflag;
      U_EXE.load        <= U_ID.load;
      U_EXE.store       <= U_ID.store;
      U_EXE.branch      <= U_ID.branch;
    end
  end
  /* 发送读写请求 */
  always_ff @(*) begin
    if (U_EXE.store == `V__ST_W || U_EXE.load == `V__LD_W) begin
      U_EXE.ram_be <= `V_ONE;
      U_RAM.data_ram_wdata <= U_EXE.rf_rdata2;
    end
    else if (U_EXE.store == `V__ST_B || U_EXE.load == `V__LD_B)  begin
      case (U_EXE.ram_addr[1:0])
        2'b00:   begin U_EXE.ram_be <= 4'b0001; U_RAM.data_ram_wdata <= {4{U_EXE.rf_rdata2[ 7: 0]}}; end
        2'b01:   begin U_EXE.ram_be <= 4'b0010; U_RAM.data_ram_wdata <= {4{U_EXE.rf_rdata2[15: 8]}}; end
        2'b10:   begin U_EXE.ram_be <= 4'b0100; U_RAM.data_ram_wdata <= {4{U_EXE.rf_rdata2[23:16]}}; end
        2'b11:   begin U_EXE.ram_be <= 4'b1000; U_RAM.data_ram_wdata <= {4{U_EXE.rf_rdata2[31:24]}}; end
        default: begin U_EXE.ram_be <= `V_ONE; U_RAM.data_ram_wdata <= `V_ONE; end
      endcase
    end
    else begin
      U_EXE.ram_be <= `V_ONE;
      U_RAM.data_ram_wdata <= `V_ZERO;
    end
  end
  assign U_EXE.ram_addr       = U_EXE.rf_rdata1 + U_EXE.imm;
  assign U_EXE.ram_oe         = |U_EXE.load;
  assign U_EXE.ram_we         = |U_EXE.store;
  assign U_RAM.data_ram_addr  = U_EXE.ram_addr;
  assign U_RAM.data_ram_be    = U_EXE.load == `V__LD_B ? `V_ONE : U_EXE.ram_be;
  assign U_RAM.data_ram_ce    = U_EXE.ram_oe | U_EXE.ram_we;
  assign U_RAM.data_ram_oe    = U_EXE.ram_oe;
  assign U_RAM.data_ram_we    = U_EXE.ram_we;
  /* alu */
  logic [`W_DATA] alu_in1, alu_in2;
  assign alu_in1 = U_EXE.sel_alu_in1 == `V_FALSE ? U_EXE.rf_rdata1 : U_EXE.pc;
  always_ff @(*) begin
    case (U_EXE.sel_alu_in2)
      `V__IS_RK  : begin alu_in2 <= U_EXE.rf_rdata2; end 
      `V__IS_IMM : begin alu_in2 <= U_EXE.imm; end 
      `V__IS_FORE: begin alu_in2 <= 32'h0000_0004; end 
      default: begin alu_in2 <= `V_ZERO; end
    endcase
  end
  /* alu result */
  logic [`W_ADDER] adder1, pre_adder2, adder2;
  logic cin, cout; // 进位
  assign cin = |{U_EXE.alu_op[`V_SUB], U_EXE.alu_op[`V_SLTU]};
  assign adder1 = {~U_EXE.uflag & alu_in1[31], alu_in1};
  assign pre_adder2 = {~U_EXE.uflag & alu_in2[31], alu_in2};
  assign adder2 = cin == `V_ONE ? ~pre_adder2 : pre_adder2;
  logic [`W_DATA] add_result;
  logic [`W_DATA] and_result;
  logic [`W_DATA] or_result;
  logic [`W_DATA] xor_result;
  logic [`W_DATA] sltu_result;
  logic [`W_DATA] sll_result;
  logic [`W_DATA] srl_result;
  logic [`W_DATA] sra_result;
  logic [`W_DATA] mul_result;
  logic [`W_DATA] lui_result;
  assign {cout, add_result} = adder1 + adder2 + cin;
  assign and_result  = alu_in1 & alu_in2;
  assign or_result   = alu_in1 | alu_in2;
  assign xor_result  = alu_in1 ^ alu_in2;
  assign sltu_result = {31'b0, cout};
  assign sll_result  = alu_in1 << alu_in2[4:0];
  assign srl_result  = alu_in1 >> alu_in2[4:0];
  assign sra_result  = alu_in1 >>> alu_in2[4:0];
  assign mul_result  = alu_in1 * alu_in2;
  assign lui_result  = alu_in2;
  always_ff @(*) begin
    case (U_EXE.alu_op)
      `V__ADD : begin U_EXE.alu_result <= add_result; end 
      `V__SUB : begin U_EXE.alu_result <= add_result; end
      `V__AND : begin U_EXE.alu_result <= and_result; end
      `V__OR  : begin U_EXE.alu_result <= or_result; end
      `V__XOR : begin U_EXE.alu_result <= xor_result; end
      `V__MUL : begin U_EXE.alu_result <= mul_result; end
      `V__SLL : begin U_EXE.alu_result <= sll_result; end
      `V__SRL : begin U_EXE.alu_result <= srl_result; end
      `V__SRA : begin U_EXE.alu_result <= sra_result; end
      `V__SLTU: begin U_EXE.alu_result <= sltu_result; end
      `V__LUI : begin U_EXE.alu_result <= lui_result; end
      default : begin U_EXE.alu_result <= `V_ZERO; end
    endcase
  end

endmodule