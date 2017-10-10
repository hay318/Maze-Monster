`timescale 1ns / 1ps

module datapath #(
   parameter Abits = 32,          // Number of bits in address
   parameter Dbits = 32,         // Number of bits in data
   parameter Nloc = 32           // Number of memory locations
)(
    input wire clk,
    input wire reset,
    
    output wire [31:0] pc,
    input wire [31:0] instr,
    
    input wire werf,
    input wire [1:0] pcsel, wasel, wdsel, asel,
    input wire [4:0] alufn,
    input wire bsel, sext,
    
    output wire Z,
    output wire [Abits-1:0] mem_addr,
    output wire [Dbits-1:0] mem_writedata,
    input wire [Dbits-1:0] mem_readdata
    );           
    wire [31:0] signImm; 
    wire [Dbits-1:0] aluA, aluB;
    wire [Dbits-1:0] reg_writedata;
    wire [4:0] reg_writeaddr; 
      
    logic [Dbits-1:0] ReadData1;
    logic [Dbits-1:0] ReadData2;
    wire [Dbits-1:0] alu_result;
    
    wire [Dbits-1:0] BT;
    wire [31:0] pcPlus4;
    wire [31:0] newPC;
    logic [31:0] pcIns = 0;
    assign newPC = (pcsel == 2'b11) ? ReadData1 : 
                       (pcsel == 2'b10) ? {pc[31:28],instr[25:0],2'b00} :
                       (pcsel == 2'b01) ? BT :
                       pcPlus4; 
                       
    always_ff @(posedge clk)
    begin
        pcIns <= (reset == 1) ? 0 :newPC;
    end
    assign pcPlus4 = pcIns + 4;
    assign pc = pcIns;
    assign reg_writeaddr = (wasel == 2'b10) ? 5'b11111 :
                           (wasel == 2'b01) ? instr[20:16] :
                           instr[15:11];

    register_file //#(Abits, Dbits, Nloc) 
        registers(clk, werf, instr[25:21], instr[20:16], reg_writeaddr, reg_writedata, ReadData1, ReadData2);
    
    assign mem_writedata = ReadData2;   
    
    assign signImm = (sext == 1 & instr[15] == 1) ? {16'b1111111111111111, instr[15:0]}
                      : {16'b0, instr[15:0]};
    
    assign aluA = (asel == 2'b10) ? {5'b10000} : 
                       (asel == 2'b01) ? instr[10:6]:
                       ReadData1;
    assign aluB = (bsel == 1'b1) ? signImm : ReadData2;       
    
    addsub bqeadder(.A( pcPlus4), .B(signImm << 2), .Subtract(1'b0), .Result(BT));
    
    ALU #(Nloc) alu_unit(aluA, aluB, alu_result, alufn, Z);
    assign mem_addr = alu_result;
         
    assign reg_writedata = (wdsel == 2'b10) ? mem_readdata :
                       (wdsel == 2'b01) ? alu_result :
                       pcPlus4;
endmodule