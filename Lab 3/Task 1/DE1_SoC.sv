//Garrett Tashiro
//October 30, 2021
//EE 371
//Lab 3, Task 1

//DE1_SoC is the top level module for Lab 3, Task 1. This module implements
//Bresenham's line drawing algorith to draw a line on a VGA display. DE1_SoC
//uses hierarchical calls to VGA_framebuffer, and line_drawer. This module 
//doesn't use any physical inputs from the DE1_SoC board, but has values set 
//inside the module for x0, x1, y0, and y1 which are passed to line_drawer
//and line_drawer returns 10-bit x and 9-bit y to VGA_framebuffer as inputs
//to draw the white line across the VGA display. 
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
	
	logic [9:0] x0, x1, x;
	logic [8:0] y0, y1, y;
	logic frame_start;
	logic pixel_color;
	
	
	//////// DOUBLE_FRAME_BUFFER ////////
	logic dfb_en;
	assign dfb_en = 1'b0;
	/////////////////////////////////////
	
	VGA_framebuffer fb(.clk(CLOCK_50), .rst(1'b0), .x, .y,
			   .pixel_color, .pixel_write(1'b1), .dfb_en, .frame_start,
			   .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
			   .VGA_BLANK_N, .VGA_SYNC_N);
	
	// draw lines between (x0, y0) and (x1, y1)
	//line_drawer will draw a line between the two
	//corrdinates
	line_drawer lines (.clk(CLOCK_50), .reset(1'b0),
			   .x0, .y0, .x1, .y1, .x, .y);
	
	// draw an arbitrary line
	assign x0 = 0;
	assign y0 = 0;
	assign x1 = 10;
	assign y1 = 20;
	assign pixel_color = 1'b1;
	
endmodule

//DE1_SoC_testbench tests for expected and unexpected behavior. 
//This testbench just runs the clock for 50 cycles, while the 
//values for x0, x1, y0, and y1 inside the DE1_SoC module were
//set to 0, 0, 10, and 20, respecfully. This testbench checked
//for proper updates to 10-bit value x, and 9-bit value y. This
//was done to be able to easily see the values updating properly.
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
								repeat(50)   @(posedge    CLOCK_50);
		$stop; // End the simulation.
	end
endmodule 
