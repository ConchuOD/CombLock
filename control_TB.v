`timescale 1ns / 1ps
module TB_control;
	// Inputs to module being verified
	reg clock, reset, newKey, switch;
	reg [4:0] keyCode;
	// Outputs from module being verified
	wire eLED, unlock;
	wire [3:0] radixVal;
	wire [15:0] dispVal;
	// Instantiate module
	control uut (
		.clock(clock),
		.reset(reset),
		.newKey(newKey),
		.keyCode(keyCode),
		.switch(switch),
		.eLED(eLED),
		.unlock(unlock),
		.radixVal(radixVal),
		.dispVal(dispVal)
		);
		localparam NUMTEST = 4;
		integer error_count, test;
		reg [4:0] testWWWW [0:3] = {5'b10100, 5'b10101, 5'b10110, 5'b10000};
		reg [4:0] testCWWW [0:3] = {5'b10000, 5'b10101, 5'b10110, 5'b10000};
		reg [4:0] testCCCC [0:3] = {5'b10001, 5'b10000, 5'b10001, 5'b10000};
	// Generate clock signal
	initial
		begin
			clock  = 1'b1;
			forever
				#100 clock  = ~clock;
		end
    // This is a non exhaustive test, to make sure there was basic functionality before more thorough testing //
    //****pulse gen shortened to 5 clock cycle delay for this test ****//
	initial
        begin
            error_count = 0; // initialisation
            reset = 1'b0;
            newKey = 1'b0;
            switch = 1'b1;
            #150
            reset = 1'b1;
            @ (negedge clock)
            reset = 1'b0;
            #50
            // testing 4 wrong inputs
            for(test = 0; test<NUMTEST; test = test + 1)
                begin
                    keyCode = testWWWW[test];
                    newKey = 1'b1;
                    #100
                    newKey = 1'b0;
                    #100
                    keyCode = 5'b00000;
                end
            if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'b0001_0001_0001_0001)
                begin
                    $display("Error in 4xWrong input, not waiting for enter. eLED (0) = %b unlock (0) = %b dispVal (1111) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #100
            keyCode = 5'b00100; //press enter
            #100
            newKey = 1'b1;
            #100
            newKey = 1'b0;
            #100
            //check for error message
            if(eLED != 1'b1 || unlock != 1'b0 || dispVal != 16'h5367)
                begin
                    $display("Error in 4xWrong input, not error. eLED (1) = %b unlock (0) = %b dispVal (5367) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #1000
            //wait then check for idling
            if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'hffff)
                begin
                    $display("Error in 4xWrong input, not idle. eLED (0) = %b unlock (0) = %b dispVal (ffff) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
                #1
            //testing 2 in a row with a reset (testing soft reset of pulse generators)
            for(test = 0; test<NUMTEST; test = test + 1)
                begin
                    keyCode = testWWWW[test];
                    newKey = 1'b1;
                    #100
                    newKey = 1'b0;
                    #100
                    keyCode = 5'b00000;
                end
            if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'b0001_0001_0001_0001)
                begin
                    $display("Error in 4xWrong input, not waiting for enter. eLED (0) = %b unlock (0) = %b dispVal (1111) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #100
            keyCode = 5'b00100;//enter
            #100
            newKey = 1'b1;
            #100
            newKey = 1'b0;
            #100
            //check for error
            if(eLED != 1'b1 || unlock != 1'b0 || dispVal != 16'h5367)
                begin
                    $display("Error in 4xWrong input, not error. eLED (1) = %b unlock (0) = %b dispVal (5367) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #1000
            //check for return to idle
            if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'hffff)
                begin
                    $display("Error in 4xWrong input, not idle. eLED (0) = %b unlock (0) = %b dispVal (ffff) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #1
            // testing clear functionality
            for(test = 0; test<NUMTEST; test = test + 1)
                begin
                    keyCode = testWWWW[test];
                    newKey = 1'b1;
                    #100
                    newKey = 1'b0;
                    #100
                    keyCode = 5'b00000;
                end
            if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'b0001_0001_0001_0001)
                begin
                    $display("Error in 4xWrong input, not waiting for enter. eLED (0) = %b unlock (0) = %b dispVal (1111) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #100
            keyCode = 5'b01100; //clear
            #100
            newKey = 1'b1;
            #100
            newKey = 1'b0;
            #100
            //check for return to idle
            if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'hffff)
                begin
                    $display("Error in 4xWrong input, not idle. eLED (0) = %b unlock (0) = %b dispVal (ffff) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
            #1
            reset = 1'b0;
            newKey = 1'b0;
            switch = 1'b1;
            #150
            reset = 1'b1;
            @ (negedge clock)
            reset = 1'b0;
            #50
            //testing 1 right into 3 wrong
            for(test = 0; test<NUMTEST; test = test + 1)
                begin
                    keyCode = testCWWW[test];
                    newKey = 1'b1;
                    #100
                    newKey = 1'b0;
                    #100
                    keyCode = 5'b00000;
                end
             if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'b0001_0001_0001_0001)
                begin
                    $display("Error in 1xCorrect3xWrong, not waiting for enter. eLED (0) = %b unlock (0) = %b dispVal (1111) = %h", eLED, unlock, dispVal);
                    error_count = error_count+1;
                end
             #100
             keyCode = 5'b00100;//enter
             #100
             newKey = 1'b1;
             #100
             newKey = 1'b0;
             #100
             //check for locked once more
             if(eLED != 1'b1 || unlock != 1'b0 || dispVal != 16'b0101_0011_0110_0111)
                    begin
                        $display("Error in 1xCorrect3xWrong, not locked. eLED (1) = %b unlock (0) = %b dispVal (5367) = %h", eLED, unlock, dispVal);
                        error_count = error_count+1;
                    end
              #1000
              //and another return to standby
              if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'hffff)
                  begin
                      $display("Error in 1xCorrect3xWrong input, not idle. eLED (0) = %b unlock (0) = %b dispVal (ffff) = %h", eLED, unlock, dispVal);
                      error_count = error_count+1;
                  end
             reset = 1'b0;
             newKey = 1'b0;
             switch = 1'b1;
             #150
             reset = 1'b1;
             @ (negedge clock)
             reset = 1'b0;
             #50
             //testing right code no door open
             for(test = 0; test<NUMTEST; test = test + 1)
                 begin
                     keyCode = testCCCC[test];
                     newKey = 1'b1;
                     #100
                     newKey = 1'b0;
                     #100
                     keyCode = 5'b00000;
                  end 
              if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'b0001_0001_0001_0001)
                      begin
                          $display("Error in 4xCorrect input, not waiting for enter. eLED (0) = %b unlock (0) = %b dispVal (1111) = %h", eLED, unlock, dispVal);
                          error_count = error_count+1;
                      end 
             #100
             keyCode = 5'b00100;//enter
             #100
             newKey = 1'b1;
             #100
             newKey = 1'b0;
             #100
             //correct code, should be open
              if(eLED != 1'b0 || unlock != 1'b1 || dispVal != 16'b0010_0011_0100_0100)
                  begin
                     $display("Error in 4xCorrect input, not unlocked. eLED (0) = %b unlock (1) = %b dispVal (2344) = %h", eLED, unlock, dispVal);
                     error_count = error_count+1;
                  end  
              #1000
              //door not opened, should relock automagically 
              if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'hffff)
                  begin
                      $display("Error in 4xCorrect input, not idle. eLED (0) = %b unlock (0) = %b dispVal (ffff) = %h", eLED, unlock, dispVal);
                      error_count = error_count+1;
                  end 
              #100
              reset = 1'b0;
              newKey = 1'b0;
              switch = 1'b1;
              #150
              reset = 1'b1;
              @ (negedge clock)
              reset = 1'b0;
              #50
              //testing door open and correct code
              for(test = 0; test<NUMTEST; test = test + 1)
                  begin
                      keyCode = testCCCC[test];
                      newKey = 1'b1;
                      #100
                      newKey = 1'b0;
                      #100
                      keyCode = 5'b00000;
                   end 
              if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'b0001_0001_0001_0001)
                  begin
                      $display("Error in 4xCorrect input, not waiting for enter. eLED (0) = %b unlock (0) = %b dispVal (1111) = %h", eLED, unlock, dispVal);
                      error_count = error_count+1;
                  end 
              #100
              keyCode = 5'b00100;//enter
              #100
              newKey = 1'b1;
              #100
              newKey = 1'b0;
              #100
              //once more, should be unlocked
              if(eLED != 1'b0 || unlock != 1'b1 || dispVal != 16'b0010_0011_0100_0100)
                  begin
                      $display("Error in 4xCorrect input, not unlocked. eLED (0) = %b unlock (1) = %b dispVal (2344) = %h", eLED, unlock, dispVal);
                      error_count = error_count+1;
                  end  
               #100
               switch = 1'b0;
               #1000
               //door is open, but 5 seconds have elapsed testing for no unlocked signal but OPEN on display
               if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'h0298)
                  begin
                      $display("Error in 4xCorrect input, door not open. eLED (0) = %b unlock (0) = %b dispVal (2344) = %h", eLED, unlock, dispVal);
                      error_count = error_count+1;
                  end
               #500
               switch = 1'b1;
               #100
               //door has been closed, so should return to idle
               if(eLED != 1'b0 || unlock != 1'b0 || dispVal != 16'hffff)
                   begin
                       $display("Error in 4xCorrect input, not idle. eLED (0) = %b unlock (0) = %b dispVal (ffff) = %h", eLED, unlock, dispVal);
                       error_count = error_count+1;
                   end                                         
            $stop;
        end
        //if(error_count == 0)
             //begin
             //$display("Test terminated with 0 errors");
             //end
endmodule
