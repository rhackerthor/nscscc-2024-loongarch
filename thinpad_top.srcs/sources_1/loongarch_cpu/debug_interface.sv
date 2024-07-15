`include "define.sv"
interface DebugInterface (
  output logic              valid,
  output logic              rf_we,
  output logic [`W_DATA   ] pc,
  output logic [`W_RF_ADDR] rf_waddr,
  output logic [`W_DATA   ] rf_wdata
);
    
endinterface