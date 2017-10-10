`timescale 1ns / 1ps
`default_nettype none

module memIO #(
    parameter Abits = 32,
    parameter Dbits = 32,
    parameter Nloc = 32,
    parameter dmem_init = "dmem.txt",
    parameter screen_mem = "screentest_smem.txt"
)(
    input wire clk,
    input wire mem_wr,
    input wire [31:0] keyb_char,
    input wire [10:0] screen_addr,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_writedata,
    output wire [31:0] to_mips,
    output wire [3:0] char_code
    );
    wire dmem_wr, smem_wr;
    wire [31:0] to_mips_character_code, mem_readdata;
    
    assign to_mips = (mem_addr[14:13] == 2'b11) ? keyb_char :
                     (mem_addr[14:13] == 2'b10) ? to_mips_character_code :
                     (mem_addr[14:13] == 2'b01) ? mem_readdata :
                     32'b0;
                     
    assign dmem_wr = (mem_wr && mem_addr[13]) ? 1'b1 : 1'b0;
    assign smem_wr = (mem_wr && mem_addr[14]) ? 1'b1 : 1'b0;
    
    screenmem #(11, 4, 1200, screen_mem) scrmem(screen_addr, mem_addr, mem_writedata, smem_wr, clk, char_code, to_mips_character_code);
    dmem #(10, 32, 1024, dmem_init) datamem(clk, dmem_wr, mem_addr, mem_writedata, mem_readdata);
    
endmodule