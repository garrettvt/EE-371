//Garrett Tashiro
//November 2, 2021
//EE 371
//Lab 3, Task 2

//line_drawer has 1-bit clk, reset, fin, 10-bit x1, x0, 9-bit y1,
//and y0 as inputs and returns 1-bit black, 10-bit x, and 9-bit y
//as outputs. This module implements Bresenham's line drawing
//algorithm in an FSM. The FSM will first draw a line in white
//and once the line is drawn, there will be a 1700 clock cycle 
//delay, then it will set the color to black and draw over the white 
//line with a black one. After the black line is drawn over the 
//white line, the 10-bit logic shift will increment by 1 and that
//will increment 10-bit logics n0 and n1 which hold the values for
//x0 and x1, thus, shifting the line across the screen. This module
//is designed to shift a line from left to right across the VGA display.
module line_drawer(clk, reset, fin, x0, x1, y0, y1, x, y, black);
		input logic 			clk, reset, fin;
		input logic [9:0]		x0, x1; 
		input logic [8:0] 	y0, y1;
		output logic [9:0] 	x;
		output logic [8:0] 	y;
		output logic			black;
		
		//12-bit logic error, and e2 to hold the 
		//error and two times the error value
		logic signed [11:0] error, e2;
		
		//10-bit dx and dy to hold the absolute 
		//values for delta x and delta y
		logic signed [9:0] dx, dy;
		
		//13-bit count is a counter for when the 
		//white line is drawn
		logic [10:0] count;
		
		//10-bit logic n0, and n1 to hold the 
		//new values from the original shifted
		//value. 10-bit logic shift to increment
		//n0, and n1 for shifting. 
		logic [9:0]	n0, n1, shift; 
		
		//Assiging dx and dy with conditional operators
		//to obtain the absolute values of delta x
		//and delta y.
		assign dx = (n1 > n0) ? n1 - n0 : n0 - n1;  //Changed x's to n's
		assign dy = (y1 > y0) ? y1 - y0 : y0 - y1;  
		
		//States for the FSM
		enum{start, draw, done} state;
		
		//This always_comb block updates the 12-bit value
		//e2 whenever error is changed, update n0, and n1
		//whenever a line is drawn over and needs to be shifted
		//once shift is updated
		always_comb begin
			e2 = 2*error;
			n0 = (x0 + shift);
			n1 = (x1 + shift);
		end
		
		//This always_ff block has the logic for the FSM. It starts with an
		//if statement to see if reset is high, or if ~fin. If either of these
		//are true, 1-bit output blakc will be set to 0, 11-bit count, and 10-bit
		//shift is set to 0. The state is set to done. Once fin is high and 
		//reset is low, the FSM is in start and 10-bit output x, and 9-bit output
		//y are assigned. Depending on the input values will determine the next state. 
		//If in the draw state, the line will start to be drawn by increasing, or
		//decreasing -bit output x, and 9-bit output y, resepectfully. Once the line
		//is finished and x and y are at the end points, the FSM will go to the done 
		//state, where a white line will be held for 1450 clock cycles, or a black line
		//will be drawn over the white line by going back to the start state. 
		always_ff @(posedge clk) begin
			if(reset || ~fin) begin
				black <= 1'b0;
				count <= '0;
				shift <= '0;
				state <= done;
			end
			
			else begin
				case(state)
					start: begin
						if((n0 == n1) && (y0 == y1)) begin
							x <= x0;
							y <= y0;
							state <= start; 
						end
						
						else begin
							x <= n0;
							y <= y0;
							error <= dx - dy;
							state <= draw;
						end
					end
					
					draw: begin
						if((x == n1) && (y == y1)) begin
							x <= n1; 
							y <= y1;
							state <= done;
						end
						
						else begin
							
							if(e2 >= -dy) begin
								error <= error - dy;
								x <= (n1 > n0) ? (x + 1) : (x - 1);
							end
							
							if(e2 <= dx) begin
								error <= error + dx;
								y <= (y1 > y0) ? (y + 1) : (y - 1);
							end
							
							if((e2 >= -dy) && (e2 <= dx)) begin
								error <= error - dy + dx;
								x <= (n1 > n0) ? (x + 1) : (x - 1);
								y <= (y1 > y0) ? (y + 1) : (y - 1);
							end
							
							state <= draw;
						end
					end
					
					done: begin
						if(~black) begin
							black <= 1'b1;
							if((n0 == 640) || (n1 == 640)) begin
							    shift <= '0;
							end
							
							else begin
							    shift <= shift + 1;
							end
							state <= start;
						end
						
						else begin
							//if the count is max, then draw a black line
							if(count == 11'd1700) begin
								black <= 1'b0;
								count <= '0;
								state <= start;
							end
							//if count isn't max, stay in done and increase count
							else begin
								black <= 1'b1;
								count <= count + 11'd1;
								state <= done;
							end
						end
					end
				endcase
			end  
		end
endmodule 

//line_drawer_testbench tests for expected and unexpected behavior.
//For these tests, the value for which count is allowed to count
//up to in the done state was changed to 10 just for simplicity. 
//This testbench first sets values for x0, x1, y0, y1, and then 
//sets reset high, then low. This first test has x1 and y1 greater than
//x0 and y0. This ran with these values for 40 clock cycles to be able
//to draw the line in white, hold the white line, and then change the
//color to black and draw over it. The second test starts with reset
//being set high, then low, and then x0 and y0 are greater than x1 and
//y1. The test ran with these values for 40 clock cycles too have the
//line draw in white, the go over it black, then shift and draw in white.
//the last test was with all the points equal to 0. This was done to see
//if it would change from the (0, 0) location.
module line_drawer_testbench();
		logic 			clk, reset, black, fin;
		logic [9:0]		x0, x1; 
		logic [8:0] 	y0, y1;
		logic [9:0] 	x;
		logic [8:0] 	y;	
		
		line_drawer dut(.clk, .reset, .fin, .x0, .x1, .y0, .y1, .x, .y, .black);
		
		parameter clk_PERIOD = 100;            
		initial begin                
				clk <= 0;
				forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
		end
		
		initial begin
			x0 <= 9'd0; x1 <= 9'd3; y0 <= 8'd0; y1 <= 8'd3;  repeat(1)   @(posedge    clk);
			fin <= 1;
			reset <= 1;	 					repeat(1)   @(posedge    clk);
			reset <= 0;	 					repeat(1)   @(posedge    clk);
											repeat(40)  @(posedge    clk);
			reset <= 1;	 					repeat(1)   @(posedge    clk);
			reset <= 0;	 					repeat(1)   @(posedge    clk);
			x0 <= 9'd2; y0 <= 8'd3; x1 <= 9'd0; y1 <= 8'd0;		repeat(1)   @(posedge    clk);
											repeat(40)  @(posedge    clk);
			fin <= 0;						repeat(1)   @(posedge    clk);
			fin <= 1;						repeat(1)   @(posedge    clk);
			x0 <= 9'd0; y0 <= 8'd0; x1 <= 9'd0; y1 <= 8'd0;		repeat(6)   @(posedge    clk);
			
			$stop; // End the simulation.
		end
endmodule 