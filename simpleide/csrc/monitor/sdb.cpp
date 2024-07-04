#include <cpu.h>
#include <verilator.h>
#include <utils.h>

/* 继续执行 */
static int cmd_c(char *args) {
  // -1会被转换为无符号数,即对应位数的最大值
	cpu_exec((uint32_t)-1);
  return 0;
}

/* 退出NEMU */
static int cmd_q(char *args) {
  return -1;
}

/* 单步执行 */
static int cmd_si(char *args) {
  uint64_t n = 1;
  if (args != NULL) 
    sscanf(args, "%lu", &n);
	cpu_exec(n);
  return 0;
}

/* 输出当前 CPU/寄存器/监视点 信息 */
static int cmd_info(char *args) {
	if (args == nullptr) {
		mycpu.display();
	}
	else {
		if (strlen(args) != 1) return 0;
		switch (args[0]) {
			case 'r': print_gpr(); break;
			default: Waring("Usage:\n" \
				"r: print infomation about regs");
		}
	}
  return 0;
}

static int cmd_help(char *args);

static struct cmd_st{
  const char *name;
  const char *description;
  int (*handler)(char *);
} cmd_table[] = {
  {"help", "Display information about all supported commands",   cmd_help},
  {"info", "Display information about the cpu",                  cmd_info},
  {"c",    "Continue the execution of the program",              cmd_c   },
  {"si",   "Lets the program pause using single step execution", cmd_si  },
  {"q",    "Exit npc",                                           cmd_q   },
};

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    for (cmd_st x: cmd_table) 
    	Log("%-5s - %s", x.name, x.description);
  }

  else {
    for (cmd_st x: cmd_table) {
      if (strcmp(arg, x.name) == 0) {
        Log("%-5s - %s", x.name, x.description);
        return 0;
      }
    }
    Waring("Unknown command '%s'", arg);
  }

  return 0;
}

#include <readline/readline.h>
#include <readline/history.h>
static char* rl_gets() {
  static char *line_read = nullptr;

  line_read = readline(ANSI_BG_BLUE "(mycpu)" ANSI_NONE " ");
  if (line_read && *line_read) add_history(line_read);

  return line_read;
}

static STATE set_batch_mode = false;
void sdb_set_batch_mode(void) {
	set_batch_mode = true;
}

void sdb_mainloop(void) {
	if (set_batch_mode) {
		cmd_c(nullptr);
		return;
	}

  for (char *str; (str = rl_gets()) != NULL;) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == nullptr) continue;

    char *args = cmd + strlen(cmd) + 1;
    args = args >= str_end ? nullptr : args;

		bool can_match = false;
    for (cmd_st x: cmd_table) {
      if (strcmp(cmd, x.name) == 0) {
				can_match = true;
        if (x.handler(args) < 0) return;
        break;
      }
    }

    if (can_match == false) 
      Waring("Unknown command '%s'", cmd);
  }
}