#include <cpu.h>
#include <verilator.h>

VerilatedContext *contextp nullptr;
VerilatedVcdC *tfp = nullptr;
Vtop *top = nullptr;

extern "C" v_init(const char *filename) {
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new Vtop;

  contextp->traceEverOn(true);
  contextp->randReset(0);

  top->trace(tfp, 0);
  tfp->open(filename);
}

static void v_one_cycle() {
  for (int i = 1; i >= 0; i--) {
    top->clk = i;
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
  }
}

static void v_rst(uint64_t n) {
  top->rst = 1; v_update(n);
  top->rst = 0; v_update(1);
}

extern "C" void v_update(uint64_t n) {
  for (int i = 0; i < n; i++)
    v_one_cycle();
}

extern "C" void v_end(void) {
  top->final();
  tfp->close();
  delete top;
  delete contextp;
  delete tfp;
}