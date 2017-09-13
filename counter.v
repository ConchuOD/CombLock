///////////////////////////////////////////////////////////////////////////////////////
// Student:       Daniel Groos
// Project:       Stopwatch (reused here with small change)
// Target Device: XC7A100T-csg324 on Digilent Nexys-4 board
// Description:   This module outputs a pulse once per decisecond. It adds clock
//                cycles until it reaches MAXVAL
// Created:       November 2016
///////////////////////////////////////////////////////////////////////////////////////
module pulseGenerator(
	input clock,
	input reset,
	input run,
	input counterReset,
	output reg pulse
	);

reg [25:0] count;
reg [25:0] countNext;

always @ (posedge clock)
begin
    count <= countNext;
end

always @ (*)
begin
    if(reset || counterReset) //reset the counter
    begin 
        countNext = 25'd0;
        pulse = 1'b0;
    end
    else if(run)
    begin
    //on overflow, set overflow back to 0 and pulse to high
        if (count == 25'd24_999_999)
        begin
            countNext = 25'b0;
            pulse = 1'b1;
        end
        else
        begin
            //increment, no pulse
            countNext = count + 1'b1;
            pulse = 25'b0;
        end
    end
    else
    begin
        countNext = count;
        pulse = 1'b0;
    end
end
endmodule