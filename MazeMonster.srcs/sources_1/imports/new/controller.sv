`timescale 1ns / 1ps
`default_nettype none


// These are non-R-type.  OPCODES defined here:

`define LW     6'b 100011
`define SW     6'b 101011

`define ADDI   6'b 001000
`define ADDIU  6'b 001001			// NOTE:  addiu *does* sign-extend the imm
`define ANDI   6'b 001100	
`define SLTI   6'b 001010
`define SLTIU  6'b 001011
`define ORI    6'b 001101
`define XORI   6'b 001110
`define LUI    6'b 001111

`define BEQ    6'b 000100
`define BNE    6'b 000101
`define J      6'b 000010
`define JAL    6'b 000011


// These are all R-type, i.e., OPCODE=0.  FUNC field defined here:

`define ADD    6'b 100000
`define ADDU   6'b 100001
`define SUB    6'b 100010
`define AND    6'b 100100
`define OR     6'b 100101
`define XOR    6'b 100110
`define NOR    6'b 100111
`define SLT    6'b 101010
`define SLTU   6'b 101011
`define SLL    6'b 000000
`define SLLV   6'b 000100
`define SRL    6'b 000010
`define SRA    6'b 000011
`define JR     6'b 001000  

module controller(
   input  wire [5:0] op, 
   input  wire [5:0] func,
   input  wire Z,
   
   output wire [1:0] pcsel,
   output wire [1:0] wasel, 
   output wire sext,
   output wire bsel,
   
   output wire [1:0] wdsel, 
   output logic [4:0] alufn, 			// will become wire because updated in always_comb
   output wire wr,
   output wire werf, 
   output wire [1:0] asel
   ); 
   
   /*

  assign pcsel = ((op == 6'b000000) && (func == `JR)) ? 2'b11   // controls 4-way multiplexor
               : ((op == 6'b000010) || (op == 6'b000011)) ? 2'b10                 //Jump
               : (((op == 6'b000100) && (Z)) || ((op == 6'b000101) && (~Z))) ? 2'b01
               : 2'b00;                                     //PC + 4                            
*/
  assign pcsel = ((op == 6'b0) & (func == `JR)) ? 2'b11   // controls 4-way multiplexor
             : ((op == `J) | (op == `JAL)) ? 2'b10                 //Jump
             : ((op == `BEQ) & (Z == 1)) ? 2'b01
             : ((op == `BNE) & (Z != 1)) ? 2'b01                  //BEQ and BNE
             : 2'b00;  
    
  logic [9:0] controls;
  assign {werf, wdsel[1:0], wasel[1:0], asel[1:0], bsel, sext, wr} = controls[9:0];

  always_comb
     case(op)                                     // non-R-type instructions
        `LW: controls <= 10'b 1_10_01_00_1_1_0;                  
        `SW: controls <= 10'b 0_xx_xx_00_1_1_1;        
      `ADDI: controls <= 10'b 1_01_01_00_1_1_0;
     `ADDIU: controls <= 10'b 1_01_01_00_1_1_0;
      `ANDI: controls <= 10'b 1_01_01_00_1_1_0;
      `SLTI: controls <= 10'b 1_01_01_00_1_1_0;             
     `SLTIU: controls <= 10'b 1_01_01_00_1_1_0;
       `ORI: controls <= 10'b 1_01_01_00_1_0_0;
    //`XORI: controls <= 10'b 1_01_01_00_1_0_0;
       `LUI: controls <= 10'b 1_01_01_10_1_x_0;
       `BEQ: controls <= 10'b 0_10_01_00_0_1_0;
       `BNE: controls <= 10'b 0_xx_xx_00_0_1_0;
         `J: controls <= 10'b 0_xx_xx_xx_x_x_0;
       `JAL: controls <= 10'b 1_00_10_xx_x_x_0;
       
       //0011 01ss ssst tttt iiii iiii iiii iiii
       
       
      6'b000000:                                   
         case(func)                              // R-type
             `ADD: controls <= 10'b 1_01_00_00_0_x_0;
            `ADDU: controls <= 10'b 1_01_00_00_0_x_0;
             `SUB: controls <= 10'b 1_01_00_00_0_x_0; 
             `AND: controls <= 10'b 1_01_00_00_0_x_0;
              `OR: controls <= 10'b 1_01_00_00_0_x_0;
             `XOR: controls <= 10'b 1_01_00_00_0_x_0;
             `NOR: controls <= 10'b 1_01_00_00_0_x_0; // WriteEnable, WriteDataselector, WriteAddrSelector, ASelector, BSelector,sext, data writeread
            `SLLV: controls <= 10'b 1_01_00_00_0_x_0; // ALUFN ERR
             `SLT: controls <= 10'b 1_01_00_00_0_x_0;
            `SLTU: controls <= 10'b 1_01_00_00_0_x_0;
             `SLL: controls <= 10'b 1_01_00_01_0_x_0;
             `SRL: controls <= 10'b 1_01_00_01_0_x_0;
             `SRA: controls <= 10'b 1_01_00_01_0_x_0;  
              `JR: controls <= 10'b 0_xx_xx_xx_x_x_0;       
            default: controls <= 10'b 0_xx_xx_xx_x_x_0;// unknown instruction, turn off register and memory writes
         endcase
      default: controls <= 10'b 0_xx_xx_xx_x_x_0;    // unknown instruction, turn off register and memory writes
    endcase
    
  always_comb
    case(op)                        // non-R-type instructions
        `LW: alufn <= 5'b 0xx01;
        `SW: alufn <= 5'b 0xx01;
      `ADDI: alufn <= 5'b 0xx01;
     `ADDIU: alufn <= 5'b 0xx01;
      `ANDI: alufn <= 5'b 0xx01;
      `SLTI: alufn <= 5'b 1x011;      
     `SLTIU: alufn <= 5'b 1x111;//ALUFN ERR
       `ORI: alufn <= 5'b x0100;//ALUFN ERR
    //`XORI: alufn <= 5'b x0100;//ALUFN ERR
       `LUI: alufn <= 5'b x0010;
       `BEQ: alufn <= 5'b 1xx01;
       `BNE: alufn <= 5'b 1xx01;      // BNE
       `JAL: alufn <= 5'b xxxxx;
      6'b000000:                      
         case(func)                 // R-type
             `ADD: alufn <= 5'b 0xx01; // ADD
            `ADDU: alufn <= 5'b 0xx01; // ADD
             `SUB: alufn <= 5'b 1xx01; // SUB
             `SLT: alufn <= 5'b 1x011; // Set Less Than
            `SLTU: alufn <= 5'b 1x111;
            `SLLV: alufn <= 5'b x0010; //
             `SLL: alufn <= 5'b x0010; // Shift Left Logical
             `SRL: alufn <= 5'b x1010; // Shift Right Logical
             `SRA: alufn <= 5'b x1110; // Shift Right Artihmetic
             `AND: alufn <= 5'b x0000; // AND
              `OR: alufn <= 5'b x0100; // OR
             `XOR: alufn <= 5'b x1000; // XOR
             `NOR: alufn <= 5'b x1100; // NOR
            default: alufn <= 5'b xxxxx; // ???
         endcase
      default: alufn <= 5'b xxxxx;          // J, JAL
    endcase    
    
endmodule