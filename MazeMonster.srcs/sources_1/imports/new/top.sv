`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter imem_init="imem_screentest.txt", 	// for SIMULATION:  imem_screentest_nopause.txt 
    parameter dmem_init="dmem_screentest.txt",
    parameter smem_init="smem_screentest.txt", 	// text file to initialize screen memory
    parameter bmem_init="bmem_screentest.txt" 	// text file to initialize bitmap memory
)(
    input wire clk, reset, ps2_clk, ps2_data,
    output wire [3:0] red, green, blue,
    output wire hsync, vsync,
    output wire [7:0] segments, digitselect
);
    wire [31:0] pc, instr, mem_readdata, mem_writedata, mem_addr;
    wire mem_wr;
    wire clk100, clk50, clk25, clk12;

    wire [10:0] smem_addr;
    wire [3:0] charcode;
    wire [31:0] keyb_char;
 
   

   // Uncomment *only* one of the following two lines:
   //    when synthesizing, use the first line
   //    when simulating, get rid of the clock divider, and use the second line
   //
   //clockdivider_Nexys4 clkdv(clk, clk100, clk50, clk25, clk12);
   assign clk100=clk; assign clk50=clk; assign clk25=clk; assign clk12=clk;

   // For synthesis:  use an appropriate clock frequency(ies) below
   //   clk100 will work for hardly anyone
   //   clk50 or clk 25 should work for the vast majority
   //   clk12 should work for everyone!  I'd say use this!
   //
   // Use the same clock frequency for the MIPS and data memory/memIO modules
   // The VGA display and 8-digit display should keep the 100 MHz clock.
   // For example:

   mips mips(clk12, reset, pc, instr, mem_wr, mem_addr, mem_writedata, mem_readdata, reg_);
   imem #(.Nloc(128), .Dbits(32), .initfile(imem_init)) imem(pc[31:0], instr);
   memIO #(.Nloc(16), .Dbits(32), .dmem_init(dmem_init), .smem_init(smem_init)) memIO(clk12, mem_wr, keyb_char, smem_addr, mem_addr, mem_writedata, mem_readdata, charcode);
   vgadisplaydriver #(bmem_init) display(clk100, charcode, smem_addr, red, green, blue, hsync, vsync);

endmodule