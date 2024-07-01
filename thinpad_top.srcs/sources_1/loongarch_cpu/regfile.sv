`include "define.sv"
module RegFile (
  input logic clk,
  input logic rst,
  PipeLineData.ID U_ID,
  PipeLineData.WB U_WB
);

  /* 写寄存器 */
  logic [`W_DATA] rf [`W_RF_NR];
  always_ff @(posedge clk) begin
    if (rst == `V_TRUE) begin
      for (int i = 0; i < `V_RF_NR; i++) begin
        rf[i] <= `V_ZERO;
      end
    end
    else if (U_WB.rf_we == `V_TRUE && U_WB.rf_waddr != `V_ZERO) begin
      rf[U_WB.rf_waddr] <= U_WB.rf_wdata;
    end
  end
  /* 读寄存器 */
  assign U_ID.pre_rf_rdata1 = U_ID.rf_raddr1 == `V_ZERO ? `V_ZERO : rf[U_ID.rf_raddr1];
  assign U_ID.pre_rf_rdata2 = U_ID.rf_raddr2 == `V_ZERO ? `V_ZERO : rf[U_ID.rf_raddr2];

endmodule
