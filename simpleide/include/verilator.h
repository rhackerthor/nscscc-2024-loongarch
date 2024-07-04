#ifndef __VERILATOR_H__
#define __VERILATOR_H__

#include <verilated.h> 				// verilator常规类,包含了生成testbench的相关类
#include <verilated_vcd_c.h> 	// 为了生成vcd文件
#include <Vtop.h>             // top.v会被编译为vtop.h, 与verilog文件名对应

extern Vtop *top;
void v_init(const char *filename);
void v_update(uint64_t n);
void v_end(void);

#endif