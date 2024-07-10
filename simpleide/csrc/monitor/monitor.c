#include <cpu.h>
#include <memory.h>
#include <verilator.h>

static char imgfile[256] = {};
static cahr wavefile[256] = {};

void sdb_set_batch_mode(void);

#include <getopt.h>
static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"wave"     , required_argument, NULL, 'w'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ((o = getopt_long(argc, argv, "-bw:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode();             break;
      case 'w': strncpy(wavefile, optarg, 256);   break;
      case  1 : strncpy(imgfile, optarg, 256);    return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

void init_monitor(int argc, char *argv[]) {
	parse_args(argc, argv);
  /* Init cpu state */
  cpu_init();
  load_image();
}
