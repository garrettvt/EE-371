//Garrett Tashiro
//October 10, 2021
//EE 371
//Lab 1, Task 4

//doubleD has 1-bit clk, reset, and press as inputs, and 
//returns 1-bit out. This module is a double DFF (two in series)
//so the input signal from a switch, or button to prevent metastability. 
module doubleD(clk, reset, press, out);   
	output logic  out;   
	input  logic  press, reset, clk;   
	
	logic temp1;
	
	//always_ff replicates a double DFF. The 1-bit input press goes into the 
	//first DFF and the output from the first DFF is the input for the 
	//second DFF. 
	always_ff @(posedge clk) begin    
		if (reset) begin
					temp1 <= 0;
					out 	<= 0;
				end
		else begin
					temp1 <= press;
					out 	<= temp1; 
			  end
	end 
	
endmodule 

		