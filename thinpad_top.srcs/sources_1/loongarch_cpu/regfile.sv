`include "define.sv"

interface RFInterface (
  input logic clk,
  input logic rst
);

  logic [`W_DATA   ] rf [`W_RF_NR];
  logic [`W_RF_ADDR] rf_raddr1;
  logic [`W_RF_ADDR] rf_raddr2;
  logic [`W_RF_ADDR] rf_waddr;
  logic [`W_DATA   ] rf_rdata1;
  logic [`W_DATA   ] rf_rdata2;
  logic [`W_DATA   ] rf_wdata;
  logic [`W_DATA   ] rf_oe1;
  logic [`W_DATA   ] rf_oe2;
  logic [`W_DATA   ] rf_we;

endinterface

module RegFile (
  IDInterface U_ID,
  WBInterface U_WB,
  RFInterface U_RF
);

  assign U_RF.rf_raddr1 = U_ID.rf_raddr1;
  assign U_RF.rf_raddr2 = U_ID.rf_raddr2;
  assign U_RF.rf_waddr  = U_WB.rf_waddr;
  assign U_RF.rf_wdata  = U_WB.rf_wdata;
  assign U_RF.rf_oe1    = U_ID.rf_oe1;
  assign U_RF.rf_oe2    = U_ID.rf_oe2;
  assign U_RF.rf_we     = U_WB.rf_we && U_WB.valid;

  /* write reg file */
  always @(posedge U_RF.clk) begin
    if (U_RF.rst) begin
      for (int i = 0; i < `V_RF_NR; i = i + 1) begin
        U_RF.rf[i] <= `V_ZERO;
      end
    end
    else if (U_RF.rf_we && (U_RF.rf_waddr != `V_ZERO)) begin
      U_RF.rf[U_RF.rf_waddr] <= U_RF.rf_wdata;
    end
  end

  /* read reg file */
  /* rdata1 */
  always @(*) begin
    if (U_RF.rf_raddr1 == `V_ZERO) begin
      U_RF.rf_rdata1 = `V_ZERO;
    end
/*     else if (U_WB.valid && U_RF.rf_we && (U_RF.rf_raddr1 == U_RF.rf_waddr)) begin
      U_RF.rf_rdata1 = U_RF.rf_wdata;
    end */
    else begin
      U_RF.rf_rdata1 = U_RF.rf[U_RF.rf_raddr1];
    end
  end
  /* rdata2 */
  always @(*) begin
    if (U_RF.rf_raddr2 == `V_ZERO) begin
      U_RF.rf_rdata2 = `V_ZERO;
    end
/*     else if (U_WB.valid && U_RF.rf_we && (U_RF.rf_raddr2 == U_RF.rf_waddr)) begin
      U_RF.rf_rdata2 = U_RF.rf_wdata;
    end */
    else begin
      U_RF.rf_rdata2 = U_RF.rf[U_RF.rf_raddr2];
    end
  end

endmodule
