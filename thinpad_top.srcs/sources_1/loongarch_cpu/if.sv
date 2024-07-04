`include "define.sv"
module IF (
  PipeLineData U_IF,
  PipeLineData U_ID,
  __PipeLineCtrl U_Pipe,
  Ram U_RAM
);

  logic [`W_DATA] next_pc;
  logic [`W_DATA] seq_pc;
  logic           pc_we;
  /* 计算next pc */
  assign pc_we = ~U_IF.rst & U_Pipe.ready_go_id;
  assign seq_pc = U_IF.pc + 32'h0000_0004;
  assign U_IF.sel_next_pc = U_ID.sel_next_pc & {{3{U_Pipe.br_cancle}}, 1'b1};
  always_ff @(*) begin
    if (U_IF.rst == `V_TRUE) begin
      next_pc <= `V_ONE;//32'h8000_0000;
    end
    else begin 
      case (U_IF.sel_next_pc)
        `V__SEQ : begin next_pc <= seq_pc; end
        `V__B_BL: begin next_pc <= U_ID.b_bl_pc; end 
        `V__JUMP: begin next_pc <= U_ID.jump_pc; end
        `V__COMP: begin next_pc <= U_ID.comp_pc; end
        default : begin next_pc <= seq_pc; end
      endcase
    end
  end  
  /* 输出inst ram地址 */
  assign U_RAM.inst_ram_addr = next_pc;
  assign U_RAM.inst_ram_ce   = ~U_IF.rst & U_Pipe.ready_go_id;
  /* 流水线寄存器 */
  always_ff @(posedge U_IF.clk) begin
    if (U_IF.rst == `V_TRUE) begin
      U_Pipe.valid_if <= `V_FALSE;
      U_IF.pc         <= `R_PC;
    end
    else if (U_Pipe.allowin_if == `V_TRUE) begin
      U_Pipe.valid_if <= !U_Pipe.valid_if | U_Pipe.to_if_valid;
    end
    if (pc_we == `V_TRUE && U_Pipe.to_if_valid == `V_TRUE && U_Pipe.allowin_if == `V_TRUE) begin
      U_IF.pc <= next_pc;
    end
  end
  assign U_IF.inst = U_RAM.inst_ram_rdata;

endmodule