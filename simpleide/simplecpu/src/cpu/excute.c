#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <memory.h>

#define MAX_PRINT_STEP 10
static bool print_step = false;
CPU_state cpu = {};

/* 初始化 */
void cpu_init(void) {
  cpu.state = CPU_RUNNING;
  cpu_pc    = 0x80000000;
}

static void execute_once(void) {
  /* inst fetch */
  cpu.inst    = pmem_read(cpu_pc);
  cpu_next_pc = cpu_pc + 4;
  decoder_execute();
  /* 输出指令 */
  char *p = cpu.logbuf;
  p += snprintf(p, sizeof(cpu.logbuf), FMT_WORD ":", cpu_pc);
  uint8_t *inst = (uint8_t *)&cpu.inst; 
  for (int i = 4 - 1; i >= 0; i--) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  if (print_step) {
    Log(stdout, "%s", cpu.logbuf);
  }
  /* update pc */
  if (cpu_pc == cpu_next_pc) {
    cpu.state = CPU_STOP;
  }
  cpu_pc = cpu_next_pc;
}

uint64_t cpu_execute(uint64_t n) {
	print_step = n <= MAX_PRINT_STEP;
	if (cpu.state == CPU_STOP) {
		Waring("Program execution has ended. To restart the program, exit npc and run again.");
		return 0;
	}
	for (int i = 0; i < n; i++) {
		execute_once();
		if (cpu.state == CPU_STOP)
			return i;
	}
}