#ifndef __CPU_H__
#define __CPU_H__

#include <common.h>

/* 记录寄存器值 */
#define NR_GPR 32 // 数量
typedef struct {
  word_t gpr[NR_GPR];
  word_t pc;
} Reg;
word_t gpr_str2val(const char *gprname);
const char *gpr_nr2str(int n);
void gpr_print_regfile(void);

/* 记录cpu状态 */
enum {CPU_RUNNING, CPU_STOP, CPU_QUIT};
typedef struct {
  state_t state;
  Reg reg;
  word_t inst;
  char logbuf[128];
} CPU_state;
extern CPU_state cpu;
#define cpu_pc cpu.reg.pc
#define cpu_gpr(i) cpu.reg.gpr[i]

void cpu_init(void);
uint64_t cpu_execute(uint64_t n);
bool cpu_error(void);

#endif