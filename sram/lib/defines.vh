`define ID_TO_SB_WD 137
`define BR_WD 33
`define RF_ADDR_WD 40
`define RF_DATA_WD 256
`define CTRL_WD 3
`define HILO_WD 66
`define INST_STATE_WD 142//ID_TO_SB_WD + ptr 
`define FU_STATE_WD 34//1+5+5+5+3+3+1+1
`define RESULT_WD 4 // 3+1

// inst_state信号位置
// `define CPLT    140
// `define ISSUED  139
`define ADDR    141:137
`define OP      103:92      // LSU_OP define in AGU
`define FU      91:89
`define REG1    88:83
`define R1VAL   82
`define R1RDY   81
`define REG2    80:75
`define R2VAL   74
`define R2RDY   73
`define REG3    72:67
`define WE      66
`define IMM     65:34
`define SEL1    33
`define SEL2    32
`define PC      31:0

`define StallBus 9
`define NoStop 1'b0
`define Stop 1'b1
`define ZeroWord 32'b0


//除法div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

`define ALU1 3'b000
`define ALU2 3'b001
`define BRU  3'b010
`define AGU  3'b011
`define HILO 3'b100
`define ALU3 3'b101
`define ALU4 3'b110
`define NULL 3'b111