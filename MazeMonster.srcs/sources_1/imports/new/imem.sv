`timescale 1ns / 1ps

module imem #(
   parameter Abits = 32,        // Number of bits in address
   parameter Dbits = 32,        // Number of bits in data
   parameter Nloc = 32,         // Number of memory locations
   parameter initfile = "sqr_imem.mem"
   )(
   input wire [31:0] pc,
   output wire [31:0] instr
   );
   
   logic [Dbits-1 : 0] mem [Nloc-1 : 0];   // The actual registers where data is stored
   initial $readmemh(initfile, mem, 0, Nloc-1);
   
   assign instr = mem[ pc >> 2];
endmodule