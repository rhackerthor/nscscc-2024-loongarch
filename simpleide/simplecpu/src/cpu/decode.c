#include <cpu/decode.h>
#include <cpu/cpu.h>
#include <cpu/cputrace.h>
#include <memory.h>

enum {
  TYPE_R, TYPE_UI5, TYPE_UI12, TYPE_SI12,
  TYPE_SI16, TYPE_SI20, TYPE_SI26
};

/* memory */
#define Mread(vaddr, mask) pmem_read(vaddr, mask)
#define Mwrite(vaddr, data, mask) pmem_write(vaddr, data, mask)
#define Mmask() (1 << BITS(src1 + imm, 1, 0))

/* reg */
#define src1R() do { *src1 = cpu_gpr(rj); } while (0)
#define src2R() do { *src2 = cpu_gpr(rk); } while (0)

/* immediate */
#define UIMM5()  do { *imm = BITS(i, 14, 10); } while (0)
#define UIMM12() do { *imm = BITS(i, 21, 10); } while (0)
#define SIMM12() do { *imm = SEXT(BITS(i, 21, 10), 12); } while (0)
#define SIMM16() do { *imm = SEXT(BITS(i, 25, 10), 16) << 2; } while (0)
#define SIMM20() do { *imm = SEXT(BITS(i, 24, 5), 20) << 12; } while (0)
#define SIMM26() do { *imm = (SEXT(BITS(i, 9, 0), 10) << 16) | BITS(i, 25, 10); } while (0)

static void decode_operand(int *rd, word_t *src1, word_t *src2, word_t *imm, state_t type) {
  word_t i = cpu.inst;
  *rd     = BITS(i,  4,  0);
  int rj  = BITS(i,  9,  5);
  int rk  = BITS(i, 14, 10);
  switch (type) {
    case TYPE_R   : src1R(); src2R();           break;
    case TYPE_UI5 : src1R();          UIMM5();  break;
    case TYPE_UI12: src1R();          UIMM12(); break;
    case TYPE_SI12: src1R();          SIMM12(); break;
    case TYPE_SI16: src1R();          SIMM16(); break;
    case TYPE_SI20:                   SIMM20(); break;
    case TYPE_SI26:                   SIMM26(); break;
    default: break;
  }
}

void decoder_execute(void) {
  int rd = 0;
  word_t src1 = 0, src2 = 0, imm = 0;
  CPU_trace trace = {};

#define INSTPAT_INST() (cpu.inst)
#define INSTPAT_MATCH(name, type, ... /* execute body */ ) { \
  decode_operand(&rd, &src1, &src2, &imm, concat(TYPE_, type)); \
  __VA_ARGS__ ; \
}

  INSTPAT_START();

  INSTPAT("00000000000100000???????????????", add_w     , R    , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 + src2);
  INSTPAT("00000000000100010???????????????", sub_w     , R    , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 - src2);
  INSTPAT("00000000000101001???????????????", and       , R    , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 & src2);
  INSTPAT("00000000000101010???????????????", or        , R    , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 | src2);
  INSTPAT("00000000000101011???????????????", xor       , R    , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 ^ src2);
  INSTPAT("00000000000111000???????????????", mul_w     , R    , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 * src2);

  INSTPAT("00000000010010001???????????????", srai_w    , UI5  , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 >> BITS(imm, 4, 0));
  INSTPAT("00000000010001001???????????????", srli_w    , UI5  , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = (signed)src1 >> BITS(imm, 4, 0));
  INSTPAT("00000000010000001???????????????", slli_w    , UI5  , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 << BITS(imm, 4, 0));

  INSTPAT("0000001001??????????????????????", sltui     , SI12 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 < imm ? 1 : 0);
  INSTPAT("0000001010??????????????????????", addi_w    , SI12 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 + imm);
  INSTPAT("0000001101??????????????????????", andi      , UI12 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 & imm);
  INSTPAT("0000001110??????????????????????", ori       , UI12 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = src1 | imm);

  INSTPAT("0010100000??????????????????????", ld_b      , SI12 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = SEXT(BITS(Mread(src1 + imm, Mmask()), 7, 0), 8));
  INSTPAT("0010100010??????????????????????", ld_w      , SI12 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = Mread(src1 + imm, 0b1111));

  INSTPAT("0010100100??????????????????????", st_b      , SI12 , trace.rf_we = 0, trace.rf_waddr =  0, trace.rf_wdata = 0, Mwrite(src1 + imm, cpu_gpr(rd), Mmask()));
  INSTPAT("0010100110??????????????????????", st_w      , SI12 , trace.rf_we = 0, trace.rf_waddr =  0, trace.rf_wdata = 0, Mwrite(src1 + imm, cpu_gpr(rd), 0xf));

  INSTPAT("0001010?????????????????????????", lu12i_w   , SI20 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = imm);
  INSTPAT("0001110?????????????????????????", pcaddu12i , SI20 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = cpu_pc + imm);

  INSTPAT("010011??????????????????????????", jirl      , SI16 , trace.rf_we = 1, trace.rf_waddr = rd, trace.rf_wdata = cpu_pc + 4, cpu_next_pc = src1 + imm);
  INSTPAT("010100??????????????????????????", b         , SI26 , trace.rf_we = 0, trace.rf_waddr =  0, trace.rf_wdata = 0, cpu_next_pc = cpu_pc + imm);
  INSTPAT("010101??????????????????????????", bl        , SI26 , trace.rf_we = 1, trace.rf_waddr =  1, trace.rf_wdata = cpu_pc + 4, cpu_next_pc = cpu_pc + imm);

  INSTPAT("010110??????????????????????????", beq       , SI16 , trace.rf_we = 0, trace.rf_waddr =  0, trace.rf_wdata = 0, cpu_next_pc = (src1 == cpu_gpr(rd)) ? cpu_pc + imm : cpu_next_pc);
  INSTPAT("010111??????????????????????????", bne       , SI16 , trace.rf_we = 0, trace.rf_waddr =  0, trace.rf_wdata = 0, cpu_next_pc = (src1 != cpu_gpr(rd)) ? cpu_pc + imm : cpu_next_pc);
  INSTPAT("011001??????????????????????????", bge       , SI16 , trace.rf_we = 0, trace.rf_waddr =  0, trace.rf_wdata = 0, cpu_next_pc = ((signed)src1 >= (signed)cpu_gpr(rd)) ? cpu_pc + imm : cpu_next_pc);

  INSTPAT_END();

  if (trace.rf_we) {
    cpu_gpr(trace.rf_waddr) = trace.rf_wdata;
  }
  cpu_gpr(0) = 0;
  trace.pc = cpu_pc;
  cpu_trace_print(&trace);
}