`include "define.sv"
module PipeLineCtrl (
  input logic  clk,
  input logic  rst,
  input logic  ifetch_stop_i,
  IFInterface  U_IF,
  IDInterface  U_ID,
  EXEInterface U_EXE,
  WBInterface  U_WB,
  RFInterface  U_RF
);

  assign U_IF.allowin  = !U_IF.valid  || (U_IF.ready_go  && U_ID.allowin);
  assign U_ID.allowin  = !U_ID.valid  || (U_ID.ready_go  && U_EXE.allowin);
  assign U_EXE.allowin = !U_EXE.valid || (U_EXE.ready_go && U_WB.allowin);
  assign U_WB.allowin  = !U_WB.valid  ||  U_WB.ready_go;

  assign U_IF.valid_in  = `V_TRUE;
  assign U_ID.valid_in  = U_IF.valid  & U_IF.ready_go;
  assign U_EXE.valid_in = U_ID.valid  & U_ID.ready_go;
  assign U_WB.valid_in  = U_EXE.valid & U_EXE.ready_go;

  logic [2:0] id_ready_go;
  logic if_ready_go;
  assign U_IF.ready_go  = 1'b1;//if_ready_go;
  assign U_ID.ready_go  = &id_ready_go;
  assign U_EXE.ready_go = 1'b1;
  assign U_WB.ready_go  = 1'b1;

/*   assign U_ID.rf_rdata1 = U_RF.rf_rdata1;
  assign U_ID.rf_rdata2 = U_RF.rf_rdata2; */

/*   always @(*) begin
    if (rst == `V_TRUE) begin
      id_ready_go[0] = `V_TRUE;
    end
    else if ((U_ID.rf_oe1 == `V_TRUE) && (U_ID.rf_raddr1 != `V_ZERO)) begin
      if ((U_EXE.valid == `V_TRUE) && (U_EXE.rf_we == `V_TRUE) && (U_EXE.rf_waddr == U_ID.rf_raddr1)) begin
        id_ready_go[0] = `V_FALSE;
      end
      else if ((U_WB.valid == `V_TRUE) && (U_WB.rf_we == `V_TRUE) && (U_WB.rf_waddr == U_ID.rf_raddr1)) begin
        id_ready_go[0] = `V_FALSE;
      end
      else begin
        id_ready_go[0] = `V_TRUE;
      end
    end
    else begin
      id_ready_go[0] = `V_TRUE;
    end
  end

  always @(*) begin
    if (rst == `V_TRUE) begin
      id_ready_go[1] = `V_TRUE;
    end
    else if ((U_ID.rf_oe2 == `V_TRUE) && (U_ID.rf_raddr2 != `V_ZERO)) begin
      if ((U_EXE.valid == `V_TRUE) && (U_EXE.rf_we == `V_TRUE) && (U_EXE.rf_waddr == U_ID.rf_raddr2)) begin
        id_ready_go[1] = `V_FALSE;
      end
      else if ((U_WB.valid == `V_TRUE) && (U_WB.rf_we == `V_TRUE) && (U_WB.rf_waddr == U_ID.rf_raddr2)) begin
        id_ready_go[1] = `V_FALSE;
      end
      else begin
        id_ready_go[1] = `V_TRUE;
      end
    end
    else begin
      id_ready_go[1] = `V_TRUE;
    end
  end */

  always @(*) begin
    if (rst == `V_TRUE) begin
      id_ready_go[0] = `V_TRUE;
      U_ID.rf_rdata1 = `V_ZERO;
    end
    else if ((U_ID.rf_oe1 == `V_TRUE) && (U_ID.rf_raddr1 != `V_ZERO)) begin
      if ((U_EXE.valid == `V_TRUE) && (U_EXE.rf_we == `V_TRUE) && (U_EXE.rf_waddr == U_ID.rf_raddr1)) begin
        if (|U_ID.sel_next_pc[`V_COMP:`V_JUMP] == `V_TRUE) begin
          id_ready_go[0] = `V_FALSE;
          U_ID.rf_rdata1 = `V_ZERO;
        end
        else if (|U_EXE.load_flag == `V_TRUE) begin
          id_ready_go[0] = `V_FALSE;
          U_ID.rf_rdata1 = `V_ZERO;
        end
        else begin
          id_ready_go[0] = `V_TRUE;
          U_ID.rf_rdata1 = U_EXE.rf_wdata;
        end
      end
      else if ((U_WB.valid == `V_TRUE) && (U_WB.rf_we == `V_TRUE) && (U_WB.rf_waddr == U_ID.rf_raddr1)) begin
        id_ready_go[0] = `V_TRUE;
        U_ID.rf_rdata1 = U_WB.rf_wdata;
      end
      else begin
        id_ready_go[0] = `V_TRUE;
        U_ID.rf_rdata1 = U_RF.rf_rdata1;
      end
    end
    else begin
      id_ready_go[0] = `V_TRUE;
      U_ID.rf_rdata1 = U_RF.rf_rdata1;
    end
  end

  always @(*) begin
    if (rst == `V_TRUE) begin
      id_ready_go[1] = `V_TRUE;
      U_ID.rf_rdata2 = `V_ZERO;
    end
    else if ((U_ID.rf_oe2 == `V_TRUE) && (U_ID.rf_raddr2 != `V_ZERO)) begin
      if ((U_EXE.valid == `V_TRUE) && (U_EXE.rf_we == `V_TRUE) && (U_EXE.rf_waddr == U_ID.rf_raddr2)) begin
        if (U_ID.sel_next_pc[`V_COMP] == `V_TRUE) begin
          id_ready_go[1] = `V_FALSE;
          U_ID.rf_rdata2 = `V_ZERO;
        end
        else if (|U_EXE.load_flag == `V_TRUE) begin
          id_ready_go[1] = `V_FALSE;
          U_ID.rf_rdata2 = `V_ZERO;
        end
        else begin
          id_ready_go[1] = `V_TRUE;
          U_ID.rf_rdata2 = U_EXE.rf_wdata;
        end
      end
      else if ((U_WB.valid == `V_TRUE) && (U_WB.rf_we == `V_TRUE) && (U_WB.rf_waddr == U_ID.rf_raddr2)) begin
        id_ready_go[1] = `V_TRUE;
        U_ID.rf_rdata2 = U_WB.rf_wdata;
      end
      else begin
        id_ready_go[1] = `V_TRUE;
        U_ID.rf_rdata2 = U_RF.rf_rdata2;
      end
    end
    else begin
      id_ready_go[1] = `V_TRUE;
      U_ID.rf_rdata2 = U_RF.rf_rdata2;
    end
  end

  always @(*) begin
    if (rst == `V_TRUE) begin
      id_ready_go[2] = `V_TRUE;
    end
    else if ((U_EXE.valid == `V_TRUE) && (ifetch_stop_i == `V_TRUE)) begin
      id_ready_go[2] = `V_FALSE;
    end
    else begin
      id_ready_go[2] = `V_TRUE;
    end
  end

  always @(*) begin
    if ((U_EXE.valid_in == `V_TRUE) && |U_ID.sel_next_pc[`V_COMP:`V_B_BL]) begin
      U_ID.branch_cancle = `V_TRUE;
    end
    else begin
      U_ID.branch_cancle = `V_FALSE;
    end
  end

endmodule