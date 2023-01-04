//Garrett Tashiro
//November 15, 2021
//EE 371
//Lab 4, Task 1

//hex_display takes 4-bit dataIn as an input and returns
//7-bit led0 as an output. This module takes the data
//of number of 1's counted and then updates HEX0 display
//with the number of 1's.
module hex_display(dataIn, led0);
	input logic [3:0]	dataIn;
	output logic [6:0]	led0;

	//This always_comb takes 4-bit dataIn as the case parameter
	//and assigns led0 to values to display 0-F in hex to hex
	//disaply 0 based upon the value of dataIn.  
	always_comb begin
		case(dataIn)
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
	end
endmodule 

//hex_display_testbench tests for expected and unexpected
//behavior. This testsbench uses a for loop and assigns 
//dataIn to decimal values 0-15 to see how the output led0
//behaves. 
module hex_display_testbench();
	logic [3:0]	dataIn;
	logic [6:0] led0;

	hex_display dut(.dataIn, .led0);

	integer i;

	initial begin
		for(i = 0; i < 16; i++) begin
			dataIn = i;	 #10;
		end
	end
endmodule 
