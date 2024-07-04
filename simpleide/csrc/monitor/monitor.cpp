#include <cpu.h>
#include <memory.h>
#include <verilator.h>
#include <getopt.h>

static char ref_so_file[256] = {};
static char ftrace_elf_file[256] = {};
static char img_file[256] = {};

void sdb_set_batch_mode(void);

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"diff"     , required_argument, NULL, 'd'},
  	{"ftrace"		, required_argument, NULL, 'f'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ((o = getopt_long(argc, argv, "-bd:f:", table, NULL)) != -1) {
    switch (o) {
			case 'b': sdb_set_batch_mode(); 								 	break;
			case 'd': strncpy(ref_so_file, optarg, 256); 		 	break;
			case 'f': strncpy(ftrace_elf_file, optarg, 256); 	break;
      case  1 : strncpy(img_file, optarg, 256); 			 	return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
				printf("\t-f,--ftrace             function trace\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}


void init_monitor(int argc, char *argv[]) {
	parse_args(argc, argv);

	V.init("./build/wave.vcd");

	V.rst(5);

	mycpu.init();

	pmem.load_image(img_file);

	IFDEF(CONFIG_ITRACE, itrace.init());

	IFDEF(CONFIG_FTRACE, ftrace.init(ftrace_elf_file));

	IFDEF(CONFIG_DIFFTEST, difftest.init(ref_so_file, img_file));
}
