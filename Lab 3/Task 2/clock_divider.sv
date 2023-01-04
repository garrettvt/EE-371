//Garrett Tashiro
//October 10, 2021
//EE 371
//Lab 3, Task 2.4

//clock_divider has 1-bit clock and 1-bit reset as inputs and returns
//divided_clocks as an output. This module allows you to change the
//clock rate of CLOCK_50 in order to be able to have HEX displays
//update roughly every second. This is a module written in 271.

// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...    
module clock_divider (clock, reset, divided_clocks);
         input  logic          reset, clock;     
		 output logic [31:0]   divided_clocks = 0;

		 always_ff @(posedge clock) begin
			divided_clocks <= divided_clocks + 1;				
		 end		
endmodule 

//clock_divider_testbench tests for expected and unexpected behavior.
//This testbench resets and just runs for 100 clock cycles
module clock_divider_testbench();
		logic 			reset, clock;
		logic [31:0]	divided_clocks;
		
		clock_divider dut(.clock, .reset, .divided_clocks);
		
		parameter clk_PERIOD = 100;            
		initial begin                
			  clock <= 0;
			  forever #(clk_PERIOD/2) clock <= ~clock;// Forever toggle the clk     
		end
		
		initial begin
			reset <= 1;		repeat(1)   @(posedge    clock);
			reset <= 0;		repeat(1)   @(posedge    clock);
							repeat(100)   @(posedge    clock);
			$stop; // End the simulation.
		end 
endmodule 
