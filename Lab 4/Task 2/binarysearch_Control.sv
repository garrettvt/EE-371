//Garrett Tashiro
//November 17, 2021
//EE 371
//Lab 4, Task 2

//binarysearch_Control is a parameterized module that has
//1-bit clk, reset, start, 8-bit A, target, 5-bit front, 
//and last as inputs and returns 1-bit loads, found, 
//not_found, lt, gt as outputs. This module implements the
//control for binary search algorithm. The module has the 
//FSM that sets flags depending on the input values, and 
//determines if data that is wanted is in the RAM or not. 
module binarysearch_Control #(parameter w = 8)(clk, reset, start, A, front, last, 
															  target, loads, found, not_found, lt, gt);
		input logic 				clk, reset, start;
		input logic [w - 1 : 0]	A, target;
		input logic [4:0]			front, last;
		output logic 				loads, found, not_found, lt, gt; 
		
		//Three states for the FSM
		enum{s1, s2, s3} ps, ns;
		
		//This always_comb implements an FSM for the binary
		//search control. The FSM has three states: s1, s2,
		//and s3. The FSM starts in s1 and stays in this state
		//until the start signal is 1, then it transitions to
		//s2. While in s2, there is an if statement that tests
		//if the data at the address we are pulling from is the
		//data we want OR if the front pointer is greater than
		//or equal to the last pointer. If either of those are
		//true, transition to s3. Otherwise stay in s2. The only
		//way to transition out of s3 to s1 is if start is 0, 
		//otherwise you stay in s3. 
		always_comb begin
			case(ps)
				s1: begin
					if(!start) begin
						ns = s1;
					end
					
					else begin
						ns = s2;
					end
				end
				
				s2: begin
					if((A == target) || (front >= last)) begin
						ns = s3;
					end
					
					else begin
						ns = s2;
					end
				end
				
				s3: begin
					if(!start) begin
						ns = s1;
					end
					
					else begin
						ns = s3;
					end
				end
			endcase
		end
		
		//This always_ff is to update ps. 
		//if reset is 1, then ps is set 
		//to s1. Else, ps is set to ns.
		always_ff @(posedge clk) begin
			if(reset) begin
				ps <= s1;
			end
			
			else begin 
				ps <= ns;
			end
		end
		
		//Assign load to 1 if in s1 and start is 0.
		//Assign found to 1 if in s3 and A == target.
		//Assign not_found to 1 if in s3 and A!= target.
		//Assign lt to 1 if in s2 and A < target.
		//Assign gt to 1 if in s2 and A > target.
		assign loads     = ((ps == s1) && !start) ? 1'b1 : 1'b0;
		assign found 	  = ((ps == s3) && (A == target)) ? 1'b1 : 1'b0;
		assign not_found = ((ps == s3) && (A != target)) ? 1'b1 : 1'b0;
		assign lt		  = ((ps == s2) && (A < target)) ? 1'b1 : 1'b0;
		assign gt		  = ((ps == s2) && (A > target)) ? 1'b1 : 1'b0;
endmodule 


//binarysearch_Control_testbench tests for expected, unexpected,
//and edgecase behavior. The testbench first sets start to 0 and
//resets. With start at 0, the system is in s1, so tests for if
//A > target, A < target, A == target, front > last, front < last,
//and front == last are done to see if any of the output flags 
//change even though in s1. Next, start is set to 1, and three
//tests are done in which A < target. After that, there are three
//tests for A > target, and then one test for if A == target. This
//was to see if lt, gt, and found were changing accordingly. After
//this, set A < target and start to 0 and then 1 to have the FSM 
//transition. Two tests are done to see if found > last triggers
//not_found, and if first == last triggers nor_found. Reset at the
//end to see if ps is set to s1. 
module binarysearch_Control_testbench();
		logic 		clk, reset, start;
		logic [7:0]	A, target;
		logic [4:0]	front, last;
		logic 		loads, found, not_found, lt, gt;
	
		binarysearch_Control #(.w(8)) dut(.clk, .reset, .start, .A, .front, .last, .target, 
													 .loads, .found, .not_found, .lt, .gt);
		
		parameter clk_PERIOD = 100;            
		initial begin                
				clk <= 0;
				forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
		end
		
		
		initial begin
			start <= 0; 						repeat(1)   @(posedge    clk);
			reset <= 1; 						repeat(1)   @(posedge    clk);
			reset <= 0; 						repeat(1)   @(posedge    clk);
			
			//Start isn't at 1. Still in s1. Check if outputs update correctly.
			front <= 5'd0; last <= 5'd31; repeat(1)   @(posedge    clk);
			front <= 5'd1; last <= 5'd1;  repeat(1)   @(posedge    clk);
			front <= 5'd1; last <= 5'd0;  repeat(1)   @(posedge    clk);
			A <= 8'd5; target <= 8'd6;		repeat(1)   @(posedge    clk);
			A <= 8'd5; target <= 8'd4;		repeat(1)   @(posedge    clk);
		   A <= 8'd5; target <= 8'd5;		repeat(1)   @(posedge    clk);	
			
			//Setting inputs to values that won't trigger flags. Start to 1.
			front <= 5'd0; last <= 5'd31; repeat(1)   @(posedge    clk);
			A <= 8'd5; target <= 8'd6;		repeat(1)   @(posedge    clk);
			start <= 1; 						repeat(1)   @(posedge    clk);
			
			//A < target while in s2
			A <= 8'd5; target <= 8'd8;		repeat(1)   @(posedge    clk);
			A <= 8'd1; target <= 8'd70;	repeat(1)   @(posedge    clk);
			A <= 8'd0; target <= 8'd1;		repeat(1)   @(posedge    clk);
			
			//A > target while in s2
			A <= 8'd5; target <= 8'd1;		repeat(1)   @(posedge    clk);
			A <= 8'd10; target <= 8'd1;	repeat(1)   @(posedge    clk);
			A <= 8'd1; target <= 8'd0;		repeat(1)   @(posedge    clk);
			
			//A == target. Wait 3 cycles to see behavior. 
			A <= 8'd0; target <= 8'd0;		repeat(3)   @(posedge    clk);
			
			//start to 0, back to s1
			start <= 0; 						repeat(1)   @(posedge    clk);
			A <= 8'd0; target <= 8'd6;		repeat(3)   @(posedge    clk);
			
			//Start to 1, and check for state change with front >= last
			start <= 1; 						repeat(1)   @(posedge    clk);
			front <= 5'd1; last <= 5'd1;  repeat(3)   @(posedge    clk);
			start <= 0; 						repeat(1)   @(posedge    clk);
			front <= 5'd10; last <= 5'd1; repeat(3)   @(posedge    clk);
			start <= 1; 						repeat(3)   @(posedge    clk);
			
			//Test reset from s3
			reset <= 1; 						repeat(1)   @(posedge    clk);
			reset <= 0; 						repeat(1)   @(posedge    clk);
			
			$stop; // End the simulation.
		end
endmodule 