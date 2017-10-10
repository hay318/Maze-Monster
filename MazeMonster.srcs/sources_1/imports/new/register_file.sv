`timescale 1ns / 1ps
`default_nettype none

module register_file #(
   parameter Abits = 5, 
   parameter Nloc = 32,                      // Number of memory locations
   parameter Dbits = 32,                      // Number of bits in data
   parameter initfile = "mem_data.txt"       // Name of file with initial values
)(

   input wire clk,
   input wire wr,                            // WriteEnable:  if wr==1, data is written into mem
   input wire [Abits-1 : 0] ReadAddr1, ReadAddr2, WriteAddr, 	
                                             // 3 addresses, two for reading and one for writing
   input wire [Dbits-1 : 0] WriteData,       // Data for writing into memory (if wr==1)
   output logic [Dbits-1 : 0] ReadData1, ReadData2
                                             // 2 output ports
   );

   logic [Dbits-1:0] rf [Nloc-1:0];                                      // The actual registers where data is stored
   initial $readmemh(initfile, rf, 0, Nloc-1);  // Data to initialize registers

   always_ff @(posedge clk)                               // Memory write: only when wr==1, and only at posedge clock
      if(wr)
         rf[WriteAddr] <= WriteData;

   assign ReadData1 = (ReadAddr1==0) ? 0:
                        rf[ReadAddr1];                              // First output port
   assign ReadData2 = (ReadAddr2==0) ? 0:
                        rf[ReadAddr2];                              // Second output port
   
   
endmodule