`include "define.sv"
module LoongCpu (
  input  logic clk,
  input  logic rst,
  input  logic ifetch_stop_i,
  /* inst ram */
  input  logic [`W_DATA  ] inst_ram_rdata_i,
  output logic [`W_DATA  ] inst_ram_addr_o,
  output logic             inst_ram_ce_o,
  /* data ram */
  input  logic [`W_DATA  ] data_ram_rdata_i,
  output logic [`W_DATA  ] data_ram_wdata_o,
  output logic [`W_DATA  ] data_ram_addr_o,
  output logic [`W_RAM_BE] data_ram_be_o,
  output logic             data_ram_ce_o,
  output logic             data_ram_oe_o,
  output logic             data_ram_we_o
);

  /* Interface */
  IFInterface  U_IF  (clk, rst); /*   if    */
  IDInterface  U_ID  (clk, rst); /*   id    */
  EXEInterface U_EXE (clk, rst); /*   exe   */
  WBInterface  U_WB  (clk, rst); /*   wb    */
  RFInterface  U_RF  (clk, rst); /* regfile */
  RamInterface U_RAM(            /*   ram   */
    .inst_ram_rdata (inst_ram_rdata_i),
    .inst_ram_addr  (inst_ram_addr_o ),
    .inst_ram_ce    (inst_ram_ce_o   ),
    .data_ram_rdata (data_ram_rdata_i),
    .data_ram_wdata (data_ram_wdata_o),
    .data_ram_addr  (data_ram_addr_o ),
    .data_ram_be    (data_ram_be_o   ),
    .data_ram_ce    (data_ram_ce_o   ),
    .data_ram_oe    (data_ram_oe_o   ),
    .data_ram_we    (data_ram_we_o   )
  );

  RegFile RegFile0 (
    .U_ID (U_ID),
    .U_WB (U_WB),
    .U_RF (U_RF)
  );

  PipeLineCtrl PipeLineCtrl0 (
    .clk           (clk          ), 
    .rst           (rst          ),
    .ifetch_stop_i (ifetch_stop_i),
    .U_IF          (U_IF         ),
    .U_ID          (U_ID         ),
    .U_EXE         (U_EXE        ),
    .U_WB          (U_WB         ),
    .U_RF          (U_RF         )
  );

  IF  IF0  (U_IF  , U_ID  , U_RAM);
  ID  ID0  (U_IF  , U_ID         );
  EXE EXE0 (U_ID  , U_EXE , U_RAM);
  WB  WB0  (U_EXE , U_WB  , U_RAM);

endmodule