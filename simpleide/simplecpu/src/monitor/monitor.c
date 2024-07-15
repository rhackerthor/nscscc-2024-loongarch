#include <cpu/cpu.h>
#include <cpu/cputrace.h>
#include <memory.h>

static char imgfile[256] = {};
static char tracefile[256] = {};

void sdb_set_batch_mode(void);

#include <getopt.h>
static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"     , no_argument       , NULL, 'b'},
    {"cpu-trace" , required_argument , NULL, 't'},
    {0           , 0                 , NULL,  0 },
  };
  int o;
  while ((o = getopt_long(argc, argv, "-bt:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode();             break;
      case 't': strncpy(tracefile, optarg, 256);  break;
      case  1 : strncpy(imgfile, optarg, 256);    return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-t,--trace              generate cpu trace\n");
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
  cpu_trace_init(tracefile);
  load_image(imgfile);
}
