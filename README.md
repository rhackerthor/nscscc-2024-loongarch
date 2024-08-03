# NSCSCC 2024 loongarch-cpu 使用说明
```txt
为方便对CPU进行调试，用verilator + c/c++搭建了一个外部调试环境，并用c/c++构建了一个cpu模拟器用于进行差分测试。
```
## 项目构成
```bash
.
├── asm
├── Makefile # 用于调用调试等工具
├── README.md
├── simpleide # 包含调试，构建内核的工具
│   ├── inst-interpreter # 构建内核工具，用于生成译码相关sv代码
│   │   ├── inst.xlsx
│   │   ├── Makefile
│   │   ├── requirements.txt
│   │   └── src # python源码，读取表格文件内容，生成所需sv代码
│   ├── rom # 编译测试汇编代码
│   │   ├── asm
│   │   ├── include
│   │   └── Makefile
│   ├── scripts # 工具运行脚本
│   │   ├── native.mk
│   │   └── tools.mk
│   └── simplecpu # trace生成工具
│        ├── include
│        ├── Makefile
│        └── src # c语言源码
├── tb_behav.wcfg # 波形文件
├── thinpad_top.srcs
│   ├── constrs_1
│   ├── sim_1
│   └── sources_1
│       ├── ip # 包含
│       ├── loongarch_cpu # cpu内核
│       │   ├── debug_interface.sv
│       │   ├── decode_interface.sv
│       │   ├── decode.sv
│       │   ├── define.sv
│       │   ├── exe_interface.sv
│       │   ├── exe.sv
│       │   ├── icache_interface.sv
│       │   ├── icache.sv
│       │   ├── id_interface.sv
│       │   ├── id.sv
│       │   ├── if_interface.sv
│       │   ├── if.sv
│       │   ├── loongcpu.sv
│       │   ├── mem_interface.sv
│       │   ├── mem.sv
│       │   ├── pipeline_ctrl.sv
│       │   ├── ram_interface.sv
│       │   ├── ram_uart_ctrl.sv
│       │   ├── regfile.sv
│       │   ├── wb_interface.sv
│       │   └── wb.sv
│       └── new
└── thinpad_top.xpr
```