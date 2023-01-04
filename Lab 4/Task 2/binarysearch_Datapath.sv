//Garrett Tashiro
//November 17, 2021
//EE 371
//Lab 4, Task 2

//binarysearch_Datapath has 1-bit clk, reset, loads, lt, 
//and gt as inputs and returns 5-bit front, mid, last, and 
//addr as outputs. This module implements the datapath for  
//the binary search algo. Depending on what the flag inputs 
//are will determine if front, last, and mid will change to 
//shift the search around the array. 
module binarysearch_Datapath(clk, reset, loads, lt, gt, front, mid, last, addr);
		input logic 				clk, reset;
		input logic 				loads, lt, gt;
		output logic [4:0]		front, mid, last, addr;
		
		//Assign addr to mid to send to hex_display.
		assign addr = mid;  
		
		//This always_ff sets 5-bit outputs front, mid, 
		//and last. If reset or loads is 1, then front
		//is set to 0, mid is set to 16, and last is set
		//to 31. If reset and loads are both 0, then the
		//control will send flags for less than, or 
		//greater than depending on where the value lies
		//compared to the data at memeray address mid. 
		//Shifting happens depending on which flag is 
		//raised, and then mid is always half of what
		//the sum of front and last is. 
		always_ff @(posedge clk) begin
			if(reset || loads) begin
				front <= 5'b00000;
				mid 	<= 5'b10000;
				last	<= 5'b11111;
			end
			
			else if(lt) begin
				last <= mid - 5'd1;
			end
			
			else if(gt) begin
				front <= mid + 5'd1;
			end
			
			mid  <= (front + last) / 2;
		end
endmodule 

//binarysearch_Datapath_testbench tests for expected, unexpected,
//and edgecase behavior. The testbench first sets loads lt, and gt
//to 0 and resets. After the reset, lt is set to 1 for 8 cycles to
//see if mid and last will equal front. After that, lt is set to 0 
//and loads is set high then low to reset the system. gt is then 
//set high for 10 clock cycles to see if front and mid will increment
//up and equal last. After that reset is set high then low. lt is 
//set low then high twice, and gt is set low than twice to see if
//the system can accpect both lt, and gt correctly.  
module binarysearch_Datapath_testbench();
		logic clk, reset, loads, lt, gt;
		logic [4:0] front, mid, last, addr;
		
		binarysearch_Datapath dut(.clk, .reset, .loads, .lt, .gt, .front, .mid, .last, .addr);

		parameter clk_PERIOD = 100;            
		initial begin                
				clk <= 0;
				forever #(clk_PERIOD/2) clk <= ~clk;// Forever toggle the clk     
		end
		
		initial begin
			loads <= 0; lt <= 0; gt <= 0;		repeat(1)   @(posedge    clk);
			reset <= 1; 							repeat(1)   @(posedge    clk);
			reset <= 0; 							repeat(1)   @(posedge    clk);
			lt <= 1;									repeat(8)   @(posedge    clk);
			lt <= 0;									repeat(1)   @(posedge    clk);
			loads <= 1;								repeat(1)   @(posedge    clk);
			loads <= 0;								repeat(1)   @(posedge    clk);
			
			gt <= 1;									repeat(10)  @(posedge    clk);
			gt <= 0;									repeat(1)   @(posedge    clk);
			loads <= 1;								repeat(1)   @(posedge    clk);
			loads <= 0;								repeat(1)   @(posedge    clk);
			
			reset <= 1; 							repeat(1)   @(posedge    clk);
			reset <= 0; 							repeat(1)   @(posedge    clk);
			
			lt <= 1;									repeat(1)   @(posedge    clk);
			lt <= 0;									repeat(1)   @(posedge    clk);
			lt <= 1;									repeat(1)   @(posedge    clk);
			lt <= 0;									repeat(1)   @(posedge    clk);
			gt <= 1;									repeat(1)   @(posedge    clk);
			gt <= 0;									repeat(1)   @(posedge    clk);
			gt <= 1;									repeat(1)   @(posedge    clk);
			gt <= 0;									repeat(1)   @(posedge    clk);
			
			$stop; // End the simulation.
		end
endmodule 