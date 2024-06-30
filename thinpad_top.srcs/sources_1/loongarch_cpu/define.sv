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
/* id */
`define W_SEL_IMM 5:0 // 立即数选择信号宽度
/* exe */
`define W_ALU_OP 10:0
`define V_ADD   0
`define V_SUB   1
`define V_AND   2
`define V_OR    3
`define V_XOR   4
`define V_MUL   5
`define V_SLL   6
`define V_SRL   7
`define V_SRA   8
`define V_SLTU  9
`define V_LUI  10
`define V__ADD  11'b0000_0000_001
`define V__SUB  11'b0000_0000_010
`define V__AND  11'b0000_0000_100
`define V__OR   11'b0000_0001_000
`define V__XOR  11'b0000_0010_000
`define V__MUL  11'b0000_0100_000
`define V__SLL  11'b0000_1000_000
`define V__SRL  11'b0001_0000_000
`define V__SRA  11'b0010_0000_000
`define V__SLTU 11'b0100_0000_000
`define V__LUI  11'b1000_0000_000
`define W_SEL_ALU_IN2 2:0
`define V_IS_RK   0
`define V_IS_IMM  1
`define V_IS_FORE 2
`define V__IS_RK   3'b001
`define V__IS_IMM  3'b010
`define V__IS_FORE 3'b100
/* const value */
`define V_TRUE 1'b1  // true
`define V_FALSE 1'b0 // false
`define V_ZERO 0     // 全0
`define V_ONE -1     // 全1
/* immediate */
`define W_SEL_IMM 5:0
`define V_UI5  0
`define V_UI12 1
`define V_SI12 2
`define V_SI16 3
`define V_SI20 4
`define V_SI26 5
`define V__UI5  6'b000_001
`define V__UI12 6'b000_010
`define V__SI12 6'b000_100
`define V__SI16 6'b001_000
`define V__SI20 6'b010_000
`define V__SI26 6'b100_000