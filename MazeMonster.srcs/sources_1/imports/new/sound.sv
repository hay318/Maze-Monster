`timescale 1ns / 1ps
`default_nettype none

module yoon_sound_Nexys4(
    input wire clk100,
    input wire unsigned [31:0] period,          // sound period in tens of nanoseconds
                                                // period = 1 means 10 ns (i.e., 100 MHz)      
    output logic audPWM
    );
        
    logic unsigned [31:0] count=0;
    
    always_ff @(posedge clk100)
        count <= (count >= period-1)? 0 : count + 1;           // Counter mod period
        
    assign audPWM = (count < (period >> 1));
    
endmodule