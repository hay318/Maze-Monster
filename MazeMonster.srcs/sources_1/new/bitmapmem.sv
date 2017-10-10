`timescale 1ns / 1ps
`default_nettype none

module bitmapmem #(
    parameter Abits = 12,          // Number of bits in address
    parameter Dbits = 12,         // Number of bits in data
    parameter Nloc = 2560,
    parameter mem_init
)(
    input wire [Abits-1:0] bitmap_addr,
    output wire [Dbits-1:0] color_value
    );
    
    logic [Dbits-1:0] mem [Nloc-1:0];                                      // The actual registers where data is stored
    initial $readmemh(mem_init, mem, 0, Nloc-1);
        
    assign color_value = mem[bitmap_addr];
    
endmodule