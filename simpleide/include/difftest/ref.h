#ifndef __DIFFTEST_REF_H__
#define __DIFFTEST_REF_H__

#include <cpu.h>

extern CPU_state ref_cpu = {};
extern word_t ref_next_pc;
#define ref_pc ref_cpu.reg.pc
#define ref_gpr(i) ref_cpu.reg.gpr[i]
extern uint8_t ref_pmem[MEM_SIZE] = {};

void ref_execute_once(void);

#endif