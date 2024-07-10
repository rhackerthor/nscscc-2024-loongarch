#include <difftest/ref.h>
#include <difftest/difftest.h>
#include <memory.h>

static void get_mem(void) {
  for (size_t i = 0; i < MEM_SIZE; i++) {
    pmem_write(ref_pmem, i, pmem[i], 0xf);
  }
}

static void get_reg(void) {
  for (int i = 0; i < NR_GPR; i++) {
    ref_gpr(i) = cpu_gpr(i);
  }
  ref_pc = cpu_pc;
}

static void set_reg(void) {
  for (int i = 0; i < NR_GPR; i++) {
    cpu_gpr(i) = ref_gpr(i);
  }
  cpu_pc = ref_pc;
}

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

static void difftest_memcpy(state_t direction) {
  if (direction == DIFFTEST_TO_REF) 
    get_mem();
  else
    Assert(0, "Can not copy the ref memory to the dut memory!");
}

static void difftest_regcpy(state_t direction) {
  if (direction == DIFFTEST_TO_REF)
    get_reg();
  else
    set_reg();
}

void difftest_init(void) {
  difftest_memcpy(DIFFTEST_TO_REF);
  difftest_regcpy(DIFFTEST_TO_REF);
}

static bool check_reg(void) {
#define difftest_waring(p, fmt, ...) do { \
  if (concat(ref_, p) != concat(cpu_, p)) { \
    printf("difftest fail at " fmt " except: " FMT_WORD " get: " FMT_WORD "\n", \
           ##__VA_ARGS__, concat(ref_, p), concat(cpu_, p)); \
    success = false; \
  } \
} while (0)

  bool success = true;
  for (int i = 0; i < NR_GPR; i++) {
    difftest_waring(gpr(i), "gpr(%d)(%s)", i, gpr_nr2str(i));
  }
  difftest_waring(pc, "pc");
  return success;
}

void difftest_step(uint64_t n) {
  for (int i = 0; i < n; i++) {
    ref_execute_once();
    check_reg();
  }
}