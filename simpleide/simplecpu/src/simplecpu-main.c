#include <common.h>

void init_monitor(int argc, char *argv[]);
void sdb_mainloop(void);

int main(int argc, char *argv[]) {
  init_monitor(argc, argv);
  sdb_mainloop();
  return 0;
}
