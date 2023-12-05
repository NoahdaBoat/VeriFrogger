
//=======================================================
//	This code is generated by Terasic System Builder
//=======================================================

module toplevel(

	//////////// Audio //////////
	input								AUD_ADCDAT,
	inout								AUD_ADCLRCK,
	inout								AUD_BCLK,
	output							AUD_DACDAT,
	inout								AUD_DACLRCK,
	output							AUD_XCK,

	//////////// CLOCK //////////
	input								CLOCK2_50,
	input								CLOCK3_50,
	input								CLOCK4_50,
	input								CLOCK_50,

	//////////// SEG7 //////////
	output				[6:0]		HEX0,
	output				[6:0]		HEX1,
	output				[6:0]		HEX2,
	output				[6:0]		HEX3,
	output				[6:0]		HEX4,
	output				[6:0]		HEX5,

	//////////// KEY //////////
	input 				[3:0]		KEY,

	//////////// LED //////////
	output				[9:0]		LEDR,

	//////////// SW //////////
	input 				[9:0]		SW,

	//////////// VGA //////////
	output							VGA_BLANK_N,
	output				[7:0]		VGA_B,
	output							VGA_CLK,
	output				[7:0]		VGA_G,
	output							VGA_HS,
	output				[7:0]		VGA_R,
	output							VGA_SYNC_N,
	output							VGA_VS
);

//=======================================================
//	REG/WIRE declarations
//=======================================================

	wire clk = CLOCK_50;
	
	wire start = !KEY[2];
	wire reset = !KEY[3];
	
	wire hungerEnable;
	wire boredEnable;
	wire sickEnable;
	wire dirtyEnable;
	wire dyingEnable;
	wire zzzsEnable;
	wire deceased;
	
	wire [3:0] age;
	wire movingComplete;
	
	wire soundOff = SW[9];
	wire soundVol = !SW[8];
	wire foodGiven = SW[0];
	wire ballGiven = SW[1];
	wire broomGiven = SW[2];
	wire pillsGiven = SW[3];
	wire firstAidGiven = SW[4];
	
	wire drawStartScreen;
	wire drawGameBackground;
	wire moveSprites;
	wire drawHungerBubble;
	wire playHungerBubble;
	wire plotDone;
	wire drawBoredBubble;
	wire drawSickBubble;
	wire drawDirtyBubble;
	wire drawDyingBubble;
	wire drawGameOver;
	wire drawZzzs;
	wire drawBall;
	wire drawFood;
	wire drawBroom;
	wire drawPills;
	wire drawFirstAid;
	
	wire plot;
	wire [8:0] x;
	wire [8:0] y;
	wire [2:0] colour;
	wire [8:0] lifeCounter;

	wire [4:0] currentState;

	// Debug
	hex_decoder h0 (.c(currentState[3:0]), .display(HEX0));
	hex_decoder h1 (.c(currentState[4:4]), .display(HEX1));
	hex_decoder h4 (.c(age[3:0]), .display(HEX4));
	hex_decoder h5 (.c(lifeCounter[3:0]), .display(HEX5));

	//assign LEDR[3] = soundHigh;
	//assign LEDR[0] = drawBall;
	//assign LEDR[1] = soundDone;
	//assign LEDR[2] = soundHungry;
	//assign LEDR[4] = soundEnable;
	//assign LEDR[5] = !enable;

//=======================================================
//	Structural coding
//=======================================================

	datapath petDataPath (
		.clk(clk),
		.reset(reset),
		.hungry(hungerEnable),
		.bored(boredEnable),
		.sick(sickEnable),
		.dirty(dirtyEnable),
		.dying(dyingEnable),
		.deceased(deceased),
		.sleeping(zzzsEnable),
		.age(age),
		.foodGiven(foodGiven),
		.ballGiven(ballGiven),
		.broomGiven(broomGiven),
		.pillsGiven(pillsGiven),
		.firstAidGiven(firstAidGiven),
		.drawStartScreen(drawStartScreen),
		.drawGameBackground(drawGameBackground),
		.drawHungerBubble(drawHungerBubble),
		.drawBoredBubble(drawBoredBubble),
		.drawSickBubble(drawSickBubble),
		.drawDyingBubble(drawDyingBubble),
		.drawZzzs(drawZzzs),
		.drawBall(drawBall),
		.drawFood(drawFood),
		.drawBroom(drawBroom),
		.drawPills(drawPills),
		.drawFirstAid(drawFirstAid),
		.drawGameOver(drawGameOver),
		.drawDirtyBubble(drawDirtyBubble),
		.moveSprites(moveSprites),
		.nextFrame(frameTick),
		.lifeCounter(lifeCounter),
		.plotDone(plotDone),
		.plot(plot),
		.x(x),
		.y(y),
		.colour(colour),
		.movingComplete(movingComplete)
	);

	control petControlPath (
		.clk(clk),
		.reset(reset),
		.plotDone(plotDone),
		.start(start),
		.frameTick(frameTick),
		.movingComplete(movingComplete),
		.ballGiven(ballGiven),
		.foodGiven(foodGiven),
		.broomGiven(broomGiven),
		.pillsGiven(pillsGiven),
		.firstAidGiven(firstAidGiven),
		.deceased(deceased),
		.hungerEnable(hungerEnable),
		.boredEnable(boredEnable),
		.sickEnable(sickEnable),
		.dirtyEnable(dirtyEnable),
		.dyingEnable(dyingEnable),
		.zzzsEnable(zzzsEnable),
		.drawStartScreen(drawStartScreen),
		.drawGameBackground(drawGameBackground),
		.drawHungerBubble(drawHungerBubble),
		.drawBoredBubble(drawBoredBubble),
		.drawSickBubble(drawSickBubble),
		.drawDirtyBubble(drawDirtyBubble),
		.drawDyingBubble(drawDyingBubble),
		.drawZzzs(drawZzzs),
		.drawBall(drawBall),
		.drawFood(drawFood),
		.drawBroom(drawBroom),
		.drawPills(drawPills),
		.drawFirstAid(drawFirstAid),
		.drawGameOver(drawGameOver),
		.moveSprites(moveSprites),
		.currentState(currentState)
	);

	vga_adapter #(
		.RESOLUTION("320x240"),
		.MONOCHROME("FALSE"),
		.BITS_PER_COLOUR_CHANNEL(1)
		//.BACKGROUND_IMAGE("image.colour.mif")
		) vga (
			.resetn(!reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(plot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
	);
		
	music petSounds (
		.clk(clk),
		.reset(reset),
		.AUD_ADCDAT(AUD_ADCDAT),
		.AUD_BCLK(AUD_BCLK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.AUD_XCK(AUD_XCK),
		.AUD_DACDAT(AUD_DACDAT),
			
		.hungerEnable(hungerEnable),
		.boredEnable(boredEnable),
		.sickEnable(sickEnable),
		.dirtyEnable(dirtyEnable),
		.dyingEnable(dyingEnable),
		.zzzsEnable(zzzsEnable),
		.soundOff(soundOff),
		.soundVol(soundVol)
	);

endmodule
