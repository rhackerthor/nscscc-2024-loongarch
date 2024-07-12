`include "define.sv"
interface IFInterface (
  input logic clk,
  input logic rst
);

  /* pipeline ctrl signal */
  logic valid;
  logic valid_in;
  logic allowin;
  logic ready_go;
  /* data */
  logic [`W_DATA] pc;
  logic [`W_DATA] inst;

  /* pipeline ctrl */
  always @(posedge clk) begin
    if (rst == `V_TRUE) begin
      valid <= `V_FALSE;
    end
    else if (allowin == `V_TRUE) begin
      valid <= valid_in;
    end
  end

  modport master (
    input  clk,
    input  rst,
    input  valid_in,
    input  allowin,
    input  ready_go,
    input  valid,
    output pc,
    output inst
  );

  modport slave (
    output valid_in,
    output allowin,
    output ready_go,
    input  valid,
    input  pc,
    input  inst
  );

endinterface