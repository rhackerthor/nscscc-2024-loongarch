`include "define.sv"
module PipeLineCtrl (
  input logic  clk,
  input logic  rst,
  input logic  ifetch_stop_i,
  IFInterface.slave  U_IF,
  IDInterface.slave  U_ID,
  EXEInterface.slave U_EXE,
  WBInterface.slave  U_WB,
  RFInterface.slave  U_RF
);

  assign U_IF.allowin  = !U_IF.valid  || (U_IF.ready_go  && U_ID.allowin);
  assign U_ID.allowin  = !U_ID.valid  || (U_ID.ready_go  && U_EXE.allowin);
  assign U_EXE.allowin = !U_EXE.valid || (U_EXE.ready_go && U_WB.allowin);
  assign U_WB.allowin  = !U_WB.valid  ||  U_WB.ready_go;

  assign U_IF.valid_in  = `V_TRUE;
  assign U_ID.valid_in  = U_IF.valid  & U_IF.ready_go;
  assign U_EXE.valid_in = U_ID.valid  & U_ID.ready_go;
  assign U_WB.valid_in = U_EXE.valid & U_EXE.ready_go;

  assign U_IF.ready_go  = 1'b1; 
  assign U_ID.ready_go  = 1'b1;
  assign U_EXE.ready_go = 1'b1;
  assign U_WB.ready_go  = 1'b1;

  always @(*) begin
    if ((U_EXE.valid_in == `V_TRUE) && |U_ID.sel_next_pc[`V_COMP:`V_B_BL]) begin
      U_ID.branch_cancle = `V_TRUE;
    end
    else begin
      U_ID.branch_cancle = `V_FALSE;
    end
  end

endmodule