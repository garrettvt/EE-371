//Garrett Tashiro
//October 10, 2021
//EE 371
//Lab 1, Task 4

//DE1_SoC has 1-bit CLOCK_50 as input, 34-bit GPIO_0 as inout, and 7-bit
//HEX0, HEX1, HEX2, HEX3, HEX4, and HEX5 as outputs. DE1_SoC combines
//the modules from previous tasks, as well as GPIO_0 to control LED's
//on the breadboard to act as teh parking lots sensors being triggered,
//and the HED displays to display the number of cars in the lot and
//show if the lot is full or empty (clear). This is the top-level module
//for the parking lot sensor system in this lab.
module DE1_SoC(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, GPIO_0, CLOCK_50);
		// SW and KEY cannot be declared if GPIO_0 is declaredon LabsLand
		input logic				CLOCK_50;
		inout logic [33:0]	GPIO_0;  //GPIO uses inout logic instead of input or output
		output logic [6:0]	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		
		//Assigning 1-bit logic to GPIO inputs, as well as
		//assigning GPIO outputs for LED's to GPIO inputs
		//from switches.
		logic reset, SWA, SWB;
		assign reset = GPIO_0[5];
		assign SWA = GPIO_0[6];
		assign SWB = GPIO_0[7];
		assign GPIO_0[26] = SWA;
		assign GPIO_0[27] = SWB;
		
		//1-bit logic for outputs out from both doubleD's: sensorA, sensorB 
		//1-bit logic for outputs enter and exit from parkFSM: entering, exiting
		//1-bit logic for outputs clear and full from counter: allOpen, allFull
		//4-bit logic for outputs ones and tens from counter: pennies, dimes 
		logic sensorA, sensorB, entering, exiting, allOpen, allFUll;
		logic [3:0] pennies, dimes;
		
		//doubleD SW1 takes 1-bit input CLOCK_50, 1-bit input reset, 1-bit input SWA, 
		//and outputs 1-bit sensorA. SWA is set to GPIO_0[6] to create an output that 
		//prevents metastability.
		doubleD SW1(.clk(CLOCK_50), .reset(reset), .press(SWA), .out(sensorA));
		
		//doubleD SW2 takes 1-bit input CLOCK_50, 1-bit input reset, 1-bit input SWB, 
		//and outputs 1-bit sensorB. SWB is set to GPIO_0[7] to create an output that 
		//prevents metastability.
		doubleD SW2(.clk(CLOCK_50), .reset(reset), .press(SWB), .out(sensorB));
		
		//parkFSM parkingLotFSM task 1-bit input CLOCK_50, 1-bit input reset, 1-bit input 
		//sensorA, 1-bit input sensorB, and has 1-bit output entering, 1-bit output exiting. 
		//parkingLotFSM takes the 1-bit outputs from doubleD SW1, and doubleD SW2 that to 
		//determine if a car is entering/exiting the parking lot. A vehicle has to trigger  
		//the first sensor, both sensors, just the second sensor, and then no sensors for a 
		//car to enter/exit the lot. 
		parkFSM parkingLotFSM(.clk(CLOCK_50), 
									 .reset(reset), 
									 .a(sensorA), 
									 .b(sensorB), 
									 .enter(entering), 
									 .exit(exiting));
		
		//counter countU_D takes 1-bit input CLOCK_50, 1-bit input reset, 1-bit input entering,
		//1-bit input exiting, and has 1-bit output allOpen, 1-bit output allFull, 4-bit output 
		//pennies, 4-bit output and dimes. This modulecounts the number of cars that are in the 
		//lot. If no cars are in the lot, allOut will be high. If the max number of cars are in 
		//the lot, allFull will be high. The 1-bit inputs entering and exiting are used to  
		//increment/decrement the total number of cars in the lot which is output using a combination 
		//of 4-bit outputs pennies, and dimes.
		counter countU_D(.clk(CLOCK_50), 
							  .reset(reset), 
							  .inc(entering), 
							  .dec(exiting), 
							  .clear(allOpen), 
							  .full(allFUll), 
							  .ones(pennies), 
							  .tens(dimes));
		
		//carHexDisplay displayCars takes 1-bit input allOpen, 1-bit input allFull, 4-bit 
		//input penies, 4-bit input dimes, and 7-bit outputs HEX0-HEX5. This module is designed
	   //to display the total number of cars in the parking lot on HEX1 and HEX0. If there are
	   //no cars in the lot then HEX5-HEX1 will display "CLEAr" while HEX0 displays 0. If the
	   //lot is full then HEX5-HEX2 will display "FULL" while HEX1 and HEX0 will display the
	   //number of cars in the parking lot. 	
		carHexDisplay displayCars(.clear(allOpen), 
										  .full(allFUll), 
										  .ones(pennies), 
										  .tens(dimes), 
										  .led0(HEX0), 
										  .led1(HEX1), 
										  .led2(HEX2), 
										  .led3(HEX3), 
										  .led4(HEX4), 
										  .led5(HEX5));
endmodule 

//DE1_SoC_testbench tests all expected, unexpected, and edgecase behavior that the parking
//lot sensor system implemented in the lab. This module tests for a pedestrian walking through
//the sensors into the lot, then the module has 5 cars enter the lot to reach the max, followed
//by 5 cars exiting the lot to show the lots be empty.
module DE1_SoC_testbench();
		logic				CLOCK_50;
		wire [33:0]		GPIO_0;
		logic [6:0]		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		
		logic reset, a, b;
		
		DE1_SoC dut(.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .GPIO_0, .CLOCK_50);
		
		parameter CLOCK_PERIOD = 100;            
		initial begin                
				CLOCK_50 <= 0;
				forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;// Forever toggle the clock     
		end
		
		assign GPIO_0[5] = reset;
		assign GPIO_0[6] = a;
		assign GPIO_0[7] = b;
		
		initial		begin
			a <= 0; b <= 0;			repeat(1)    @(posedge    CLOCK_50);
			reset <= 1;					repeat(1)    @(posedge    CLOCK_50);
			reset <= 0;					repeat(1)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);  //Pedestrians
			a <= 0; b <= 1;			repeat(1)    @(posedge    CLOCK_50);
			//b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);
											repeat(2)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);  //1 enter. 
											repeat(2)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);  //2 enter
											repeat(2)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);  
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);  //3 enter
											repeat(2)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);  //4 enter
											repeat(2)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);  //5 enter. Full.
											repeat(2)    @(posedge    CLOCK_50);
		   b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);  //1 exit. 4 total.
											repeat(2)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);  //2 exit. 3 total.
											repeat(2)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);  //3 exit. 2 total.
											repeat(2)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);  //4 exit. 1 total.
											repeat(2)    @(posedge    CLOCK_50);
			b <= 1;						repeat(1)    @(posedge    CLOCK_50);
			a <= 1;						repeat(1)    @(posedge    CLOCK_50);
			b <= 0;						repeat(1)    @(posedge    CLOCK_50);
			a <= 0;						repeat(1)    @(posedge    CLOCK_50);  //5 exit. 0 total. Clear.
											repeat(4)    @(posedge    CLOCK_50);
			
			$stop; // End the simulation.
	   end
endmodule
