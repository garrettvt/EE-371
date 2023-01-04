//Garrett Tashiro
//November 15, 2021
//EE 371
//Lab 4, Task 2

//hex_display takes 4-bit dataIn and 1-bit found as inputs a
//nd returns 7-bit led0, led1 as outputs. This module takes 
//the data of the address that mid is pointing to, and if
//found is 1, then the address will be displayed on HEX1 and
//HEX0, otherwise HEX0 and HEX1 are blank. 
module hex_display(dataIn, found, led0, led1);
		input logic 			found;
		input logic [4:0]		dataIn;
		output logic [6:0]	led0, led1;
		
		//logic for upper bit of dataIn as well
		//logic lower for lower 4 bits of dataIn
		logic upper;
		logic [3:0] lower;
		
		//Assign lower to the lower 4 bits of dataIn
		//Assing the most significant bit of dataIn to upper.
		assign lower = dataIn[3:0];
		assign upper = dataIn[4];
		
		//This always_comb has an if statement to check if found
		//is 1. If it is, there are two case statements: lower, 
		//and upper. Case statement for lower sets led0 to the
		//respective value of the lower bits of dataIn to display
		//0-F. Case statement for upper sets led1 to the respective
		//value of the upper bit of dataIn to 0 or 1. Else statement
		//for if the data is not found, and in this case both led0
		//and led1 are going to be blank on the HEX displays. 
		always_comb begin
			if(found) begin
				case(lower)
					4'd0: begin
						led0 = 7'b1000000;   //0
					end
					
					4'd1: begin
						led0 = 7'b1111001;   //1
					end
					
					4'd2: begin
						led0 = 7'b0100100;   //2
					end
					
					4'd3: begin
						led0 = 7'b0110000;   //3
					end
					
					4'd4: begin
						led0 = 7'b0011001;   //4
					end
					
					4'd5: begin
						led0 = 7'b0010010;   //5
					end
					
					4'd6: begin
						led0 = 7'b0000010;   //6
					end
					
					4'd7: begin
						led0 = 7'b1111000;   //7
					end
					
					4'd8: begin
						led0 = 7'b0000000;   //8
					end
					
					4'd9: begin
						led0 = 7'b0010000;   //9
					end
					
					4'd10: begin
						led0 = 'b0001000;    //A 
					end
					
					4'd11: begin
						led0 = 7'b0000011;   //b
					end
					
					4'd12: begin
						led0 = 7'b1000110;   //C
					end
					
					4'd13: begin
						led0 = 7'b0100001;   //d
					end
					
					4'd14: begin
						led0 = 7'b0000110;  	//E
					end
					
					4'd15: begin
						led0 = 7'b0001110;  	//F
					end
					
					default: begin
						led0 = 7'bx;
					end
				endcase
				
				case(upper)
					1'b0: begin
						led1 = 7'b1000000;   //0
					end
					
					1'b1: begin
						led1 = 7'b1111001;   //1
					end
					
					default: begin
						led1 = 7'bx;
					end
				endcase
			end
			
			else begin
				led0 = 7'b1111111;
				led1 = 7'b1111111;
			end		
		end
endmodule 

//hex_display_testbench tests for expected and unexpected
//behavior. This testbench first sets found to 0 then uses 
//a for loop to change dataIn by setting it to 'i'. The loop
//goes from 0-17. After that, found is set to 1, and there
//is a second for loop that goes from 0-17. This is to check
//if the HEX displays will be updating according to the value
//of input found. 
module hex_display_testbench();
		logic found;
		logic [4:0]	dataIn;
		logic [6:0] led0, led1;
		
		hex_display dut(.dataIn, .found, .led0, .led1);
		
		integer i;
		
		initial begin
			found <= 0;
			for(i = 0; i < 18; i++) begin
				dataIn = i;	 #10;
			end
			
			found <= 1;
			for(i = 0; i < 18; i++) begin
				dataIn = i;	 #10;
			end
		end
endmodule 