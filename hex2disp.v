//////////////////////////////////////////////////////////////////////////////////
// Company:      UCD School of Electrical and Electronic Engineering
// Engineer:      Brian Mulkeen (modified)
// Project:        Display Interface Design
// Target Device: XC7A100T-csg324 on Digilent Nexys-4 board
// Description:   Look-up table to map 4-bit input to 7-bit output,
//    to show value in hexadecimal on 7-segment display, segment signals active low.
//   Segment naming as shown below.  Segment pattern output in order ABCDEFG
//          --- A ---
//         |           |
//         F          B
//         |           |
//          --- G ---
//         |           |
//         E          C
//         |           |
//          --- D ---
//
// Revision 0 - File Created, 29 September 2014
// Revision 1 - Comments modified, 12 October 2015
// Revision 2 - Daniel Groos, 23 November 2016
//////////////////////////////////////////////////////////////////////////////////

module hex2disp (
   input [3:0] number,      // 4-bit number
   output reg [6:0] pattern );      // 7-segment pattern - ABCDEFG
   
// look-up table to convert 4-bit value to 7-segment pattern (0 = on)
   always @ (number)
      case(number)
         //TODO: delete commented out code
         4'h0:  pattern = 7'b0000001;  // display 0 - all segments on except G
         4'h1:  pattern = 7'b1111110;  // display hyphen - only segments G on
         4'h2:  pattern = 7'b0011000;  // display P
         4'h3:  pattern = 7'b0001000;  // display A
         4'h4:  pattern = 7'b0100100;  // display S
         4'h5:  pattern = 7'b0111000;  // display F
         4'h6:  pattern = 7'b1111001;  // display I
         4'h7:  pattern = 7'b1110001;  // display L
         4'h8:  pattern = 7'b0001001;  // display N
         4'h9:  pattern = 7'b0110000;  // display E
	     default: pattern = 7'b1111111; // all segments off
      endcase  // no need for default, as all possibilities covered

endmodule 
