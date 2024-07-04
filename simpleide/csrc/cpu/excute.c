#include <cpu.h>
#include <verilator.h>
#include <difftest.h>
#include <memory.h>

#define MAX_PRINT_STEP 10
static bool print_step = false;
CPU_state cpu = {};

/* 初始化 */
void cpu_init(void) {
  cpu.state = CPU_RUNNING;
}
/* 输出指令 */
static void execute_once(void) {
  char *p = cpu.logbuf;
  p += snprintf(p, sizeof(cpu.logbuf), FMT_WORD ":", cpu_pc);
  uint8_t *inst = (uint8_t *)&cpu.inst; 
  for (int i = 4 - 1; i >= 0; i--) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  if (print_step) {
    Log(stdout, "%s", mycpu.logbuf);
  }

  v_update(1);
}

uint64_t cpu_execute(uint64_t n) {
	print_step = n <= MAX_PRINT_STEP;
	if (cpu.state == CPU_STOP) {
		Waring("Program execution has ended. To restart the program, exit npc and run again.");
		return;
	}
	for (int i = 0; i < n; i++) {
		execute_once();
		if (cpu.state == CPU_STOP)
			return;
	}
}