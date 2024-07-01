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

  assign allowin_if  = !valid_if  | ready_go_if  & allowin_id;
  assign allowin_id  = !valid_id  | ready_go_id  & allowin_exe;
  assign allowin_exe = !valid_exe | ready_go_exe & allowin_mem;
  assign allowin_mem = !valid_mem | ready_go_mem;
  assign allowin_wb  = !valid_wb  | ready_go_wb;

  assign if_to_id_valid   = valid_if  & ready_go_if;
  assign id_to_exe_valid  = valid_id  & ready_go_id;
  assign exe_to_mem_valid = valid_exe & ready_go_exe;
  assign mem_to_wb_valid  = valid_mem & ready_go_mem;

  assign ready_go_if  = 1'b1;
  // assign ready_go_id  = 1'b1;
  assign ready_go_exe = 1'b1;
  assign ready_go_mem = 1'b1;
  assign ready_go_wb  = 1'b1;

endinterface

module PipeLineCtrl (
  PipeLineData.IF U_IF,
  PipeLineData.ID U_ID,
  PipeLineData.EXE U_EXE,
  PipeLineData.MEM U_MEM,
  PipeLineData.WB U_WB,
  __PipeLineCtrl U_Pipe
);

  always_ff @(*) begin
    if (U_ID.rf_oe1 == `V_TRUE) begin
      if (U_EXE.rf_we == `V_TRUE && U_ID.rf_raddr1 == U_EXE.rf_waddr) begin
        if (U_ID.branch == `V_TRUE) begin
          U_ID.rf_rdata1 <= `V_ZERO;
          U_Pipe.ready_go_id <= 1'b0;
        end
        else if (|U_EXE.load == `V_TRUE) begin
          U_ID.rf_rdata1 <= `V_ZERO;
          U_Pipe.ready_go_id <= 1'b0;
        end
        else begin
          U_ID.rf_rdata1 <= U_EXE.alu_result;
          U_Pipe.ready_go_id <= 1'b1;
        end
      end
      else if (U_MEM.rf_we == `V_TRUE && U_ID.rf_raddr1 == U_MEM.rf_waddr) begin
        U_ID.rf_rdata1 <= |U_MEM.load == `V_TRUE ? U_MEM.ram_data : U_MEM.alu_result;
        U_Pipe.ready_go_id <= 1'b1;
      end
      else if (U_WB.rf_we == `V_TRUE && U_ID.rf_raddr1 == U_WB.rf_waddr) begin
        U_ID.rf_rdata1 <= U_WB.rf_wdata;
        U_Pipe.ready_go_id <= 1'b1;
      end
      else begin
        U_ID.rf_rdata1 <= U_ID.pre_rf_rdata1;
        U_Pipe.ready_go_id <= 1'b1;
      end
    end
    else begin
      U_ID.rf_rdata1 <= U_ID.pre_rf_rdata1;
      U_Pipe.ready_go_id <= 1'b1;
    end
  end

  logic [`W_DATA] cnt;
  always_ff @(*) begin
    if (U_ID.rf_oe2 == `V_TRUE) begin
      if (U_EXE.rf_we == `V_TRUE && U_ID.rf_raddr2 == U_EXE.rf_waddr) begin
        if (U_ID.branch == `V_TRUE) begin
          U_ID.rf_rdata2 <= `V_ZERO;
          U_Pipe.ready_go_id <= 1'b0;
          cnt <= 1;
        end
        else if (|U_EXE.load == `V_TRUE) begin
          U_ID.rf_rdata2 <= `V_ZERO;
          U_Pipe.ready_go_id <= 1'b0;
          cnt <= 2;
        end
        else begin
          U_ID.rf_rdata2 <= U_EXE.alu_result;
          U_Pipe.ready_go_id <= 1'b1;
          cnt <= 3;
        end
      end
      else if (U_MEM.rf_we == `V_TRUE && U_ID.rf_raddr2 == U_MEM.rf_waddr) begin
        U_ID.rf_rdata2 <= |U_MEM.load == `V_TRUE ? U_MEM.ram_data : U_MEM.alu_result;
        U_Pipe.ready_go_id <= 1'b1;
          cnt <= 4;
      end
      else if (U_WB.rf_we == `V_TRUE && U_ID.rf_raddr2 == U_WB.rf_waddr) begin
        U_ID.rf_rdata2 <= U_WB.rf_wdata;
        U_Pipe.ready_go_id <= 1'b1;
      end
      else begin
        U_ID.rf_rdata2 <= U_ID.pre_rf_rdata2;
        U_Pipe.ready_go_id <= 1'b1;
          cnt <= 6;
      end
    end
    else begin
      U_ID.rf_rdata2 <= U_ID.pre_rf_rdata2;
      U_Pipe.ready_go_id <= 1'b1;
    end
  end

endmodule