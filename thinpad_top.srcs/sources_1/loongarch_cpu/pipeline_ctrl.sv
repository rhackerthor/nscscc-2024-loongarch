`include "define.sv"

module PipeLineCtrl (
  input logic clk,
  input logic rst,
  input logic to_if_valid_i,
  PipeLineData U_IF,
  PipeLineData U_ID,
  PipeLineData U_EXE,
  PipeLineData U_MEM,
  PipeLineData U_WB
);

  assign U_IF.allowin  = !U_IF.valid  || (U_IF.ready_go  && U_ID.allowin);
  assign U_ID.allowin  = !U_ID.valid  || (U_ID.ready_go  && U_EXE.allowin);
  assign U_EXE.allowin = !U_EXE.valid || (U_EXE.ready_go && U_MEM.allowin);
  assign U_MEM.allowin = !U_MEM.valid || (U_MEM.ready_go && U_WB.allowin);
  assign U_WB.allowin  = !U_WB.valid  ||  U_WB.ready_go;

  assign U_IF.valid_in  = to_if_valid_i;
  assign U_ID.valid_in  = U_IF.valid  & U_IF.ready_go;
  assign U_EXE.valid_in = U_ID.valid  & U_ID.ready_go;
  assign U_MEM.valid_in = U_EXE.valid & U_EXE.ready_go;
  assign U_WB.valid_in  = U_MEM.valid & U_MEM.ready_go;

  assign U_IF.ready_go  = 1'b1; 
  // assign U_ID.ready_go  = 1'b1;
  assign U_EXE.ready_go = 1'b1;
  assign U_MEM.ready_go = 1'b1;
  assign U_WB.ready_go  = 1'b1;

  logic ready_go_id1, ready_go_id2, ready_go_id3;
  always_ff @(*) begin
    if (rst == `V_TRUE) begin
      ready_go_id1 <= 1'b1;
    end
    else if (U_ID.rf_oe1 == `V_TRUE) begin
      if (U_EXE.valid == `V_TRUE && U_EXE.rf_we == `V_TRUE && U_EXE.rf_waddr == U_ID.rf_raddr1) begin
        if (|U_EXE.load == `V_TRUE) begin
          U_ID.rf_rdata1 <= `V_ZERO;
          ready_go_id1 <= 1'b0;
        end
        else if (U_ID.branch == `V_TRUE) begin
          U_ID.rf_rdata1 <= `V_ZERO;
          ready_go_id1 <= 1'b0;
        end
        else begin
          U_ID.rf_rdata1 <= U_EXE.alu_result;
          ready_go_id1 <= 1'b1;
        end
      end
      else if (U_MEM.valid == `V_TRUE && U_MEM.rf_we == `V_TRUE && U_MEM.rf_waddr == U_ID.rf_raddr1) begin
        U_ID.rf_rdata1 <= |U_MEM.load == `V_TRUE ? U_MEM.ram_data : U_MEM.alu_result;
        ready_go_id1 <= 1'b1;
      end
      else if (U_WB.valid == `V_TRUE && U_WB.rf_we == `V_TRUE && U_WB.rf_waddr == U_ID.rf_raddr1) begin
        U_ID.rf_rdata1 <= U_WB.rf_wdata;
        ready_go_id1 <= 1'b1;
      end
      else begin
        U_ID.rf_rdata1 <= U_ID.pre_rf_rdata1;
        ready_go_id1 <= 1'b1;
      end
    end
    else begin
      U_ID.rf_rdata1 <= U_ID.pre_rf_rdata1;
      ready_go_id1 <= 1'b1;
    end
  end

  always_ff @(*) begin
    if (rst == `V_TRUE) begin
      ready_go_id2 <= 1'b1;
    end
    else if (U_ID.rf_oe2 == `V_TRUE) begin
      if (U_EXE.valid == `V_TRUE && U_EXE.rf_we == `V_TRUE && U_EXE.rf_waddr == U_ID.rf_raddr2) begin
        if (|U_EXE.load == `V_TRUE) begin
          U_ID.rf_rdata2 <= `V_ZERO;
          ready_go_id2 <= 1'b0;
        end
        else if (U_ID.branch == `V_TRUE) begin
          U_ID.rf_rdata2 <= `V_ZERO;
          ready_go_id2 <= 1'b0;
        end
        else begin
          U_ID.rf_rdata2 <= U_EXE.alu_result;
          ready_go_id2 <= 1'b1;
        end
      end
      else if (U_MEM.valid == `V_TRUE && U_MEM.rf_we == `V_TRUE && U_MEM.rf_waddr == U_ID.rf_raddr2) begin
        U_ID.rf_rdata2 <= (|U_MEM.load == `V_TRUE) ? U_MEM.ram_data : U_MEM.alu_result;
        ready_go_id2 <= 1'b1;
      end
      else if (U_WB.valid == `V_TRUE && U_WB.rf_we == `V_TRUE && U_WB.rf_waddr == U_ID.rf_raddr2) begin
        U_ID.rf_rdata2 <= U_WB.rf_wdata;
        ready_go_id2 <= 1'b1;
      end
      else begin
        U_ID.rf_rdata2 <= U_ID.pre_rf_rdata2;
        ready_go_id2 <= 1'b1;
      end
    end
    else begin
      U_ID.rf_rdata2 <= U_ID.pre_rf_rdata2;
      ready_go_id2 <= 1'b1;
    end
  end

  always_ff @(*) begin
    if (rst == `V_TRUE) begin
      ready_go_id3 <= `V_TRUE;
    end
    else if (to_if_valid_i == `V_FALSE && U_EXE.valid == `V_TRUE) begin
      ready_go_id3 <= `V_FALSE;
    end
    else begin
      ready_go_id3 <= `V_TRUE;
    end
  end

  assign U_ID.ready_go = ready_go_id1 & ready_go_id2 & ready_go_id3;

  always_ff @(*) begin
    if (U_EXE.valid_in == `V_TRUE && |U_ID.branch == `V_TRUE) begin
      U_ID.br_cancle <= `V_TRUE;
    end
    else begin
      U_ID.br_cancle <= `V_FALSE;
    end
  end

endmodule