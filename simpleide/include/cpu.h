#ifndef __CPU_H__
#define __CPU_H__

#include <common.h>

/* 记录寄存器值 */
#define NR_GPR 32 // 数量
typedef struct (
  word_t pc;
  word_t gpr[NR_GPR];
) reg;

/* 记录cpu状态 */
typedef struct {
  enum {CPU_RUNNING, CPU_STOP, CPU_QUIT};
  state_t state;
  reg reg_old, reg_now;
  word_t inst;
  char logbuf[128];
} CPU_state;
extern CPU_state cpu;
#define cpu_pc cpu.now.pc
#define cpu_gpr(i) cpu.now.gpr[i]

void cpu_init(void);
uint64_t cpu_execute(uint64_t n);
void gpr_print_regfile(void);
void cpu_print_info(void);
bool cpu_error(void);

#endif