#include <cpu/cputrace.h>

File *trace_Fp = NULL;

void cpu_trace_init(char *filename) {
  trace_Fp = f_open(filename, "w+");
}

void cpu_trace_print(CPU_trace *trace) {
  fprintf(
    trace_Fp->fp, "%d " FMT_WORD " %02x " FMT_WORD "\n", 
    trace->rf_we, trace->pc, trace->rf_waddr, trace->rf_wdata
  );
}