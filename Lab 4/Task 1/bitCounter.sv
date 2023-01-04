//Garrett Tashiro
//November 15, 2021
//EE 371
//Lab 4, Task 1

//bitCounter has 1-bit clk, reset, start, and z as 
//inputs and returns 1-bit load_b, result_shift, and done
//as outputs. This module is the control module for a bit
//counter. It has the FSM for the system, and will use inputs
//start and z to control state changing. Assignments for 
//outputs are based upon the state the system is in. 
module bitCounter(clk, reset, z, start, result_shift, load_b, done);  
	input logic 		 clk, reset, start, z;
	output logic 		 load_b, result_shift, done;

	//enumerated states for the FSM
	enum{s1, s2, s3} ps, ns;

	//This always_comb has the FSM for the bit counter. The FSM
	//will stay in s1 as long as start is low. If start is high, 
	//the FSM will transition to s2. Once in s2, as long as 'z'
	//is low, the FSM will stay in s2, which sets result_shift 
	//and shifts the bits in the datapath. If 'z' is 1, the FSM
	//transitions to s3. The FSM stays in s3 as long as start is
	//1, otherwise the FSM transitions to s1. While in s1 and  
	//!start, output load_b is 1. In s3, done is 1. 
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
				if(z == 1) begin
					ns = s3;
				end

				else begin
					ns = s2;
				end
			end

			s3: begin
				if(start) begin
					ns = s3;
				end

				else begin
					ns = s1;
				end
			end
		endcase 
	end

	//This always_ff is to update ps. Upon reset
	//ps is set to s1. If reset is 0, then ps is 
	//set to ns. 
	always_ff @(posedge clk) begin
		if(reset) begin
			ps <= s1;
		end

		else begin
			ps <= ns;
		end
	end

	////Assignment of outputs////

	//result_shift is 1 if in s2 state
	assign result_shift = (ps == s2);

	//done is 1 if in s3 state
	assign done = (ps == s3);

	//load_b is 1 if in s1 state and start is 0
	assign load_b = ((ps == s1) && !start) ? 1'b1 : 1'b0;
endmodule

//bitCounter_testbench tests for expected, unexpected, and edgecase
//behavior. This testbench first sets 1-bit inputs start and z to 0.
//Reset is then set high for one clock cycle, then low. Next, start
//and z are both set to 1 for 2 clock cycles. Z is then set to 0 for
//two clock cycles. Then start is set to 0 for two clock cycles. This 
//was done to see the behavior of the outputs, and if they would update
//properly. Next, reset is set high then low. Start is then set high 
//for 8 clock cycles, and then low for 2. After that, z is set high for
//one clock cycle, then low for 4 clock cycles. This was checking if 
//states and outputs would update properly as well. 
module bitCounter_testbench();
	logic 	   clk, reset, start, z;
	logic 	   load_b, result_shift, done;

	bitCounter dut(.clk, .reset, .z, .start, .result_shift, .load_b, .done);
	parameter clk_PERIOD = 100;            
	initial begin                
	      clk <= 0;
	      forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
	end

	initial begin
	   start <= 0; z <= 0;		repeat(1)   @(posedge    clk);
	   reset <= 1; 			repeat(1)   @(posedge    clk);
	   reset <= 0; 			repeat(1)   @(posedge    clk);
	   start <= 1;	z <= 1;		repeat(2)   @(posedge    clk);
	   start <= 1;	z <= 0;		repeat(2)   @(posedge    clk);
	   start <= 0;	z <= 0;		repeat(2)   @(posedge    clk);
	   reset <= 1; 			repeat(1)   @(posedge    clk);
	   reset <= 0; 			repeat(1)   @(posedge    clk);
	   start <= 1; 		        repeat(8)   @(posedge    clk);
	   start <= 0; 			repeat(2)   @(posedge    clk);
	   z <= 1;			repeat(1)   @(posedge    clk);
	   z <= 0;			repeat(4)   @(posedge    clk);

	   $stop; // End the simulation.
	end
endmodule 
