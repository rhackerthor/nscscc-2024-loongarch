`include "define.sv"
module Decode (
  input logic [`W_DATA] inst,
  DecodeInterface U_D
);

  assign U_D._add_w     = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000001) && (inst[19:15] == 5'b00000);
  assign U_D._sub_w     = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000001) && (inst[19:15] == 5'b00010);
  assign U_D._and       = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000001) && (inst[19:15] == 5'b01001);
  assign U_D._or        = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000001) && (inst[19:15] == 5'b01010);
  assign U_D._xor       = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000001) && (inst[19:15] == 5'b01011);
  assign U_D._mul_w     = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000001) && (inst[19:15] == 5'b11000);
  assign U_D._srai_w    = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000100) && (inst[19:15] == 5'b10001);
  assign U_D._srli_w    = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000100) && (inst[19:15] == 5'b01001);
  assign U_D._slli_w    = (inst[31:26] == 6'b000000) && (inst[25:20] == 6'b000100) && (inst[19:15] == 5'b00001);
  assign U_D._sltui     = (inst[31:26] == 6'b000000) && (inst[25:22] == 4'b1001);
  assign U_D._addi_w    = (inst[31:26] == 6'b000000) && (inst[25:22] == 4'b1010);
  assign U_D._andi      = (inst[31:26] == 6'b000000) && (inst[25:22] == 4'b1101);
  assign U_D._ori       = (inst[31:26] == 6'b000000) && (inst[25:22] == 4'b1110);
  assign U_D._ld_b      = (inst[31:26] == 6'b001010) && (inst[25:22] == 4'b0000);
  assign U_D._ld_w      = (inst[31:26] == 6'b001010) && (inst[25:22] == 4'b0010);
  assign U_D._st_b      = (inst[31:26] == 6'b001010) && (inst[25:22] == 4'b0100);
  assign U_D._st_w      = (inst[31:26] == 6'b001010) && (inst[25:22] == 4'b0110);
  assign U_D._lu12i_w   = (inst[31:26] == 6'b000101) && (inst[25] == 1'b0);
  assign U_D._pcaddu12i = (inst[31:26] == 6'b000111) && (inst[25] == 1'b0);
  assign U_D._jirl      = (inst[31:26] == 6'b010011);
  assign U_D._b         = (inst[31:26] == 6'b010100);
  assign U_D._bl        = (inst[31:26] == 6'b010101);
  assign U_D._beq       = (inst[31:26] == 6'b010110);
  assign U_D._bne       = (inst[31:26] == 6'b010111);
  assign U_D._bge       = (inst[31:26] == 6'b011001);

endmodule