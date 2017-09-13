///////////////////////////////////////////////////////////////////////////////////////
// Student:       Conor Dooley
// Project:       CombLock
// Target Device: XC7A100T-csg324 on Digilent Nexys-4 board
// Description:   Top-level module 
//  Created:      17 Nov 2016
///////////////////////////////////////////////////////////////////////////////////////
module comLock(input clk100,        // 100 MHz clock from oscillator on board
               input rstPBn,        // reset signal, active low, from CPU RESET pushbutton
               input sw,        // represents open doortimer
               input [5:0] kpcol,   //
               output [3:0] kprow,  //
               output [2:0] led,
               output [7:0] digit,  // digit controls - active low (7 on left, 0 on right)
               output [7:0] segment // segment controls - active low (a b c d e f g dp)
               );
// ====================================================================================
//  Interconnecting Signals
    wire clk5;              // 5 MHz clock signal, buffered
    wire reset;             // internal reset signal, active high
    wire [15:0] dispVal;    // value to be displayed
    wire [3:0] radixVal;    // radix to display
    wire newKey;            //
    wire [4:0]keyCode;           //
    wire unlock, eLED;
// ====================================================================================
//  Instantiate clock and reset generator, connect to signals
    clockReset clkGen (.clk100(clk100),       // input clock at 100 MHz
                       .rstPBn(rstPBn),       // input reset, active low
                       .clk5(clk5),         // output clock, 5 MHz	
                       .reset(reset)         // output reset, active high
                       );   
// ====================================================================================
//  Instantiation of keypad black box.    
    keypad keypad1 (.clk(clk5),
                    .rst(reset),
                    .kpcol(kpcol),
                    .kprow(kprow),
                    .newkey(newKey),
                    .keycode(keyCode)
                    );
//=====================================================================================
//  Instantiation of control module
    control control1(.clock(clk5),
                     .reset(reset),
                     .newKey(newKey),
                     .keyCode(keyCode),
                     .switch(sw),
                     .eLED(eLED),
                     .unlock(unlock),
                     .radixVal(radixVal),
                     .dispVal(dispVal)  
                     );
// ====================================================================================
//  Instantiation of display interface.
    displayInterface disp1 (.clock(clk5),      // 5 MHz clock signal
                            .reset(reset),     // reset signal, active high
                            .value(dispVal),   // input value to be displayed
                            .point(radixVal),  // radix markers to be displayed
                            .digit(digit),     // digit outputs
                            .segment(segment)  // segment outputs
                            );
//====================================================================================
//  if door switch is , door led is on 
    assign led[0] = ~sw; // one above right most button. on shows door is open - for testing lock doesnt actually hold door closed
    assign led[1] = eLED; // displays if there is an error in entering the keycode
    assign led[2] = unlock; // displays of the door is unlocked. In real system this would disable locking mechanism
  
endmodule
