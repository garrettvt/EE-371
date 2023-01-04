//Garrett Tashiro
//October 30, 2021
//EE 371
//Lab 3, Task 1

//line_drawer module has 1-bit clk, reset, 10-bit x0, x1, 
//9-bit y0, and y1 as inputs and returns 10-bit x, and
//9-bit y as outputs. This module takes in corrdinate
//pairs (x0, y0) and (x1, y1) and will update outputs x and 
//and y to then draw a ling from one point to another. 
module line_drawer(clk, reset, x0, x1, y0, y1, x, y);
	input logic 		clk, reset;
	input logic [9:0]	x0, x1; 
	input logic [8:0] 	y0, y1;
	output logic [9:0] 	x;
	output logic [8:0] 	y; 

	//12-bit logic for the error and two times the error
	//10-bit logic for delta x and delta y
	logic signed [11:0] error, e2;
	logic signed [9:0] dx, dy;

	//Assigning dx with a conditional operator
	//to get the absolute value of delta x
	assign dx = (x1 > x0) ? x1 - x0 : x0 - x1;

	//Assigning dy with a conditional operator
	//to get the absolute value of delta y
	assign dy = (y1 > y0) ? y1 - y0 : y0 - y1;  

	//Two states for the line_drawer FSM	
	enum{start, draw} state;

	//This always_comb block is to update 12-bit e2 to 
	//be two times what 12-bit error value is
	always_comb begin
		e2 = 2*error;
	end

	//This always_ff block holds the FSM and draws the line for the
	//system. If 1-bit input reset is high, state is set to start.
	//The else portion is the logic for the FSM. The system will start
	//in the start state and assign 10-bit output x to 10-bit input x0, 
	//and 9-bit output y to 9-bit input y0. If the x inputs are equal
	//as well as the y inputs, then the FSM will stay in the start state.
	//If they are not equal, the state machine will tranistion to the draw
	//state and increment 10-bit out x and 9-bit out y accordingly until the
	//line is drawn.
	always_ff @(posedge clk) begin
		if(reset) begin
			state <= start;
		end

		else begin
			case(state)
				start: begin
					if((x0 == x1) && (y0 == y1)) begin
						x <= x0;
						y <= y0;
						state <= start;
					end

					else begin
						x <= x0;
						y <= y0;
						error <= dx - dy;
						state <= draw;
					end
				end

				draw: begin
					if((x == x1) && (y == y1)) begin
						x <= x1; 
						y <= y1;
						state <= start;
					end

					else begin

						if(e2 >= -dy) begin
							error <= error - dy;
							x <= (x1 > x0) ? (x + 1) : (x - 1);
						end

						if(e2 <= dx) begin
							error <= error + dx;
							y <= (y1 > y0) ? (y + 1) : (y - 1);
						end

						if((e2 >= -dy) && (e2 <= dx)) begin
							error <= error - dy + dx;
							x <= (x1 > x0) ? (x + 1) : (x - 1);
							y <= (y1 > y0) ? (y + 1) : (y - 1);
						end

						state <= draw;
					end
				end
			endcase
		end  
	end  
endmodule 


//line_drawer_testbench tests for expected and unexpected behavior.
//The testbech first sets all the inputs to 0, and resets. The first
//test is changing x1, and y1 and holds the value for 6 clock cycles.
//Next, reset is set high then low. x1, and y1 are both set to 0 while
//x0, and y0 are increase to different numbers under 10. The third test
//is having all input values be equal to zero, then setting reset high
//then low. reset stays low for 5 clock cycles. This was to check if
//the output values would stay at x0 and y1 and the FSM would stay in 
//the start state. The final test I set x0, x1, and y0 to 0 and had
//y1 set to 8. I set reset high, then low for 15 clock cycles.
module line_drawer_testbench();
	logic 		clk, reset;
	logic [9:0]	x0, x1; 
	logic [8:0] 	y0, y1;
	logic [9:0] 	x;
	logic [8:0] 	y; 

	line_drawer dut(.clk, .reset, .x0, .x1, .y0, .y1, .x, .y);

	parameter clk_PERIOD = 100;            
	initial begin                
			clk <= 0;
			forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
	end

	initial begin
		x0 <= 9'd0; x1 <= 9'd0; y0 <= 8'd0; y1 <= 8'd0;  repeat(1)   @(posedge    clk);
		reset <= 1;	 					repeat(1)   @(posedge    clk);
		reset <= 0;	 					repeat(1)   @(posedge    clk);
		x1 <= 9'd2; y1 <= 8'd3;			repeat(1)   @(posedge    clk);
										repeat(6)  @(posedge    clk);
		reset <= 1;	 					repeat(1)   @(posedge    clk);
		reset <= 0;	 					repeat(1)   @(posedge    clk);
		x1 <= 9'd0; y1 <= 8'd0;			repeat(1)   @(posedge    clk);
		x0 <= 9'd4; y0 <= 8'd5;			repeat(1)   @(posedge    clk);
											repeat(10)  @(posedge    clk);
		x0 <= 9'd0; x1 <= 9'd0; y0 <= 8'd0; y1 <= 8'd0;  repeat(1)   @(posedge    clk);
		reset <= 1;	 					repeat(1)   @(posedge    clk);
		reset <= 0;	 					repeat(5)   @(posedge    clk);
		x0 <= 9'd0; x1 <= 9'd0; y0 <= 8'd0; y1 <= 8'd8;  repeat(1)   @(posedge    clk);
		reset <= 1;	 					repeat(1)   @(posedge    clk);
		reset <= 0;	 					repeat(15)   @(posedge    clk);
		$stop; // End the simulation.
	end
endmodule 
