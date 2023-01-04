//Garrett Tashiro
//October 18, 2021
//EE 371
//Lab 4, Task 1

//doubleD has 1-bit clk, reset, and press as inputs, and 
//returns 1-bit out. This is a parameterized module to be able 
//to change the number of bits being passed. This module is a double
//DFF (two in series) that takes the input signal from a switches, or 
//buttons to prevent metastability. 
module paramDFF #(parameter itsy = 1)(clk, reset, press, out);     
	input logic  					reset, clk;
	input logic [itsy - 1:0]	press;
	output logic [itsy - 1:0] 	out;	

	logic [itsy - 1:0] temp1;

	//always_ff replicates a double DFF. The input press goes into the 
	//first DFF and the output from the first DFF is the input for the 
	//second DFF. 
	always_ff @(posedge clk) begin    
		if (reset) begin
			temp1 <= '0;
			out 	<= '0;
		end

		else begin
			temp1 <= press;
			out 	<= temp1; 
	  end
	end 	
endmodule 

//paramDFF_testbench tests the behaivor of a parameterized double DFF
//module. The test first sets reset to high and then low. It then tests
//4 different values being passed through the DFF's in series. The updated
//output takes two clock cycles, so wait a few clock cycles at the end.
module paramDFF_testbench();
	logic 			reset, clk;
	logic [3:0]		press, out;

	paramDFF #(.itsy(4)) dut(.clk, .reset, .press, .out);

	parameter clk_PERIOD = 100;            
	initial begin                
	   clk <= 0;
	   forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
	end

	initial begin
		reset <= 1;				repeat(1)   @(posedge    clk);
		reset <= 0;	press <= 4'b1000;	repeat(1)   @(posedge    clk);
		press <= 4'b0011;			repeat(1)   @(posedge    clk);
		press <= 4'b1100;			repeat(1)   @(posedge    clk);
		press <= 4'b0100;			repeat(1)   @(posedge    clk);
							repeat(3)   @(posedge    clk);

		$stop; // End the simulation.
	end
endmodule 
