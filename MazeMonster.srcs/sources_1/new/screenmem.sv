`timescale 1ns / 1ps
`default_nettype none

module screenmem #(
    parameter Abits = 11,          // Number of bits in address
    parameter Dbits = 4,         // Number of bits in data
    parameter Nloc = 1200,
    parameter mem_init
)(
    input wire [Abits-1:0] screen_addr,
    input wire [31:0] mips_addr, mem_writedata,
    input wire mem_wr, clk,
    output wire [Dbits-1:0] char_code,
    output wire [31:0] to_mips_char_code
    );
    
    always_ff @(posedge clk)                               // Memory write: only when wr==1, and only at posedge clock
          if(mem_wr)
             mem[mips_addr[10:0]] <= mem_writedata[3:0];
    
    logic [Dbits-1:0] mem [Nloc-1:0];                                      // The actual registers where data is stored
    initial $readmemh(mem_init, mem, 0, Nloc-1);
    
    assign to_mips_char_code = {28'b0, mem[mips_addr[10:0]]};
    assign char_code = mem[screen_addr];
endmodule