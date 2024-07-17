`include "define.sv"
interface DecodeInterface ();

  logic _add_w;
  logic _sub_w;
  logic _slt;
  logic _sltu;
  logic _nor;
  logic _and;
  logic _or;
  logic _xor;
  logic _mul_w;
  logic _sll_w;
  logic _srl_w;
  logic _sra_w;
  logic _srai_w;
  logic _srli_w;
  logic _slli_w;
  logic _slti;
  logic _sltui;
  logic _addi_w;
  logic _andi;
  logic _ori;
  logic _xori;
  logic _ld_b;
  logic _ld_w;
  logic _st_b;
  logic _st_w;
  logic _lu12i_w;
  logic _pcaddu12i;
  logic _jirl;
  logic _b;
  logic _bl;
  logic _beq;
  logic _bne;
  logic _blt;
  logic _bge;
  logic _bltu;
  logic _bgeu;

endinterface