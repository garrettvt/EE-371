//Garrett Tashiro
//November 3, 2021
//EE 371
//Lab 3, Task 2


//DE1_SoC module is the top level module for Lab 3, Task 2. This module implements
//a line being drawn, and shifted across a VGA screen. The module uses hierarchical
//calls to clock_divider, VGA_framebuffer, line_drawer, and clr_scr. The DE1_SoC 
//module only takes one input from SW[0], and taht is connected to reset. Upon startup,
//the system will start by drawing a white line on the left hand side of the VGA display
//and after some clock cycles the white line is drawn over with a black one, and the
//line is shifted to the right by one pixel. The line will go off the far right side and
//come back to the left side and continue the process of shifting a line acoss the VGA 
//display. Upon reset, clr_scr's values for x and y are used, along with its color. The 
//modle will start in the top left corner of the screen and go pixel by pixel changing
//the color to black and clearing the screen. 
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	//Added logic xl, and xc to hold outputs from 
	//line_drawer and clr_scr
	logic [9:0] x0, x1, x, xl, xc;
	
	//Added logic yl, and yc to hold outputs from 
	//line_drawer and clr_scr
	logic [8:0] y0, y1, y, yl, yc;
	logic frame_start;
	
	//added logic c_color, l_color, and finished
	//to take outputs from line_drawer and clr_scr
	logic pixel_color, c_color, l_color, finished;
	
	//Logic reset to hold a the value from SW[0]
	//to be the reset for the system. 
	logic reset;
	assign reset = SW[0];
	
	//32-bit logic to hold output from clock_divider
	logic [31:0] div_clk;
	
	//clock_divider has 1-bit CLOCK_50, and reset as inputs and returns 1-bit
	//div_clk as an output.This module divides the clock to lower the frequency
	//of CLOCK_50
	clock_divider oneSec(.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk)); 
	
	//1-bit logic clk for the clock on board or during simulation
	logic clk;
	assign clk = CLOCK_50;		// for simulation 
	//assign clk = div_clk[9];  // for board 
	
	//////// DOUBLE_FRAME_BUFFER ////////
	logic dfb_en;
	assign dfb_en = 1'b0;
	/////////////////////////////////////
	
	//VGA_framebuffer is given to us
	VGA_framebuffer fb(.clk(CLOCK_50), .rst(1'b0), .x, .y,
				.pixel_color, .pixel_write(1'b1), .dfb_en, .frame_start,
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_N, .VGA_SYNC_N);
	
	//line_drawer will draw a line between (x0, y0) and (x1, y1). 
	//The white line will stay on the screen for 1500 clock cycles
	//before drawing a black line over the white one, and then 
	//the a variable shift will increase and new, shifted x0 and x1 
	//values are used to shift the line across the screen.
	line_drawer lines (.clk(clk), .reset(reset), .fin(finished),
				.x0, .y0, .x1, .y1, .x(xl), .y(yl), .black(l_color));
   
	//clr_scr clear takes 1-bit CLOCK_50, and reset as inputs and returns 
	//10-bit xc, 9-bit yc, 1-bit c_color, and done as outputs. The output
	//xc is used for assigning x conditionally, yc is used for assigning 
	//y conditionally, c_color is used for assigning pixel_color conditionally
	//and finished is used as the condition in which the assignments are 
	//based upon.
	clr_scr clear(.clk(CLOCK_50), .reset(reset), .x(xc), .y(yc), .color(c_color), .done(finished));
	
	//Conditional operator to assign x. If 1-bit finished being
	//passed from clr_scr is true, then the x value output from
	//line_drawer will be used. If finished is false, the x value
	//output from clr_scr will be used.
	assign x = (finished) ? xl : xc;

	//Conditional operator to assign y. If 1-bit finished being
	//passed from clr_scr is true, then the y value output from
	//line_drawer will be used. If finished is false, the y value
	//output from clr_scr will be used.
	assign y = (finished) ? yl : yc;
	
	//Conditional operator to assign pixel_color. If 1-bit finished
	//is true, then use the 1-bit l_color from output black in 
	//line_drawer. If it is false, use 1-bit c_coloc from output
	//color of clr_scr.
	assign pixel_color = (finished) ? l_color : c_color;
	
	// draw an arbitrary line
	assign x0 = 0;
	assign y0 = 100;
	assign x1 = 0;
	assign y1 = 340;
endmodule

//DE1_SoC_testbench tests for expected and unexpected behavior. DE1_SoC
//only uses SW[0] as an input to control the system. SW[0] is linked 
//to reset. The test first starts by setting SW[0] high for a cycle,
//then low for 150 cycles. The values in clr_scr were lowered to a max
//x value of 6 and a max y vlue of 4. The line being tested upon is
//x0 = 0, y0 = 0, x1 = 0, and y1 = 10. The line_drawer module pasues for 10 
//cycles for these tests as well. The test is ran twice to insure
//that the system could reset after drawing lines. These values were used to create 
//a smaller testbench to view the behavior of the DE1_SoC and all the 
//other modules working together correctly.
module DE1_SoC_testbench();
		logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		logic [9:0] LEDR;
		logic [3:0] KEY;
		logic [9:0] SW;

		logic CLOCK_50;
		logic [7:0] VGA_R;
		logic [7:0] VGA_G;
		logic [7:0] VGA_B;
		logic VGA_BLANK_N;
		logic VGA_CLK;
		logic VGA_HS;
		logic VGA_SYNC_N;
		logic VGA_VS;
		
		DE1_SoC dut(.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .CLOCK_50, 
					.VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
						
		parameter CLOCK_PERIOD=100;
		initial begin
			CLOCK_50 <= 0;
			forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
		end
		
		initial begin
			SW[0] <= 1;			repeat(1)   @(posedge    CLOCK_50);
			SW[0] <= 0;			repeat(150)   @(posedge    CLOCK_50);
			SW[0] <= 1;			repeat(1)   @(posedge    CLOCK_50);
			SW[0] <= 0;			repeat(150)   @(posedge    CLOCK_50);
			$stop; // End the simulation.
		end
endmodule 