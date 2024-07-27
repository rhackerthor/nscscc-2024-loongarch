`include "define.sv"
module PipeLineCtrl (
  input logic  clk,
  input logic  rst,
  IFInterface  U_IF,
  ICInterface  U_IC,
  IDInterface  U_ID,
  EXEInterface U_EXE,
  MEMInterface U_MEM,
  WBInterface  U_WB,
  RFInterface  U_RF,
  RamInterface U_RAM
);

  assign U_IF.allowin  = !U_IF.valid  || (U_IF.ready_go  && U_IC.allowin);
  assign U_IC.allowin  = !U_IC.valid  || (U_IC.ready_go  && U_ID.allowin);
  assign U_ID.allowin  = !U_ID.valid  || (U_ID.ready_go  && U_EXE.allowin);
  assign U_EXE.allowin = !U_EXE.valid || (U_EXE.ready_go && U_MEM.allowin);
  assign U_MEM.allowin = !U_MEM.valid || (U_MEM.ready_go && U_WB.allowin);
  assign U_WB.allowin  = !U_WB.valid  ||  U_WB.ready_go;

  assign U_IF.valid_in  = `V_TRUE;
  assign U_IC.valid_in  = U_IF.valid  & U_IF.ready_go;
  assign U_ID.valid_in  = U_IC.valid  & U_IC.ready_go;
  assign U_EXE.valid_in = U_ID.valid  & U_ID.ready_go;
  assign U_MEM.valid_in = U_EXE.valid  & U_EXE.ready_go;
  assign U_WB.valid_in  = U_MEM.valid & U_MEM.ready_go;

  logic       if_ready_go;
  logic       ic_ready_go;
  logic [1:0] id_ready_go;
  logic       mem_ready_go;
  assign U_IF.ready_go  = if_ready_go;
  assign U_IC.ready_go  = ic_ready_go;// `V_TRUE;
  assign U_ID.ready_go  = &id_ready_go;
  assign U_EXE.ready_go = `V_TRUE;
  assign U_MEM.ready_go = mem_ready_go;
  assign U_WB.ready_go  = `V_TRUE;

  /* if ready go */
  always @(*) begin
    if (rst) begin
      if_ready_go = `V_TRUE;
    end
    /* 当访问base时，暂停if */
    else if (U_RAM.inst_ram_busy) begin
      if_ready_go = `V_FALSE;
    end
    else begin
      if_ready_go = `V_TRUE;
    end
  end

  always @(*) begin
    if (rst) begin
      ic_ready_go = `V_TRUE;
    end
    else if (U_RAM.inst_ram_busy) begin
      ic_ready_go = `V_FALSE;
    end
    else if (U_IC.miss) begin
      ic_ready_go = `V_FALSE;
    end
    else begin
      ic_ready_go = `V_TRUE;
    end
  end

  /* select rf rdata1 */
  assign U_ID.rf_rdata1 = U_RF.rf_rdata1;
  always @(*) begin
    if (rst) begin
      id_ready_go[0] = `V_TRUE;
    end
    else if (U_ID.rf_oe1 && (U_ID.rf_raddr1 != `V_ZERO)) begin
      if (U_EXE.valid && U_EXE.rf_we && (U_EXE.rf_waddr == U_ID.rf_raddr1)) begin
        id_ready_go[0] = `V_FALSE;
      end
      else if (U_MEM.valid && U_MEM.rf_we && (U_MEM.rf_waddr == U_ID.rf_raddr1)) begin
        id_ready_go[0] = `V_FALSE;
      end
      else if (U_WB.valid && U_WB.rf_we && (U_WB.rf_waddr == U_ID.rf_raddr1)) begin
        id_ready_go[0] = `V_TRUE;
      end
      else begin
        id_ready_go[0] = `V_TRUE;
      end
    end
    else begin
      id_ready_go[0] = `V_TRUE;
    end
  end

  /* select rf rdata2 */
  assign U_ID.rf_rdata2 = U_RF.rf_rdata2;
  always @(*) begin
    if (rst) begin
      id_ready_go[1] = `V_TRUE;
    end
    else if (U_ID.rf_oe2 && (U_ID.rf_raddr2 != `V_ZERO)) begin
      if (U_EXE.valid && U_EXE.rf_we && (U_EXE.rf_waddr == U_ID.rf_raddr2)) begin
        id_ready_go[1] = `V_FALSE;
      end
      else if (U_MEM.valid && U_MEM.rf_we && (U_MEM.rf_waddr == U_ID.rf_raddr2)) begin
        id_ready_go[1] = `V_FALSE;
      end
      else if (U_WB.valid && U_WB.rf_we && (U_WB.rf_waddr == U_ID.rf_raddr2)) begin
        id_ready_go[1] = `V_TRUE;
      end
      else begin
        id_ready_go[1] = `V_TRUE;
      end
    end
    else begin
      id_ready_go[1] = `V_TRUE;
    end
  end

  /* branch cancle */
  always @(*) begin
    if (~U_ID.cancle && U_ID.allowin && U_ID.valid_in && U_ID.branch_flag) begin
      U_ID.branch_cancle = `V_TRUE;
    end
    else begin
      U_ID.branch_cancle = `V_FALSE;
    end
  end

  /* mem ready go */
  always @(*) begin
    if (U_MEM.cnt[0] && U_RAM.data_ram_ce && (~U_RAM.is_uart)) begin
      mem_ready_go <= `V_FALSE;
    end
    else begin
      mem_ready_go <= `V_TRUE;
    end
  end

endmodule