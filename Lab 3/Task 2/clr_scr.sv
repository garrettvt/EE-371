//Garrett Tashiro
//November 2, 2021
//EE 371
//Lab 3, Task 2


//clr_scr has 1-bit clk, ans reset as inputs and 
//returns, 10-bit x, and 9-bit y, 1-bit color, 
//and done as outputs. Upon reset, 10-bit x,
//9-bit y, 1-bit color, and done are set to 0. On
//the next clock cycle y in incremented every clock
//cycle until it is 480. Once at 480 it is set to 0 
//and x is incremented. This process goes on until each
//pixel has been gone over to color them black. 
module clr_scr(clk, reset, x, y, color, done);
		input logic 			clk, reset;
		output logic [9:0] 	x;
		output logic [8:0] 	y;
		output logic 			color, done;
		
		//This always_ff block checks if reset is 0 or 1.
		//If it is 0 the 10-bit x, 9-bit y, 1-bit color, and
		//done are all set to 0. The following clock cycles 
		//x and y are incremented accordingly until x is 641.
		//At this point color and done are both set to 1.
		always_ff @(posedge clk) begin
			if(reset) begin
				x <= '0;
				y <= '0;
				color <= 1'b0;
				done <= 1'b0;
			end
			
			else begin
//				if(x < 641) begin
//					if(y < 480) begin
				if(x < 6) begin
					if(y < 4) begin
						y <= y + 1;
					end
					
					else begin
						x <= x + 1;
						y <= 0;
					end
				end
			
//				if(x >= 641) begin
				if(x >= 6) begin
					color <= 1'b1;
					done <= 1'b1;
				end
			end
		end
endmodule 

//clr_scr_testbench tests for expected and unexpected behavior.
//This test was done when in the always_ff x was capped at 6
//and y was capped at 4 just to have a similar test. The test
//sets reset high and then low. Reset stays low for 35 cycles 
//to have x increment to 6 and for y to increment repeatedly 
//from 0 to 4 until x hit its max and both color and done go high.
module clr_scr_testbench();
		logic 			clk, reset, color, done;
		logic [9:0] 	x;
		logic [8:0] 	y;
		
		clr_scr dut (.clk, .reset, .x, .y, .color, .done);
		
		parameter clk_PERIOD = 100;            
		initial begin                
				clk <= 0;
				forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
		end
		
		initial begin
			reset <= 1;	 		repeat(3)   @(posedge    clk);
			reset <= 0;	 		repeat(35)   @(posedge    clk);
			
			$stop; // End the simulation.
		end
endmodule 