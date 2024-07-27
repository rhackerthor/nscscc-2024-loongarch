/* 
 * W --> width 数据宽度
 * V --> 常量
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
`define V_FREQUENCY 100000000 // 频率
/* regfile */
`define W_RF_ADDR 4:0 // 寄存器地址宽度
`define W_RF_NR 31:0  // 寄存器数量宽度
`define V_RF_NR 32    // 寄存器数量
`define W_RF_RD 4:0
`define W_RF_RJ 9:5
`define W_RF_RK 14:10
/* if */
`define V_RST_PC 32'h7fff_fffc // pc复位值
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
`define V__ADD  (1 << `V_ADD )
`define V__SUB  (1 << `V_SUB )
`define V__AND  (1 << `V_AND )
`define V__OR   (1 << `V_OR  )
`define V__XOR  (1 << `V_XOR )
`define V__MUL  (1 << `V_MUL )
`define V__SLL  (1 << `V_SLL )
`define V__SRL  (1 << `V_SRL )
`define V__SRA  (1 << `V_SRA )
`define V__SLTU (1 << `V_SLTU)
`define V__LUI  (1 << `V_LUI )
/* mul */
`define W_MUL_RESULT 63:0
`define W_MUL_LB 31:0
`define W_MUL_HB 63:32
/* sel alu in2 */
`define W_SEL_ALU_IN2 2:0
`define V_IS_RK   0
`define V_IS_IMM  1
`define V_IS_FOUR 2
`define V__IS_RK   (1 << `V_IS_RK  ) 
`define V__IS_IMM  (1 << `V_IS_IMM )
`define V__IS_FOUR (1 << `V_IS_FOUR)
/* const VALUE */
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
`define V__UI5  (1 << `V_UI5 )
`define V__UI12 (1 << `V_UI12)
`define V__SI12 (1 << `V_SI12)
`define V__SI16 (1 << `V_SI16)
`define V__SI20 (1 << `V_SI20)
`define V__SI26 (1 << `V_SI26)
/* store and load */
`define W_STORE 1:0
`define W_LOAD 1:0
`define V_ST_B 0
`define V_ST_W 1
`define V__ST_B 2'b01
`define V__ST_W 2'b10
`define V_LD_B 0
`define V_LD_W 1
`define V__LD_B 2'b01
`define V__LD_W 2'b10
/* icache */
`define W_ICACHE 31:0
`define V_ICACHE 32
`define W_VADDR 6:2