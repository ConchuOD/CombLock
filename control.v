///////////////////////////////////////////////////////////////////////////////////////
// Student:       Conor Dooley
// Project:       Lock
// Target Device: XC7A100T-csg324 on Digilent Nexys-4 board
// Description:   This module is an FSM which controls the operation of the combLock
//                
// Created:       November 2016
//////////////////////////////////////////////////////////////////////////////////////
module control (
    input clock, reset,
    input newKey,
    input [4:0] keyCode,
    input switch,
    output reg eLED, unlock,
    output reg [3:0] radixVal,
    output reg [15:0] dispVal    
    );
reg [11:0] currentState, nextState; //register to hold state, and variable to hold next state
wire  continu;
reg counterReset, enable;
localparam  STATE_IDLE       = 12'b0000_0000_0001, //
            STATE_1WRONG     = 12'b0000_0000_0010, //
            STATE_2WRONG     = 12'b0000_0000_0100, //
            STATE_3WRONG     = 12'b0000_0000_1000, //
            STATE_4WRONG     = 12'b0000_0001_0000, //
            STATE_1CORRECT   = 12'b0000_0010_0000, //
            STATE_2CORRECT   = 12'b0000_0100_0000, //
            STATE_3CORRECT   = 12'b0000_1000_0000, //
            STATE_4CORRECT   = 12'b0001_0000_0000, //
            STATE_WAIT_ERROR = 12'b0010_0000_0000, //
            STATE_UNLOCKED   = 12'b0100_0000_0000, //
            STATE_OPEN       = 12'b1000_0000_0000; //

always @ (posedge clock)
begin
    currentState <= nextState;
end

always @ ( * )
begin
    if(reset) nextState = STATE_IDLE; //reset goes to idle
    else
    begin
        case (currentState)
            // only leave this idle state if there is a new key press
            STATE_IDLE:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b10001)//correct code
                    begin
                    nextState = STATE_1CORRECT;
                    end
                    else if(keyCode==5'b01100 || keyCode==5'b00100) //handling enter and clear, they do nothing here
                    begin
                    nextState = STATE_IDLE;
                    end
                    else
                    begin
                    nextState = STATE_1WRONG;  
                    end 
                end
                else
                begin
                nextState = STATE_IDLE;
                end
            end
            //now wrong states, so rouge user cannot easily figure out correctness from display
            //leave on key press, clear returns to idle others advance 
            STATE_1WRONG:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b01100) //left side black - clear
                    begin
                    nextState = STATE_IDLE;
                    end
                    else if(keyCode==5'b00100)//right side black - enter
                    begin
                    nextState = STATE_WAIT_ERROR;
                    end
                    else
                    begin
                    nextState = STATE_2WRONG;
                    end
                end 
                else
                begin
                nextState = STATE_1WRONG;
                end
            end
            //leave on key press, clear returns to idle others advance 
            STATE_2WRONG:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b01100) //left side black - clear
                     begin
                     nextState = STATE_IDLE;
                     end
                     else if(keyCode==5'b00100)//right side black - enter
                     begin
                     nextState = STATE_WAIT_ERROR;
                     end
                     else
                     begin
                     nextState = STATE_3WRONG;
                     end
                end 
                else
                begin
                nextState = STATE_2WRONG;
                end
            end
            //leave on key press, clear returns to idle others advance 
            STATE_3WRONG:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b01100)//left side black - clear
                     begin
                     nextState = STATE_IDLE;
                     end
                     else if(keyCode==5'b00100)//right side black - enter
                     begin
                     nextState = STATE_WAIT_ERROR;
                     end
		     else if(keyCode==5'b01100)//left side black - clear
                     begin
                     nextState = STATE_IDLE;
                     end
                     else
                     begin
                     nextState = STATE_4WRONG;
                     end
                end 
                else
                begin
                nextState = STATE_3WRONG;
                end
            end
            //leave on enter - goes to error state, clear returns to idle others advance 
            STATE_4WRONG:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b01100)//left side black - clear
                     begin
                     nextState = STATE_IDLE;
                     end
                     else if(keyCode==5'b00100)//right side black - enter
                     begin
                     nextState = STATE_WAIT_ERROR;
                     end
                     else
                     begin
                     nextState = STATE_4WRONG;
                     end
                end 
                else
                begin
                nextState = STATE_4WRONG;
                end
            end
            //leave error state after 5 seconds
            STATE_WAIT_ERROR:
            begin
                if(continu)
                begin
                nextState = STATE_IDLE;
                end
                else
                begin nextState = STATE_WAIT_ERROR;
                end
            end
            //now correct states
            //leave if correct keycode to next correct, if error keycode to next wrong, or on clear to idle
            STATE_1CORRECT:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b10000)//correct code
                    begin
                    nextState = STATE_2CORRECT;
                    end
                    else if(keyCode==5'b01100)//left side black - clear
                    begin
                    nextState = STATE_IDLE;
                    end
                    else if(keyCode==5'b00100)//right side black - enter
                    begin
                    nextState = STATE_WAIT_ERROR;
                    end
                    else
                    begin
                    nextState = STATE_2WRONG;
                    end  
                end
                else
                begin
                nextState = STATE_1CORRECT;
                end
            end
            //leave if correct keycode to next correct, if error keycode to next wrong, or on clear to idle
            STATE_2CORRECT:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b10001) //correct code
                    begin
                    nextState = STATE_3CORRECT;
                    end
                    else if(keyCode==5'b01100)//left side black - clear
                    begin
                    nextState = STATE_IDLE;
                    end 
                    else if(keyCode==5'b00100)//right side black - enter
                    begin
                    nextState = STATE_WAIT_ERROR;
                    end                   
                    else
                    begin
                    nextState = STATE_3WRONG;
                    end   
                end
                else
                begin
                nextState = STATE_2CORRECT;
                end
            end
            //leave if correct keycode to next correct, if error keycode to next wrong, or on clear to idle
            STATE_3CORRECT:
            begin
                if(newKey==1'b1)
                begin
                    if(keyCode==5'b10000)//correct code
                    begin
                    nextState = STATE_4CORRECT;
                    end
                    else if(keyCode==5'b01100)//left side black - clear
                    begin
                    nextState = STATE_IDLE;
                    end  
                    else if(keyCode==5'b00100)//right side black - clear
                    begin
                    nextState = STATE_WAIT_ERROR;
                    end                  
                    else
                    begin
                    nextState = STATE_4WRONG;
                    end   
                end
                else
                begin
                nextState = STATE_3CORRECT;
                end
            end
            //leave if enter to unlocked, if error keycode error state, or on clear to idle
            STATE_4CORRECT:
            begin
                if(newKey==1'b1)
                begin
                     if(keyCode==5'b00100)//right side black
                     begin
                     nextState = STATE_UNLOCKED;
                     end
                     else if(keyCode==5'b01100)//left side black
                     begin
                     nextState = STATE_IDLE;
                     end
                     else
                     begin
                     nextState = STATE_4CORRECT;//ignore further input
                     end
                 end
                 else
                 begin
                 nextState = STATE_4CORRECT;
                 end
            end
            //leave unlocked state after 5 seconds if door isnt opened - this is the period of time they have to open the door
            //or if the door gets opened
            STATE_UNLOCKED:
            begin
                if(~switch)
                begin
                nextState = STATE_OPEN;
                end
                else if(continu)
                begin
                nextState = STATE_IDLE;
                end
                else
                begin
                nextState = STATE_UNLOCKED;
                end
            end
            //when door gets closed, go to idle
            STATE_OPEN:
            begin
                if(switch)
                begin
                nextState = STATE_IDLE;
                end
                else
                begin
                nextState = STATE_OPEN;
                end
            end
            //otherwise to idle
            default:
            begin
                nextState = STATE_IDLE; //default state after restart is idle
            end     
        endcase
    end
end

always @ (currentState)
begin
    if(currentState==STATE_IDLE) //idle state turns on all radices and turns off digits. It also resets the counters
    begin
        dispVal = 16'b1111_1111_1111_1111;
        radixVal = 4'b0000;
        eLED = 1'b0;
        unlock = 1'b0;
        counterReset = 1'b1;
    end
    else if(currentState==STATE_1WRONG || currentState==STATE_1CORRECT) //turn on a hyphen to signify entered digits
    begin
        dispVal = 16'b1111_1111_1111_0001;
        radixVal = 4'b1111;
        eLED = 1'b0;
        unlock = 1'b0;
        counterReset = 1'b0;
    end
    else if(currentState==STATE_2WRONG || currentState==STATE_2CORRECT) //turn on 2 hyphens to signify entered digits
    begin
        dispVal = 16'b1111_1111_0001_0001;
        radixVal = 4'b1111;
        eLED = 1'b0;
        unlock = 1'b0;
        counterReset = 1'b0;
    end
    else if(currentState==STATE_3WRONG || currentState==STATE_3CORRECT) //turn on 3 hyphens to signify entered digits
    begin
        dispVal = 16'b1111_0001_0001_0001;
        radixVal = 4'b1111;
        eLED = 1'b0;
        unlock = 1'b0;
        counterReset = 1'b0;
    end
    else if(currentState==STATE_4WRONG || currentState==STATE_4CORRECT) //turn on 4 hyphens to signify entered digits
        begin
            dispVal = 16'b0001_0001_0001_0001;
            radixVal = 4'b1111;
            eLED = 1'b0;
            unlock = 1'b0;
            counterReset = 1'b0;
        end
    else if(currentState==STATE_WAIT_ERROR)
    begin
        dispVal = 16'b0101_0011_0110_0111; //tell user FAIL, turn on error LED
        radixVal = 4'b1111;
        eLED = 1'b1;
        unlock = 1'b0;
        counterReset = 1'b0;
    end
    else if(currentState==STATE_UNLOCKED)
    begin
        dispVal = 16'b0010_0011_0100_0100; //tell user PASS, send unlock signal
        radixVal = 4'b1111;
        eLED = 1'b0;
        unlock = 1'b1;
        counterReset = 1'b0;
    end
    else if(currentState==STATE_OPEN)
    begin
        dispVal = 16'b0000_0010_1001_1000; //tell user OPEN, but turn off unlock signal.
        radixVal = 4'b1111;
        eLED = 1'b0;
        unlock = 1'b0;
        counterReset = 1'b0;
    end
    else
    begin
        dispVal = 16'b1111_1111_1111_1111; //same behaviour here as in idle
        radixVal = 4'b0000;
        eLED = 1'b0;
        unlock = 1'b0;
        counterReset = 1'b0;
    end
end
always @ (unlock, eLED)
begin
    if(eLED == 1'b1 || unlock == 1'b1)
       begin
       enable = 1'b1;
       end
    else
      begin
      enable = 1'b0;
      end
end
//  Instantiation of pulse generator.
    pulseGenerator delay5sec1 (.clock(clock),       // 5 MHz clock signal
                              .run(enable),         // controls operation of the stopwatch
                              .reset(reset),      // reset signal, active high
                              .pulse(continu),     // output pulse
                              .counterReset(counterReset)
                              );
endmodule
