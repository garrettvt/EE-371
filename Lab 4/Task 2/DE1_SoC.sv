//Garrett Tashiro
//November 15, 2021
//EE 371
//Lab 4, Task 2

//DE1_SoC is the top level module for Lab 4, Task 2. This module 
//implements a binary search algorithm on a ram module that is 
//32x8 to search for data inside the module. This module uses 
//hierarchical calls to paramDFF, binarysearch_Control, ram32x8,
//binarysearch_Datapath, and hex_display. The DE1 takes data input
//from SW[7:0] and checks the ram for that value. KEY[0] controls 
//reset, and SW[9] is the switch for the start signal. If the data
//is found inside the ram, then LEDR[9] will light up and the address
//for the data will display on HEX0 and HEX1. If the data is not 
//found then LEDR[8] will light up, and HEX0 and HEX1 will be blank.
module DE1_SoC(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50);
		input logic 			CLOCK_50;
		input logic [3:0]		KEY;
		input logic [9:0]		SW;
		output logic [6:0]	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		output logic [9:0]	LEDR;
		
		//Set HEX2-HEX5 to be blank
		assign HEX2 = 7'b1111111;
		assign HEX3 = 7'b1111111;
		assign HEX4 = 7'b1111111;
		assign HEX5 = 7'b1111111;
		
		//logic for reset, start, clk, 
		//loads, lt, gt, found, not_found,
		//data, target, front, mid, last,
		//and result.
		logic reset, start, clk;
		logic loads, lt, gt;
		logic found, not_found;
		logic [7:0] data, target;
		logic [4:0] front, mid, last, result;
		
		//Assign clk to CLOCK_50,
		//LEDR[9] to the value of found
		//LEDR[8] to the value of not_found
		assign clk = CLOCK_50;
		assign LEDR[9] = found; 
		assign LEDR[8] = not_found;
		
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
		//output value from this module is passed as an input to 
		//binarysearch_Control.
		paramDFF #(.itsy(1)) start_signal(.clk(clk), .reset(1'b0), .press(SW[9]), .out(start));
		
		//paramDFF input_data is a parameterized module that has its 
		//parameter value set to 8. The module has 1-bit clk, 0 as reset, 
		//and SW[7:0] as inputs and returns 8-bit data as an output. This
		//module is two DFFs in series and prevents metastability. The 
		//output value from this module is passed as an input to 
		//binarysearch_Control.
		paramDFF #(.itsy(8)) input_data(.clk(clk), .reset(1'b0), .press(SW[7:0]), .out(data));
		
		//binarysearch_Control control has 1-bit clk, reset, start, 8-bit data,
		//5-bit front, and last as inputs and returns 1-bit loads, found,  
		//not_found, lt, and gt as outputs. The 1-bit ouputs loads, lt, and gt
		//are passed to binarysearch_Datapath. The 1-bit output found is passed
		//to hex_display as an input, and the output not_found is the value LEDR[8]
		//is assigned to. This module is the control for the system and has the FSM. 
		binarysearch_Control #(.w(8)) control(.clk(clk), .reset(reset), .start(start), 
														  .A(data), .front(front), .last(last), 
														  .target(target), .loads(loads), .found(found), 
														  .not_found(not_found), .lt(lt), .gt(gt));
		
		//ram32x8 has 1-bit ~clk, 8'd0 for data, 5-bit mid, 5'd0 for wraddress, and
		//1'b0 for wren as inputs returns 8-bit target as an output. This module implements
		//a 32x8 RAM. Three inputs are zeroed out since we only want to read from mid 
		//addresses data and return it to target. target is passed to binarysearch_Control
		//as an input.
		ram32x8 sortedRAM(.clock(~clk), .data(8'd0), .rdaddress(mid), 
								.wraddress(5'd0), .wren(1'b0), .q(target));
		
		//binarysearch_Datapath has 1-bit clk, reset, loads, lt, and gt as inputs
		//and returns 5-bit front, mid, last, and addr as outputs. This module is
		//the datapath for the binary search algorithm. 5-bit outputs front, and last 
		//are passed to binarysearch_Control as inputs. 5-bit output mid is passed to 
		//both binarysearch_Control and ram32x8 as an input. 5-bit output addr is passed
		//to hex_display as an input. 
		binarysearch_Datapath datapath(.clk(clk), .reset(reset), .loads(loads), 
												 .lt(lt), .gt(gt), .front(front), 
												 .mid(mid), .last(last), .addr(result));
		
		//hex_display has 5-bit result, and 1-bit found as inputs and return
		//7-bit outputs to HEX0 and HEX1. This module takes the addr that mid is set
		//to, and will display the address onto HEX1 and HEX0 only if found is equal
		//to 1. Otherwise both displays will be blank. 
		hex_display hexy(.dataIn(result), .found(found), .led0(HEX0), .led1(HEX1));
		
endmodule 

`timescale 1 ps / 1 ps

//DE1_SoC_testbench tests for expected, unexpected, and edgecase behavior.
//The testbench first starts by setting SW7-0 to a value in the RAM. Sw9 
//is set to 0. KEY0 is set low then high to reset the system and this high
//value is then held for 14 clock cycles to see if state transitions will
//happen prior to having SW9 be high. SW9 is then set high for 18 clock 
//cycles. Sw9 is then set low. SW7-0 is set to a value not in RAM. SW9 is
//set high for 20 clock cycles, then low. SW9 is set high for 20 cycles and
//then low for a second time to see if the systems FSM will transition correctly.
//SW7-0 is then set to something in the RAM again. KEY0 is set low then high 
//for 14 cycles to see if the system will reset correctly without a state 
//transition. Finally, SW9 is set high for 20 clock cycles then low. 
module DE1_SoC_testbench();
		logic CLOCK_50;
		logic [3:0]	KEY;
		logic [9:0]	SW;
		logic [6:0]	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		
		DE1_SoC dut(.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .CLOCK_50);
						
		parameter CLOCK_PERIOD=100;
		initial begin
			CLOCK_50 <= 0;
			forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
		end
		
		initial begin
			SW[7:0] <= 8'b00001100;		repeat(2)   @(posedge    CLOCK_50);
			SW[9] <= 0; 					repeat(2)   @(posedge    CLOCK_50);  //start = 0
			KEY[0] <= 0;					repeat(2)   @(posedge    CLOCK_50);  //reset
			KEY[0] <= 1;					repeat(14)  @(posedge    CLOCK_50);
			SW[9] <= 1; 					repeat(18)  @(posedge    CLOCK_50); //start = 1
			SW[9] <= 0; 					repeat(2)   @(posedge    CLOCK_50);
			SW[7:0] <= 8'b11111111;		repeat(2)   @(posedge    CLOCK_50);
			SW[9] <= 1; 					repeat(20)  @(posedge    CLOCK_50);
			SW[9] <= 0; 					repeat(2)   @(posedge    CLOCK_50);
			SW[9] <= 1; 					repeat(20)  @(posedge    CLOCK_50);
			SW[9] <= 0; 					repeat(2)   @(posedge    CLOCK_50);
			
			SW[7:0] <= 8'b00000000;		repeat(2)   @(posedge    CLOCK_50);
			KEY[0] <= 0;					repeat(2)   @(posedge    CLOCK_50);  //reset
			KEY[0] <= 1;					repeat(14)  @(posedge    CLOCK_50);
			
			SW[9] <= 1; 					repeat(20)  @(posedge    CLOCK_50);
			SW[9] <= 0; 					repeat(2)   @(posedge    CLOCK_50);
			
			$stop; // End the simulation.
		end
endmodule 
