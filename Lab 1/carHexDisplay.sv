//Garrett Tashiro
//October 8, 2021
//EE 371
//Lab 1, Task 3

//carHexDisplay has 1-bit clear, 1-bit full, 4-bit ones, and 4-bit tens as
//inputs and returns 7-bit led0, 7-bit led1, 7-bit led2, 7-bit led3, 7-bit 
//led4, and 7-bit led5 as outputs. This module is designed to display the
//ouputs for the count from the counter module to the hex displays. If clear
//is 1 then the hex displays will display "CLEAr" followed by a 0. If full 
//is 1 then hex displays will display "FULL" followed by the number of cars
//in the lot. If neither clear, or full are 1, only the number of cars is displayed.
module carHexDisplay(clear, full, ones, tens, led0, led1, led2, led3, led4, led5);
		input logic				clear, full;
		input logic [3:0]		ones, tens;
		output logic [6:0]	led0, led1, led2, led3, led4, led5;
		
		//Numbers for HEX displays to count number of cars
		localparam logic [6:0] zero = 7'b1000000;   //0
		localparam logic [6:0] one = 7'b1111001;    //1
		localparam logic [6:0] two = 7'b0100100;    //2
		localparam logic [6:0] three = 7'b0110000;  //3
		localparam logic [6:0] four = 7'b0011001;   //4
		localparam logic [6:0] five = 7'b0010010;   //5
		localparam logic [6:0] six = 7'b0000010;    //6
		localparam logic [6:0] seven = 7'b1111000;  //7
		localparam logic [6:0] eight = 7'b0000000;  //8
		localparam logic [6:0] nine = 7'b0010000;   //9
		
		//Letters for hex displays to write out CLEAr and FULL
		localparam logic [6:0] C = 7'b1000110;  //C
		localparam logic [6:0] L = 7'b1000111;  //L  
		localparam logic [6:0] E = 7'b0000110;  //E
		localparam logic [6:0] A = 7'b0001000;  //A
		localparam logic [6:0] R = 7'b0101111;  //r
		localparam logic [6:0] F = 7'b0001110;  //F
		localparam logic [6:0] U = 7'b1000001;  //U
		
	   localparam logic [6:0] blank = 7'b1111111;
		
		
		//This always_comb block uses the 4-bit inputs ones, and tens in case statements
		//to display the number of cars are in the lot on HEX0 and HEX1. If no cars are in
		//the lot, clear will be 1, HEX1 will be set to 'r' to be at the end of the word  
		//"CLEAr" that is displayed on HEX5-HEX1. 
		always_comb begin
			case(ones)
				
				4'd0: begin
						led0 = zero;
				end
				
				4'd1: begin
						led0 = one;
				end
				
				4'd2: begin
						led0 = two;
				end
				
				4'd3: begin
						led0 = three;
				end
				
				4'd4: begin
						led0 = four;
				end
				
				4'd5: begin
						led0 = five;
				end
				
				4'd6: begin
						led0 = six;
				end
				
				4'd7: begin
						led0 = seven;
				end
				
				4'd8: begin
						led0 = eight;
				end
				
				4'd9: begin
						led0 = nine;
				end
				
				default: begin
						led0 = 7'bx;
				end
			endcase 
			
			case(tens)
				
				4'd0: begin
						if(clear == 1) begin
							led1 = R;
							led0 = zero;
						end
						
						else begin
							led1 = zero;
						end
				end
				
				4'd1: begin
						led1 = one;
				end
				
				4'd2: begin
						led1 = two;
				end
				
				4'd3: begin
						led1 = three;
				end
				
				4'd4: begin
						led1 = four;
				end
				
				4'd5: begin
						led1 = five;
				end
				
				4'd6: begin
						led1 = six;
				end
				
				4'd7: begin
						led1 = seven;
				end
				
				4'd8: begin
						led1 = eight;
				end
				
				4'd9: begin
						led1 = nine;
				end
				
				default: begin
						led1 = 7'bx;
				end
			endcase
		end
		
		//This always_comb is to set HEX displays HEX5-HEX2. When clear is 1
		//HEX5-HEX2 are set to say "CLEA". When full is 1 HEX5-HEX2 are set to
		//say "FULL". If neither full or clear are 1, then HEX5-HEX2 will be 
		//blank and not display anything. 
		always_comb begin
			
			if(clear == 1) begin
				led5 <= C;
				led4 <= L;
				led3 <= E;
				led2 <= A;
			end
			
			else if(full == 1) begin
				led5 <= F;
				led4 <= U;
				led3 <= L;
				led2 <= L;
			end
			
			else begin
				led5 <= blank;
				led4 <= blank;
				led3 <= blank;
				led2 <= blank;
			end
		end
		
		//Causes weird bug. Just stick with always_comb and 
		//get rid of clk and reset up top.
//		always_ff @(posedge clk) begin
//			if(reset || clear == 1) begin
//				led5 <= C;
//				led4 <= L;
//				led3 <= E;
//				led2 <= A;
//			end
//			
//			else if(full == 1) begin
//				led5 <= F;
//				led4 <= U;
//				led3 <= L;
//				led2 <= L;
//			end
//			
//			else begin
//				led5 <= blank;
//				led4 <= blank;
//				led3 <= blank;
//				led2 <= blank;
//			end
//	   end
endmodule 

//carHexDisplay_testbench tests to see what happens to the hex displays when clear
//is 0 and 1. It also tests to see what happens to the hex displays when full is 
//set to 0 and 1. The testbench counts from 0-9 for ones, and counts from 0-1 for
//tens. This test counted from 0 to 15, then back down to 0, with 15 being the max. 
module carHexDisplay_testbench();
		logic				clear, full;
		logic [3:0]		ones, tens;
		logic [6:0]	led0, led1, led2, led3, led4, led5;
		
		carHexDisplay dut(.clear, .full, .ones, .tens, .led0, .led1, .led2, .led3, .led4, .led5);
		
		initial 		begin
			ones <= '0; tens <= '0; clear <= 1; full <= 0;  #10;
															 #10;
			ones <= 4'd1; clear <= 0;			    #10;
			ones <= 4'd2;								 #10;
			ones <= 4'd3;								 #10;
			ones <= 4'd4;								 #10;
			ones <= 4'd5;								 #10;
			ones <= 4'd6;								 #10;
			ones <= 4'd7;								 #10;
			ones <= 4'd8;								 #10;
			ones <= 4'd9;								 #10;
			ones <= '0; tens <= 4'd1;				 #10;
			ones <= 4'd1;								 #10;
			ones <= 4'd2;								 #10;
			ones <= 4'd3;								 #10;
			ones <= 4'd4;								 #10;
			ones <= 4'd5; full <= 1;				 #10;
															 #10;
			ones <= 4'd4; full <= 0;				 #10;
			ones <= 4'd3;								 #10;
			ones <= 4'd2;								 #10;
			ones <= 4'd1;								 #10;
			ones <= 4'd0;								 #10;
			ones <= 4'd0; tens <= 4'd0;			 #10;
			ones <= 4'd9;								 #10;
			ones <= 4'd8;								 #10;
			ones <= 4'd7;								 #10;
			ones <= 4'd6;								 #10;
			ones <= 4'd5;								 #10;
			ones <= 4'd4;								 #10;
			ones <= 4'd3;								 #10;
			ones <= 4'd2;								 #10;
			ones <= 4'd1; 							    #10;
			ones <= 4'd0; clear <= 1;			    #10;
		end
endmodule 