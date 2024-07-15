/* 
 * W --> width 数据宽度
 * R --> rst value 复位值
 * V --> 变量或常量
 */
`define W_DATA 31:0 // 通用32位数据宽度
/* sram */
`define W_RAM_ADDR 19:0 // ram 地址宽度
`define W_RAM_BE 3:0    // ram 字节选择信号宽度
`define R_RAM_BE 4'hf   // ram 字节选择信号复位值
`define V_BASE_RAM_BEGIN 32'h8000_0000
`define V_BASE_RAM_END   32'h803f_ffff
`define V_EXT_RAM_BEGIN  32'h8040_0000
`define V_EXT_RAM_END    32'h807f_ffff
/* uart */
`define V_UART_STAT 32'hbfd0_03fc
`define V_UART_DATA 32'hbfd0_03f8
`define W_UART_DATA 7:0
`define V_BITRATE 9600 // 比特率
`define V_FREQUENCY 50000000 // 频率
/* regfile */
`define W_RF_ADDR 4:0 // 寄存器地址宽度
`define W_RF_NR 31:0  // 寄存器数量宽度
`define V_RF_NR 32    // 寄存器数量
`define W_RF_RD 4:0
`define W_RF_RJ 9:5
`define W_RF_RK 14:10
/* if */
`define R_PC 32'h7fff_fffc // pc复位值
`define W_SEL_NEXT_PC 3:0  // next pc选择信号宽度
`define V_SEQ  0
`define V_B_BL 1
`define V_JUMP 2
`define V_COMP 3
`define V__SEQ  4'b0001
`define V__B_BL 4'b0010
`define V__JUMP 4'b0100
`define V__COMP 4'b1000
/* exe */
`define W_ADDER 32:0
`define W_ALU_OP 12:0
`define V_ADD   0
`define V_SUB   1
`define V_AND   2
`define V_OR    3
`define V_XOR   4
`define V_NOR   5
`define V_MUL   6
`define V_SLL   7
`define V_SRL   8
`define V_SRA   9
`define V_SLT  10
`define V_SLTU 11
`define V_LUI  12
`define V__ADD  13'B0_0000_0000_0001
`define V__SUB  13'B0_0000_0000_0010
`define V__AND  13'B0_0000_0000_0100
`define V__OR   13'B0_0000_0000_1000
`define V__XOR  13'B0_0000_0001_0000
`define V__NOR  13'B0_0000_0010_0000
`define V__MUL  13'B0_0000_0100_0000
`define V__SLL  13'B0_0000_1000_0000
`define V__SRL  13'B0_0001_0000_0000
`define V__SRA  13'B0_0010_0000_0000
`define V__SLT  13'B0_0100_0000_0000
`define V__SLTU 13'B0_1000_0000_0000
`define V__LUI  13'B1_0000_0000_0000
`define W_SEL_ALU_IN2 2:0
`define V_IS_RK   0
`define V_IS_IMM  1
`define V_IS_FORE 2
`define V__IS_RK   3'B001
`define V__IS_IMM  3'B010
`define V__IS_FORE 3'B100
/* const VALUE */
`define V_TRUE 1'B1  // true
`define V_FALSE 1'B0 // false
`define V_ZERO 0     // 全0
`define V_ONE -1     // 全1
/* immedIATE */
`define W_SEL_IMM 5:0
`define V_UI5  0
`define V_UI12 1
`define V_SI12 2
`define V_SI16 3
`define V_SI20 4
`define V_SI26 5
`define V__UI5  6'B000_001
`define V__UI12 6'B000_010
`define V__SI12 6'B000_100
`define V__SI16 6'B001_000
`define V__SI20 6'B010_000
`define V__SI26 6'B100_000
/* store AND LOAD */
`define W_STORE 1:0
`define W_LOAD 1:0
`define V_ST_B 0
`define V_ST_W 1
`define V__ST_B 2'B01
`define V__ST_W 2'B10
`define V_LD_B 0
`define V_LD_W 1
`define V__LD_B 2'B01
`define V__LD_W 2'B10