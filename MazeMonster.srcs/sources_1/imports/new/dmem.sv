`timescale 1ns / 1ps

module dmem #(
   parameter Abits = 32,        // Number of bits in address
   parameter Dbits = 32,        // Number of bits in data
   parameter Nloc = 32,         // Number of memory locations
   parameter initfile = "sqr_dmem.mem"
   )(
   input wire clk,
   input wire wr,                   // WriteEnable:  if wr==1, data is written into mem
   input wire [Abits-1 : 0] addr,   // Address for specifying memory location
   input wire [Dbits-1 : 0] din,    // Data for writing into memory (if wr==1)
   output wire [Dbits-1 : 0] dout   // Data read from memory (all the time)
   );
   
   logic [Dbits-1 : 0] mem [Nloc-1 : 0];   // The actual registers where data is stored
   initial $readmemh(initfile, mem, 0, Nloc-1);
   
   always_ff @(posedge clk)     // Memory write: only when wr==1, and only at posedge clock
      if(wr)
         mem[addr >> 2] <= din;
   
   assign dout = mem[addr >> 2];       // Memory read: read all the time, no clock involved
   
endmodule