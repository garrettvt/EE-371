//Garrett Tashiro
//October 7, 2021
//EE 371
//Lab 1, Task 2

//counter module takes 1-bit clk, reset, inc, and dec as inputs
//and returns 1-bit clear, full, and 4-bit ones and tens. This counter module
//is designed to count the number of cars coming and out of the 
//parking lot. If the lot has no cars, clear will be set to 1 and
//can't go below 0. If the max number is reached full will be set
//to 1 and no more cars can park. 
module counter #(parameter max = 5)(clk, reset, inc, dec, clear, full, ones, tens); 
		input logic				clk, reset, inc, dec;
		output logic			clear, full;
		output logic [3:0]	ones, tens;
		
		//integer total; 
		logic [4:0]	total;
		
		//This always_ff will count up if inc is 1, and count down if dec is 1. If the
		//total number of cars is at the max, the count will not increase. If the total
		//number of cars is at 0, the count will not decrease. Counting up and down will
		//update the 4-bit outputs ones and tens from 0-9. 
		always_ff @(posedge clk) begin
			if(reset) begin
				total <= '0; 			
				ones <= '0;
				tens <= '0;
			end
			
			else begin
				
				if(inc && (total != max)) begin
					total <= total + 1;
					
					if(ones == 4'd9) begin
						ones <= '0;
						tens <= tens + 1; 
					end
					
					else begin
						ones <= ones + 1;
					end
				end
				
				else if(dec && (total != 0)) begin
					total <= total - 1;
					
					if(ones == 4'd0) begin
						ones <= 4'd9;
						tens <= tens - 1;
					end
					
					else begin
						ones <= ones - 1;
					end
				end
				
				else begin
					total <= total;
				end
			end
		end
		
		assign clear = (total == 0);
		assign full = (total == max);
endmodule 

//counter_testbench tests for expected, unexpected, and edgecase behavior of the counter.
//The testbench is tests to make sure the counter can count up and down, doesn't decrease
//below 0, or increase above the max (which for this test was 11).
module counter_testbench();
		logic			clk, reset, inc, dec, clear, full;
		logic [3:0]	ones, tens;
		
		counter dut(.clk, .reset, .inc, .dec, .clear, .full, .ones, .tens);
		
		parameter CLOCK_PERIOD = 100;            
		initial begin                
				clk <= 0;
				forever #(CLOCK_PERIOD/2) clk <= ~clk;// Forever toggle the clock     
		end
		
		initial 		begin
			inc <= 0; dec <= 0;	repeat(1)    @(posedge    clk); //This is just to test a max of 11 
			reset <= 1;		  repeat(1)    @(posedge    clk);
			reset <= 0; 	  repeat(1)    @(posedge    clk);
			inc <= 1;		  repeat(1)    @(posedge    clk);
			inc <= 0;		  repeat(1)    @(posedge    clk);
			dec <= 1;		  repeat(1)    @(posedge    clk);
			dec <= 1;		  repeat(1)    @(posedge    clk);
			dec <= 1;		  repeat(1)    @(posedge    clk);
			dec <= 0;		  repeat(1)    @(posedge    clk);
			inc <= 1;		  repeat(13)   @(posedge    clk);
			inc <= 0;		  repeat(2)    @(posedge    clk);
			
			$stop; // End the simulation.
		end
endmodule 