#ifndef __CPU_CPUTRACE_H__
#define __CPU_CPUTRACE_H__

#include <common.h>

typedef struct {
  bool rf_we;
  word_t pc;
  int rf_waddr;
  word_t rf_wdata;
} CPU_trace;

void cpu_trace_init(char *filename);
void cpu_trace_print(CPU_trace *trace);

#endif