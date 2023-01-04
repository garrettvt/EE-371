//Garrett Tashiro
//November 15, 2021
//EE 371
//Lab 4, Task 1


//datapath_BC is a parameterized module that has 1-bit clk,
//reset, load_b, result_shift, done, and 8-bit A (parameterized
//variable set to 8) as inputs and returns 1-bit z, and 4-bit 
//result as outputs. This module implements the datapath for a
//bit counter to count the number of 1's in a certain set of data
//being passed in. 
module datapath_BC #(parameter width = 8)(clk, reset, A, load_b, result_shift, done, z, result);
	input logic 		   clk, reset;
	input logic 		   load_b, result_shift, done;
	input logic [width - 1: 0] A;
	output logic 		   z;
	output logic [3:0]	   result; 

	//logic to hold value of A that is orignially
	//passed in so the data can be shifted to 
	//count the number of 1's in the data passed.
	//4-bit logic count to hold the count of number
	//of 1's that the data has. 
	logic [width - 1: 0] new_a;
	logic [3:0] count;

	//Assign output z to not or new_a
	assign z = ~|new_a; 

	//Assign result to be 0 if done is 0,
	//or for result to equal the count if
	//done is 1 using a conditional operator.
	assign result = (done) ? count : 4'd0;

	//This always_ff block has the logic for the 
	//datapath. If reset or load_b are 1, then 
	//count is set to 0 and new_a is set to the 
	//input data. Else if right_shift is 1, if
	//the data in the 0'th place of a is a 1 then
	//increase count by 1, and always shift new_a
	//to the right by 1.
	always_ff @(posedge clk) begin
		if(reset || load_b) begin
			count <= 0;
			new_a <= A;
		end

		else if(result_shift) begin
			if(new_a[0] == 1) begin
				count <= count + 4'd1;
			end
			new_a <= new_a >> 1;
		end
	end
endmodule 

//datapath_BC_testbench tests for expected, unexpected, and edgecase
//behavior. This testbench starts by setting A to a non_zero value, 
//then load_b, result_shift, and done to 0. Reset is set high then 
//low. right_shift is set high for 8 clock cycles, and then low for one
//cycle. The 8-bit input value of A is changed to a different non-zero 
//value, and load_b is set high for a clock cycle, then it is set low. 
//result_shift is set high for 8 clock cycles, then low for 1, and then 
//done is set high for a clock cycle then low again. This testbench was
//done to be sure value were updating correctly based upon the input 
//values being passed to the system, and that the output values were getting
//updated correctly after the input values were cahnged. 
module datapath_BC_testbench();
	logic clk, reset, load_b, result_shift, done, z;
	logic [7:0] A;
	logic [3:0] result;

	datapath_BC #(8) dut(.clk, .reset, .A, .load_b, .result_shift, .done, .z, .result);

	parameter clk_PERIOD = 100;            
	initial begin                
	      clk <= 0;
	      forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
	end

	initial begin
	   A <= 8'b01100111;	load_b <= 0; result_shift <= 0; done <= 0; repeat(1)   @(posedge    clk);
	   reset <= 1; 		repeat(1)   @(posedge    clk);
	   reset <= 0; 		repeat(1)   @(posedge    clk);
	   result_shift <= 1;	repeat(8)   @(posedge    clk);
	   result_shift <= 0;	repeat(1)   @(posedge    clk);
	   done <= 1;		repeat(1)   @(posedge    clk);
	   done <= 0;		repeat(1)   @(posedge    clk);
	   A <= 8'b11000011;	repeat(1)   @(posedge    clk);
	   load_b <= 1;		repeat(1)   @(posedge    clk);
	   load_b <= 0;		repeat(1)   @(posedge    clk);
	   result_shift <= 1;	repeat(8)   @(posedge    clk);
	   result_shift <= 0;	repeat(1)   @(posedge    clk);
	   done <= 1;		repeat(1)   @(posedge    clk);
	   done <= 0;		repeat(1)   @(posedge    clk);

	   $stop; // End the simulation.
	end
endmodule 
