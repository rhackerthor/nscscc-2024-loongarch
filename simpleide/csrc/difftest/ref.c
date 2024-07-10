#include <difftest/ref.h>
#include <difftest/decode.h>
#include <memory.h>

CPU_state ref_cpu = {};
uint8_t ref_pmem[MEM_SIZE] = {};
word_t ref_next_pc;

void ref_execute_once(void) {
  ref_cpu.inst = pmem_read(ref_pmem, ref_pc);
  /* default next pc value */
  ref_next_pc = ref_pc + 4;
  ref_decoder_execute(ref_cpu.inst);
  /* update pc */
  ref_pc = ref_next_pc;
}