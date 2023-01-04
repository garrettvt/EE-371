//Garrett Tashiro
//November 15, 2021
//EE 371
//Lab 4, Task 1


//DE1_SoC is the top level module for Lab 4, Task 1. This module implements 
//a bit counter to count the number of 1's in data that is passed to it with
//switches. The module uses hierarchical calls to paramDFF, bitCounter, 
//datapath_BD, and hex_display. The DE1_SoC module takes inputs from SW[7:0],
//SW[9], and KEY[0]. The module will take in an 8-bit piece of data using 
//SW[7:0], and if SW[9] is equal to one, then the system will count the number
//of bits int the 8-bits passed from the input that are 1. Once the system has
//finished counting all the bits, LEDR[9] will light up saying that the system 
//is done and the number of ones that were counted will display on HEX0.
module DE1_SoC(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50);
	input logic 		CLOCK_50;
	input logic [3:0]	KEY;
	input logic [9:0]	SW;
	output logic [6:0]	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]	LEDR;

	//Assign HEX1-HEX5 to be blank
	assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;

	//Create 1-bit logic for reset, start, clk,
	//load_b, result_shift, done, and z. Then
	//create 8-bit logic for data and 4-bit logic
	//for result.
	logic reset, start, clk;
	logic load_b, result_shift, done, z;
	logic [7:0] data;
	logic [3:0] result;

	//Assign clk to CLOCK_50
	//and LEDR[9] to the value of done.
	assign clk = CLOCK_50;
	assign LEDR[9] = done; 

	//paramDFF reset_dff is a parameterized module that has its 
	//parameter value set to 1. The module has 1-bit clk, 0 as reset, 
	//and KEY[0] as inputs and returns 1-bit reset as an output. This
	//module is two DFFs in series and prevents metastability. The 
	//output value from this module is passed as an input to bitCounter,
	//and datapath_BC.
	paramDFF #(.itsy(1)) reset_dff(.clk(clk), .reset(1'b0), .press(~KEY[0]), .out(reset));

	//paramDFF start_signal is a parameterized module that has its 
	//parameter value set to 1. The module has 1-bit clk, 0 as reset, 
	//and SW[9] as inputs and returns 1-bit start as an output. This
	//module is two DFFs in series and prevents metastability. The 
	//output value from this module is passed as an input to bitCounter.
	paramDFF #(.itsy(1)) start_signal(.clk(clk), .reset(1'b0), .press(SW[9]), .out(start));

	//paramDFF input_data is a parameterized module that has its 
	//parameter value set to 8. The module has 1-bit clk, 0 as reset, 
	//and SW[7:0] as inputs and returns 8-bit data as an output. This
	//module is two DFFs in series and prevents metastability. The 
	//output value from this module is passed as an input to bitCounter.
	paramDFF #(.itsy(8)) input_data(.clk(clk), .reset(1'b0), .press(SW[7:0]), .out(data));

	//bitCounter control has 1-bit clk, reset, start, and z as inputs
	//and returns 1-bit result_shift, load_b, and done as outputs.
	//This module is the control logic for the bit counter for this system,
	//and has teh FSM inside of it. The outputs from bitCounter are passed to
	//datapath_BC as inputs. 
	bitCounter control(.clk(clk), .reset(reset), .z, .start(start), .result_shift, .load_b, .done);

	//datapath_BC datapath has 1-bit clk, reset, result_shift, load_b, done,
	//and 8-bit data as inputs and returns 1-bit z, and 4-bit results as outputs.
	//This module is teh datapath logic for the bit counter. This module does the
	//shifting of the bits, checks if a bit is 1 or 0 in the data that was passed,
	//and updates the count accordingly. Once the all the data that was passed is 
	//now 0's, z is set to 1, result is equal to the count. 
	datapath_BC #(.width(8)) datapath(.clk(clk), .reset(reset), .A(data), .load_b, .result_shift, .done, .z, .result(result));

	//hex_display hexy has 4-bit result as and inputs and returns 7-bit value
	//to HEX0. This module takes teh number of 1's counted in the data being
	//input and then displays it to HEX0. 
	hex_display hexy(.dataIn(result), .led0(HEX0));

endmodule 

//DE1_SoC_testbench tests for expected, unexpected, and edgecase behavior.
//This testbench first sets the input data to a value, and sets start (SW[9])
//to 0. The system is reset by setting KEY[0] low for a clock cycle, then high.
//start is then set high for 10 clock cycles to check if the system counts the
//number of 1's in the data being passed in. After that, start is set low for 5
//cycles to see if the values would update properly and the states would transition
//properly as well. Start is then set high for 11 clock cycles to see if values 
//and states update properly again. With start still at 1, reset is set high then
//low. The value for data coming in is changed. Start is then set low for two clock
//cycles and then high again. This is done so it would cause state tranistions. While
//the number of 1's are beign counted the data input is changed to see if that affects
//the current procces. Start is et low for 8 clock cycles and then high for 15 to check
//for proper state transitions and values updating. 
module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	DE1_SoC dut(.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .CLOCK_50);

	parameter CLOCK_PERIOD=100;
	initial begin
	   CLOCK_50 <= 0;
	   forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end

	initial begin
	   SW[7:0] <= 8'b00110011;	repeat(1)   @(posedge    CLOCK_50);
	   SW[9] <= 0; 			repeat(1)   @(posedge    CLOCK_50);
	   KEY[0] <= 0;			repeat(1)   @(posedge    CLOCK_50);
	   KEY[0] <= 1;			repeat(1)   @(posedge    CLOCK_50);
	   SW[9] <= 1; 			repeat(10)   @(posedge    CLOCK_50);
	   SW[9] <= 0; 			repeat(5)   @(posedge    CLOCK_50);
	   SW[9] <= 1; 			repeat(11)   @(posedge    CLOCK_50);
	   KEY[0] <= 0;			repeat(1)   @(posedge    CLOCK_50);
	   KEY[0] <= 1;			repeat(15)   @(posedge    CLOCK_50);
	   SW[7:0] <= 8'b11111111;	repeat(4)   @(posedge    CLOCK_50);
	   SW[9] <= 0; 			repeat(2)   @(posedge    CLOCK_50);
	   SW[9] <= 1; 			repeat(1)   @(posedge    CLOCK_50);
	   SW[7:0] <= 8'b00011111;	repeat(1)   @(posedge    CLOCK_50);
	   SW[9] <= 1; 			repeat(15)   @(posedge    CLOCK_50);
	   SW[9] <= 0; 			repeat(8)   @(posedge    CLOCK_50);
	   SW[9] <= 1; 			repeat(15)   @(posedge    CLOCK_50);

	   $stop; // End the simulation.
	end
endmodule 
