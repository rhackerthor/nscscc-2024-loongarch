`include "define.sv"
interface __PipeLineCtrl (
  input to_if_valid
);

  logic valid_if;
  logic valid_id;
  logic valid_exe;
  logic valid_mem;
  logic valid_wb;

  logic allowin_if;
  logic allowin_id;
  logic allowin_exe;
  logic allowin_mem;
  logic allowin_wb;

  logic ready_go_if;
  logic ready_go_id;
  logic ready_go_exe;
  logic ready_go_mem;
  logic ready_go_wb;

  logic if_to_id_valid;
  logic id_to_exe_valid;
  logic exe_to_mem_valid;
  logic mem_to_wb_valid;

  logic br_cancle;

endinterface

module PipeLineCtrl (
  input logic clk,
  input logic rst,
  PipeLineData U_IF,
  PipeLineData U_ID,
  PipeLineData U_EXE,
  PipeLineData U_MEM,
  PipeLineData U_WB,
  __PipeLineCtrl U_Pipe
);

  assign U_Pipe.allowin_if  = !U_Pipe.valid_if  || (U_Pipe.ready_go_if  && U_Pipe.allowin_id);
  assign U_Pipe.allowin_id  = !U_Pipe.valid_id  || (U_Pipe.ready_go_id  && U_Pipe.allowin_exe);
  assign U_Pipe.allowin_exe = !U_Pipe.valid_exe || (U_Pipe.ready_go_exe && U_Pipe.allowin_mem);
  assign U_Pipe.allowin_mem = !U_Pipe.valid_mem || (U_Pipe.ready_go_mem && U_Pipe.allowin_wb);
  assign U_Pipe.allowin_wb  = !U_Pipe.valid_wb  || U_Pipe.ready_go_wb;

  assign U_Pipe.if_to_id_valid   = U_Pipe.valid_if  & U_Pipe.ready_go_if;
  assign U_Pipe.id_to_exe_valid  = U_Pipe.valid_id  & U_Pipe.ready_go_id;
  assign U_Pipe.exe_to_mem_valid = U_Pipe.valid_exe & U_Pipe.ready_go_exe;
  assign U_Pipe.mem_to_wb_valid  = U_Pipe.valid_mem & U_Pipe.ready_go_mem;

  assign U_Pipe.ready_go_if  = 1'b1;
  // assign ready_go_id  = 1'b1;
  assign U_Pipe.ready_go_exe = 1'b1;
  assign U_Pipe.ready_go_mem = 1'b1;
  assign U_Pipe.ready_go_wb  = 1'b1;

  logic ready_go_id1, ready_go_id2;
  always_ff @(*) begin
    if (rst == `V_TRUE) begin
      ready_go_id1 <= 1'b1;
    end
    else if (U_ID.rf_oe1 == `V_TRUE) begin
      if (U_Pipe.valid_exe == `V_TRUE && U_EXE.rf_we == `V_TRUE && U_EXE.rf_waddr == U_ID.rf_raddr1) begin
        ready_go_id1 <= 1'b0;
      end
      else if (U_Pipe.valid_mem == `V_TRUE && U_MEM.rf_we == `V_TRUE && U_MEM.rf_waddr == U_ID.rf_raddr1) begin
        ready_go_id1 <= 1'b0;
      end
      else if (U_Pipe.valid_wb == `V_TRUE && U_WB.rf_we == `V_TRUE && U_WB.rf_waddr == U_ID.rf_raddr1) begin
        ready_go_id1 <= 1'b0;
      end
      else begin
        ready_go_id1 <= 1'b1;
      end
    end
    else begin
      ready_go_id1 <= 1'b1;
    end
  end

  always_ff @(*) begin
    if (rst == `V_TRUE) begin
      ready_go_id2 <= 1'b1;
    end
    else if (U_ID.rf_oe2 == `V_TRUE) begin
      if (U_Pipe.valid_exe == `V_TRUE && U_EXE.rf_we == `V_TRUE && U_EXE.rf_waddr == U_ID.rf_raddr2) begin
        ready_go_id2 <= 1'b0;
      end
      else if (U_Pipe.valid_mem == `V_TRUE && U_MEM.rf_we == `V_TRUE && U_MEM.rf_waddr == U_ID.rf_raddr2) begin
        ready_go_id2 <= 1'b0;
      end
      else if (U_Pipe.valid_wb == `V_TRUE && U_WB.rf_we == `V_TRUE && U_WB.rf_waddr == U_ID.rf_raddr2) begin
        ready_go_id2 <= 1'b0;
      end
      else begin
        ready_go_id2 <= 1'b1;
      end
    end
    else begin
      ready_go_id2 <= 1'b1;
    end
  end
  assign U_Pipe.ready_go_id = ready_go_id1 & ready_go_id2;

  always_ff @(*) begin
    if (U_Pipe.id_to_exe_valid == `V_TRUE && |U_ID.sel_next_pc[`V_COMP:`V_B_BL] == `V_TRUE) begin
      U_Pipe.br_cancle <= `V_TRUE;
    end
    else begin
      U_Pipe.br_cancle <= `V_FALSE;
    end
  end

endmodule