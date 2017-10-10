`timescale 1ns / 1ps
`timescale 1ns / 1ps
`default_nettype none

module xycounter #(parameter width=2, height=2)(
    input wire clock,
    input wire enable,
    output logic [$clog2(width)-1:0] x=0,
    output logic [$clog2(height)-1:0] y=0
    );
    
    always_ff @(posedge clock)
        if(enable)
            if (x != width - 1'b1)
                x <= enable ? x + 1'b1 : x; 
            else begin
                x <= enable ? 0 : x;
                if (y != height - 1)
                    y <= enable ? y + 1'b1 : y;
                else
                    y <= enable ? 0 : y;
     end
    
endmodule
