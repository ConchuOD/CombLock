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
	// Generate clock signal
	initial
		begin
			clock  = 1'b1;
			forever
				#100 clock  = ~clock ;
		end
	// Generate other input signals
	initial
		begin
			reset = 1'b0;
			newKey = 1'b0;
			keyCode = 5'b0;
			switch = 1'b1;
			#50
			reset = 1'b1;
			#200
			reset = 1'b0;
			keyCode = 5'b10001;
			#900
			newKey = 1'b1;
			#100
			newKey = 1'b0;
			#10
			keyCode = 5'b10001;
			#290
			newKey = 1'b1;
            #100
            newKey = 1'b0;
            #300
            newKey = 1'b1;
            #100
            newKey = 1'b0;
            #300
            newKey = 1'b1;
            #10
            keyCode = 5'b10011;
            #90
            newKey = 1'b0;
            #300
            switch = 1'b0;
            #300
            #300
            switch = 1'b1;
            #3000
			$stop;
		end
endmodule
