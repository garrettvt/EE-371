//Garrett Tashiro
//October 7, 2021
//EE 371
//Lab 1, Task 1

//Module parkFSM takes 1-bit clk, reset, a, and b as input logic and returns 1-bit enter, and exit 
//as outputs. This module implements a parking lot gate with two sensors to detect is a car is
//leaving, or entering the parking lot. 
module parkFSM(clk, reset, a, b, enter, exit);
		input logic		clk, reset, a, b;	
		output logic	enter, exit;
		
		
		enum{none, enterA, enterAB, enterB, exitB, exitAB, exitA} ps, ns;
		
		//This always_comb is for the parking lots FSM that takes in seven states. 
		//The transition between states is triggered by the 1-bit inputs from 
		//a and b. The FSM starts in state none. 
		always_comb begin
			case(ps)
			
				none: begin
						
						if(a == 1 && b == 0) begin  //Start enter sequence
							exit = 0;
							enter = 0;
							ns = enterA;
						end
						
						else if(a == 0 && b == 1) begin  //Start exit sequence
							exit = 0;
							enter = 0;
							ns = exitB;
						end
						
						else begin  //Stay in none
							exit = 0;
							enter = 0;
							ns = none;
						end
				end
				
				enterA: begin  //Entering with only sensor a blocked
						
						if(a == 1 && b == 1) begin  //Both sensors are triggered for enter
							exit = 0;
							enter = 0;
							ns = enterAB;
						end
						
						else if(a == 0 && b == 0) begin  //No sensors are triggered
							exit = 0;
							enter = 0;
							ns = none;
						end
						
						else begin  //Stay in enterA
							exit = 0;
							enter = 0;
							ns = enterA;
						end
				end
				
				enterAB: begin  //Entering with both sensors blocked
						
						if(a == 0 && b == 1) begin  //Only sensor b is triggered in enter sequence
							exit = 0;
							enter = 0;
							ns = enterB;
						end
						
						else if(a == 1 && b == 0) begin  //Only sensor a is triggered in enter sequence
							exit = 0;
							enter = 0;
							ns = enterA;
						end
						
						else begin  //Stay in enterAB
							exit = 0;
							enter = 0;
							ns = enterAB;
						end
				end
				
				enterB: begin 
						
						if(a == 0 && b == 0) begin //Enter sequence finished
							exit = 0;
							enter = 1;  //Car has entered the lot. Increase enter.
							ns = none;
						end
						
						else if(a == 1 && b == 1) begin //Both sensors are triggered for exit
							exit = 0;
							enter = 0;
							ns = enterAB;
						end
						
						else begin  //Stay in enterB
							exit = 0;
							enter = 0;
							ns = enterB;
						end
				end
				
				exitB: begin
						
						if(a == 0 && b == 0) begin  //No sensors triggered
							exit = 0;
							enter = 0;
							ns = none;
						end
						
						else if(a == 1 && b == 1) begin  //Both sensors are triggered in exit sequence
							exit = 0;
							enter = 0;
							ns = exitAB;
						end
						
						else begin  //Stay in exitB
							exit = 0;
							enter = 0;
							ns = exitB;
						end
				end
				
				exitAB: begin 
						
						if(a == 0 && b == 1) begin  //Only sensor B is triggered in exit sequence
							exit = 0;
							enter = 0;
							ns = exitB;
						end
						
						else if(a == 1 && b == 0) begin  //Only sensor A is triggered in exit sequence
							exit = 0;
							enter = 0;
							ns = exitA;
						end
						
						else begin  //Stay in exitAB
							exit = 0;
							enter = 0;
							ns = exitAB;
						end
				end
				
				exitA: begin 
						
						if(a == 0 && b == 0) begin  //Exit sequence finished
							exit = 1;  //Car exited lot. Set exit variable to 1. 
							enter = 0;
							ns = none;
						end
						
						else if(a == 1 && b == 1) begin  //Both sensors triggered in exit sequence
							exit = 0;
							enter = 0;
							ns = exitAB;
						end
						
						else begin  //Stay in exitA
							exit = 0;
							enter = 0;
							ns = exitA;
						end
				end
			endcase
		end
		
		//This always_ff will set ps to none if the 1-bit input reset is
		//set to 1, otherwise ps will be set to next state upon the 
		//positive clock edge
		always_ff @(posedge clk) begin
			if (reset) begin
				ps <= none;  
		   end
			
			else begin
				ps <= ns;
			end
		end
endmodule 

//parkFSM_testbench tests all expected, unexpected, and edgecase behavior of the 
//parking lot FSM that is implemented in the lab. The testbench starts by first
//testing a pedestrian triggering sensors, then the next two tests are a car entering
//and exiting the lot, while the last two tests are trigger all sensors from entering
//or exiting, but not going from the last sensor to no sensors to enter/exit, then 
//back tracking through the states.
module parkFSM_testbench();
		logic clk, reset, a, b, enter, exit;
		
		parkFSM dut(.clk, .reset, .a, .b, .enter, .exit);
		
		parameter CLOCK_PERIOD = 100;            
		initial begin                
				clk <= 0;
				forever #(CLOCK_PERIOD/2) clk <= ~clk;// Forever toggle the clock     
		end
		
		initial 		begin
			a <= 0; b <= 0;  repeat(1)    @(posedge    clk);
			reset <= 1;		  repeat(1)    @(posedge    clk);
			reset <= 0; 	  repeat(1)    @(posedge    clk);
			a <= 1;			  repeat(1)    @(posedge    clk);  //Pedestrian start
			a <= 0; b <= 1;  repeat(1)    @(posedge    clk);
			//b <= 1;			  repeat(1)    @(posedge    clk);
			b <= 0;			  repeat(1)    @(posedge    clk);  //Pedestrian end
								  repeat(1)    @(posedge    clk);
			a <= 1;			  repeat(1)    @(posedge    clk);  //Enter start
			b <= 1;			  repeat(1)    @(posedge    clk);
			a <= 0;			  repeat(1)    @(posedge    clk);
			b <= 0;			  repeat(1)    @(posedge    clk);  //Enter end
								  repeat(1)    @(posedge    clk);
			b <= 1;			  repeat(1)    @(posedge    clk);  //Exit start
			a <= 1;			  repeat(1)    @(posedge    clk);
			b <= 0;			  repeat(1)    @(posedge    clk);
			a <= 0;			  repeat(1)    @(posedge    clk);  //Exit end
								  repeat(1)    @(posedge    clk);
			a <= 1;			  repeat(1)    @(posedge    clk);  //Testing from one side to another
			b <= 1;			  repeat(1)    @(posedge    clk);  //and back without triggering enter
			a <= 0;			  repeat(1)    @(posedge    clk);
			a <= 1;			  repeat(1)    @(posedge    clk);
			b <= 0;			  repeat(1)    @(posedge    clk);
			a <= 0;			  repeat(1)    @(posedge    clk);
								  repeat(1)    @(posedge    clk);
			b <= 1;			  repeat(1)    @(posedge    clk);  //Testing from one side to another
			a <= 1;			  repeat(1)    @(posedge    clk);  //and back without triggering exit
			b <= 0;			  repeat(1)    @(posedge    clk);
			b <= 1;			  repeat(1)    @(posedge    clk);
			a <= 0;			  repeat(1)    @(posedge    clk);
			b <= 0;			  repeat(1)    @(posedge    clk);
								  repeat(1)    @(posedge    clk);

			$stop; // End the simulation.
		end
endmodule 
