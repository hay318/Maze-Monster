`timescale 1ns / 1ps
`default_nettype none


module counter1second(
		input wire clock,
		output logic [3:0] value
	);

	logic [31:0] value_32;

		always @(posedge clock) begin
			value_32 <= value_32 + 1;
			value <= value_32[29:26];
		end
	
endmodule