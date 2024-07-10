#include <cpu.h>

static const char *alias[] = {
  "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

word_t gpr_str2val(const char *gprname) {
  for (int i = 0; i < NR_GPR; i++) {
    if (strcmp(gprname, alias[i]) == true) {
      return cpu_gpr(i);
    }
  }
  Assert(true, "Can not match the reg: '%s'", gprname);
}

const char *gpr_nr2str(int n) {
  Assert(RANGE(n, 0, NR_GPR), 
    "The reg number: %02d is out of range [0, %d]", 
    n, NR_GPR
  );
  return alias[n];
}

void gpr_print_regfile(void) {
  const char *SPACE = "    ";
  printf(" NR  NAME    VALUE %s", SPACE);
  printf(" NR  NAME    VALUE\n");
  for (int i = 0; i < (NR_GPR >> 1); i++) {
    int j = i + (NR_GPR >> 1);
    printf("X%02d %-4s " FMT_WORD "%s", i, alias[i], cpu_gpr(i), SPACE);
    printf("X%02d %-4s " FMT_WORD "\n", j, alias[j], cpu_gpr(j));
  }
  printf("\n");
}