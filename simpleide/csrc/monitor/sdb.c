#include <cpu.h>

/* 继续执行 */
static int cmd_c(char *args) {
  // -1会被转换为无符号数,即对应位数的最大值
	mycpu.execute((uint32_t)-1);
  return 0;
}

/* 退出 */
static int cmd_q(char *args) {
  cpu.state = CPU_QUIT;
  return -1;
}

/* 单步执行 */
static int cmd_si(char *args) {
  uint64_t n = 1;
  if (args != NULL) {
    sscanf(args, "%lu", &n);
  }
	execute(n);
  return 0;
}

/* 输出当前 寄存器/监视点 信息 */
static int cmd_info(char *args) {
  if (strlen(args) != 1) return 0;
  switch (args[0]) {
    case 'r': print_gpr(); break;
    default: Waring("Usage:\nr: print infomation about regs");
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

#define NR_CMD ARRLEN(cmd_table)
static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  /* 打印全部命令说明 */
  if (arg == NULL) {
    for (int i = 0; i < NR_CMD; i++) {
    	printf("%-5s - %s", cmd_table[i].name, cmd_table[i].description);
    }
  }
  /* 打印指定命令说明 */
  else {
    for (int i = 0; i < NR_CMD; i++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%-5s - %s", cmd_table[i].name, cmd_table[i].description);
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
  static char *line_read = NULL;
  /* 输入line_read */
  line_read = readline(ANSI_BG_BLUE "loongcpu " ANSI_NONE " ");
  /* 保证line_read不为空, 并将其放入历史 */
  if (line_read && *line_read) { add_history(line_read); }
  return line_read;
}

static state_t set_batch_mode = false;
void sdb_set_batch_mode(void) {
	set_batch_mode = true;
}

void sdb_mainloop(void) {
  /* 检查是否开启批处理模式 */
	if (set_batch_mode) {
		cmd_c(NULL);
		return;
	}
  for (char *str; (str = rl_gets()) != NULL;) {
    char *str_end = str + strlen(str);
    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) continue;
    /* extract the other tokens as the argument */
    char *args = cmd + strlen(cmd) + 1;
    args = args >= str_end ? NULL : args;
    /* match the commands with cmd_table */
		bool can_match = false;
    for (int i = 0; i < NR_CMD; i++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
				can_match = true;
        if (cmd_table[i].handler(args) < 0) return;
        break;
      }
    }
    if (can_match == false) { Waring("Unknown command '%s'", cmd); }
  }
}