`include "define.sv"
module EXE (
  PipeLineData.ID U_ID,
  PipeLineData.EXE U_EXE,
  PipeLineCtrl U_Pipe,
  Ram U_RAM
);

  /* 流水线寄存器 */
  always_ff @(posedge U_EXE.clk) begin
    if (U_EXE.rst == `V_TRUE) begin
      U_EXE.valid <= `V_FALSE;
    end
    else if (U_Pipe.allownin_exe == `V_TRUE) begin
      U_Pipe.valid_exe <= U_Pipe.id_to_exe_valid;
    end
    if (U_Pipe.id_to_exe_valid == `V_TRUE && U_Pipe.allownin_exe == `V_TRUE) begin
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
      U_EXE.sel_wb_data <= U_ID.sel_wb_data;
    end
  end
  /* 发送读写请求 */
  always_ff @(*) begin
    U_EXE.ram_be <= `V_ONE;
    if (U_ID.store == `V__ST_W || U_ID.load == `V__LD_W) begin
      U_EXE.ram_be <= `V_ONE;
    end
    else if (U_ID.store == `V__ST_B || U_ID.load.`V__LD_B)  begin
      case (U_EXE.ram_addr[1:0])
        2'b00:   begin U_EXE.ram_be <= 4'b0001; end
        2'b01:   begin U_EXE.ram_be <= 4'b0010; end
        2'b10:   begin U_EXE.ram_be <= 4'b0100; end
        2'b11:   begin U_EXE.ram_be <= 4'b1000; end
        default: begin U_EXE.ram_be <= `V_ONE; end
      endcase
    end
  end
  assign U_EXE.ram_addr = U_ID.rf_rdata1 + U_ID.imm;
  assign U_EXE.ram_oe = |U_ID.load;
  assign U_EXE.ram_we = |U_ID.store;
  assign U_RAM.data_ram_wdata = |{U_ID.load[`V_LD_B], U_ID.store[`V_ST_B]} ? {4{U_ID.rf_rdata2[7:0]}} : U_ID.rf_rdata2;
  assign U_RAM.data_ram_addr  = U_EXE.ram_addr;
  assign U_RAM.data_ram_be    = U_EXE.ram_be;
  assign U_RAM.data_ram_oe    = U_EXE.ram_oe;
  assign U_RAM.data_ram_we    = U_EXE.ram_we;
  /* alu */
  logic [`W_DATA] alu_in1, alu_in2;
  assign alu_in1 = sel_alu_in1 == `V_FALSE ? U_EXE.rf_rdata1 : U_EXE.pc;
  always_ff @(*) begin
    case (sel_alu_in2)
      `V__IS_RK  : begin alu_in2 <= U_EXE.rf_rdata2; end 
      `V__IS_IMM : begin alu_in2 <= U_EXE.imm; end 
      `V__IS_FORE: begin alu_in2 <= 32'h0000_0004; end 
      default: 
    endcase
  end
  /* alu result */
  logic [`W_ADDER] adder1, pre_adder2, adder2;
  logic cin, cout; // 进位
  assign cin = |{U_EXE.alu_op[`V_SUB], U_EXE.alu_op[`V_SLTU]};
  assign adder1 = {~U_EXE.uflag & alu_in1[31], alu_in1};
  assign pre_adder2 = {~U_EXE.uflag & alu_in2[31], alu_in2};
  assign adder2 = cin == `V_ONE ? ~pre_adder2 : adder2;
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
    case (alu_op)
      `V__ADD : begin alu_result <= add_result; end 
      `V__SUB : begin alu_result <= add_result; end
      `V__AND : begin alu_result <= and_result; end
      `V__OR  : begin alu_result <= or_result; end
      `V__XOR : begin alu_result <= xor_result; end
      `V__MUL : begin alu_result <= mul_result; end
      `V__SLL : begin alu_result <= sll_result; end
      `V__SRL : begin alu_result <= srl_result; end
      `V__SRA : begin alu_result <= sra_result; end
      `V__SLTU: begin alu_result <= sltu_result; end
      `V__LUI : begin alu_result <= lui_result; end
      default : begin alu_result <= `V_ZERO; end
    endcase
  end

endmodule