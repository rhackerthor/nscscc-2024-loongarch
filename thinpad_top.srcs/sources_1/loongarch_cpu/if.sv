`include "define.sv"
module IF (
  IFInterface.master U_IF,
  IDInterface  U_ID,
  RamInterface U_RAM
);

  /* pipeline ctrl */
  always @(posedge U_IF.clk) begin
    if (U_IF.rst == `V_TRUE) begin
      U_IF.valid <= `V_FALSE;
    end
    else if (U_IF.allowin == `V_TRUE) begin
      U_IF.valid <= U_IF.valid_in;
    end
/*     else if (U_ID.branch_cancle) begin
      U_IF.valid <= `V_ZERO;
    end */
  end

  /* 流水线寄存器 */
  always @(posedge U_IF.clk) begin
    if (U_IF.rst == `V_TRUE) begin
      U_IF.pc <= `V_RST_PC;
      U_IF.cnt <= `V_ZERO;
    end
    else if (U_IF.valid_in && U_IF.allowin) begin
      U_IF.pc <= U_IF.next_pc;
      U_IF.cnt <= 1;
    end
    else begin
      U_IF.cnt <= {U_IF.cnt[6:0], U_IF.cnt[7]};
    end
  end

  /* 计算next pc */
  assign U_IF.branch_flag = U_ID.branch_cancle;
  always @(*) begin
    if (U_IF.rst) begin 
      U_IF.next_pc = `V_ZERO;
    end
    else if (U_IF.branch_flag) begin 
      U_IF.next_pc = U_ID.branch_pc;
    end
    else begin 
      U_IF.next_pc = U_IF.pc + 32'h4;
    end
  end  

  /* 输出inst ram地址 */
  assign U_RAM.inst_ram_addr = U_IF.next_pc;
  assign U_RAM.inst_ram_ce = ~U_IF.rst & U_IF.allowin;

  logic [`W_DATA] inst_r;
  logic inst_ram_busy_r;
  always @(posedge U_IF.clk) begin
    if (U_IF.cnt[0]) begin
      inst_r <= U_RAM.inst_ram_rdata;
    end
    inst_ram_busy_r <= U_RAM.inst_ram_busy;
  end
  assign U_IF.inst = inst_ram_busy_r ? inst_r : U_RAM.inst_ram_rdata;


endmodule