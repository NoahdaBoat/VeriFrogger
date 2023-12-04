
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module toplevel(

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);



//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================

wire clk = CLOCK_50;
    //wire go = !KEY[0];
	 wire go_start = !KEY[2];
    wire reset = !KEY[3];
    //wire rnd_reset = !KEY[1];
    //wire enable = !KEY[2];
	 wire hungerenable;// = SW[0];
	 wire boredenable;// = SW[1];
	wire sickenable;// = SW[2];
	wire dirtyenable;// = SW[3];
	wire dyingenable;// = SW[4];
	wire zzzsenable;// = SW[5];
	wire deceased;
	wire soundOff = SW[9];
	wire soundVol = !SW[8];
	reg snd;
	wire [3:0] age;
	wire done_moving;
	
	
	wire foodGiven = SW[0]; //&& !KEY[0];
	wire ballGiven = SW[1]; //&& !KEY[0];
	wire broomGiven = SW[2]; //&& !KEY[0];
	wire pillsGiven = SW[3]; //&& !KEY[0];
	wire firstAidGiven = SW[4]; //&& !KEY[0];
	

    wire draw_scrn_start, draw_scrn_game_bg;
    wire move_objects;
	 wire draw_hungerbubble;
	 wire play_hungerbubble;
    wire plot_done;
	 wire draw_boredbubble;
	wire draw_sickbubble;
	wire draw_dirtybubble;
	wire draw_dyingbubble;
	wire draw_gameover;
	wire draw_zzzs;
	wire draw_ball;
	wire draw_food;
	wire draw_broom;
	wire draw_pills;
	wire draw_firstAid;

    wire plot;
    wire [8:0] x, y;
    wire [2:0] color;
	 wire [8:0] lifeCounter;

	 // VGA wires.
    //wire VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    //wire [9:0] VGA_R, VGA_G, VGA_B;
	 
	// Audio \\
     wire [4:0] current_state;
	  wire [4:0] music_type;
	
	  
	// Audio Wires
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;
	
	wire [18:0] delay15 = 19'b0000_000_101110111000; // Do not use
	wire [18:0] delay14 = 19'b0001_000_101110111000; //~F
	wire [18:0] delay13 = 19'b0010_000_101110111000; //~F#
	wire [18:0] delay12 = 19'b0011_000_101110111000; //~B
	wire [18:0] delay11 = 19'b0100_000_101110111000; //~F#
	wire [18:0] delay10 = 19'b0101_000_101110111000; //~D
	wire [18:0] delay9 = 19'b0110_000_101110111000;  //~B
	wire [18:0] delay8 = 19'b0111_000_101110111000;  //~A
	wire [18:0] delay7 = 19'b1000_000_101110111000;  //~F#
	wire [18:0] delay6 = 19'b1001_000_101110111000;  //~E
	wire [18:0] delay5 = 19'b1010_000_101110111000;  //~D
	wire [18:0] delay4 = 19'b1011_000_101110111000;  //~C#
	wire [18:0] delay3 = 19'b1100_000_101110111000;  //~B
	wire [18:0] delay2 = 19'b1101_000_101110111000;  //~Bf
	wire [18:0] delay1 = 19'b1110_000_101110111000;  //~A
	wire [18:0] delay0 = 19'b1111_000_101110111000;  //~G
	
	reg soundEnable = 1;
	
	reg [18:0] delay_cnt;
	reg [18:0] delay = 19'b0011_000_101110111000;
	
	 //wire [25:0] timer_limit = 26'd3000000;
	 wire [25:0] timer_limit = 26'd60000000; // 2 second audio loop
    reg [26:0] timer_count = 0;
	 reg [4:0] count = 0; //debug
	 
	
	wire [31:0] sound = (!soundEnable || soundOff) ? 0 : snd ? 32'd10000000 : -32'd10000000;
	wire [31:0] soundq = (!soundEnable || soundOff) ? 0 : snd ? 32'd6000000 : -32'd6000000;

	// Loop for 1/2 second timer
  
	always@(posedge CLOCK_50) begin
		
		// Main square wave oscillator
		if(delay_cnt == delay) begin
			delay_cnt <= 0;
			snd <= !snd;
		end else delay_cnt <= delay_cnt + 1;
		
		// All sounds are combinations of 8 on/off tones
		 if (timer_count >= timer_limit)
		 begin
			timer_count <= 0;
			count <= 0; //debug
		 end
		 else
			timer_count <= timer_count + 1;

		 if ((timer_count >= 0) && (timer_count < timer_limit / 8))
		 begin
				count <= 1; //debug
				if (hungerenable) begin
					soundEnable <= 1;
					delay <= delay13;
				end else if (boredenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (sickenable) begin
					soundEnable <= 1;				
					delay <= delay4;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 1;				
					delay <= delay7;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (zzzsenable) begin
					soundEnable <= 1;
					delay <= delay2;
					delay <= delay - 5000;
				end else begin
					soundEnable <= 1;
					delay <= delay9;
				end
				//delay <= delay + 3000000;
		 end
		 if ((timer_count >= timer_limit / 8 ) && (timer_count < timer_limit / 4))
		 begin
				count <= 2; //debug
				if (hungerenable) begin
					soundEnable <= 1;
					delay <= delay13;
				end else if (boredenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (sickenable) begin
					soundEnable <= 1;				
					delay <= delay6;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 0;				
					delay <= delay3;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (zzzsenable) begin
					soundEnable <= 1;
					delay <= delay2;
					delay <= delay - 5000;
				end else begin
					soundEnable <= 0;
					delay <= delay9;
				end
				//delay <= delay + 3000000;
		 end
		if ((timer_count >= timer_limit / 4) && (timer_count < ((timer_limit / 8) * 3)))
		begin
				count <= 3; //debug
				if (hungerenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (boredenable) begin
					soundEnable <= 0;
					delay <= delay5;
				end else if (sickenable) begin
					soundEnable <= 1;				
					delay <= delay8;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 0;				
					delay <= delay7;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (zzzsenable) begin
					soundEnable <= 0;
					delay <= delay1;
				end else begin
					soundEnable <= 1;
					delay <= delay11;
				end
				//delay <= delay + 3000000;
		end
		if ((timer_count >= ((timer_limit / 8) * 3)) && (timer_count < timer_limit / 2))
		begin
				count <= 4; //debug
				if (hungerenable) begin
					soundEnable <= 0;
					delay <= delay8;
				end else if (boredenable) begin
					soundEnable <= 0;
					delay <= delay5;
				end else if (sickenable) begin
					soundEnable <= 1;				
					delay <= delay10;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 0;				
					delay <= delay3;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay12;
				end else if (zzzsenable) begin
					soundEnable <= 0;
					delay <= delay1;
				end else begin
					soundEnable <= 0;
					delay <= delay7;
				end
				//delay <= delay + 3000000;
		end
		if ((timer_count > timer_limit / 2) && (timer_count < ((timer_limit / 8) * 5)))
		 begin
				count <= 5; //debug
				if (hungerenable) begin
					soundEnable <= 1;
					delay <= delay11;
				end else if (boredenable) begin
					soundEnable <= 13;
					delay <= delay5;
				end else if (sickenable) begin
					soundEnable <= 0;				
					delay <= delay4;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 1;				
					delay <= delay6;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay13;
				end else if (zzzsenable) begin
					soundEnable <= 0;
					delay <= delay1;
				end else begin
					soundEnable <= 1;
					delay <= delay9;
				end
				//delay <= delay + 3000000;
		 end
		 if ((timer_count >= ((timer_limit / 8) * 5)) && (timer_count < ((timer_limit / 4) * 3)))
		 begin
				count <= 6; //debug
				if (hungerenable) begin
					soundEnable <= 0;
					delay <= delay6;
				end else if (boredenable) begin
					soundEnable <= 13;
					delay <= delay5;
				end else if (sickenable) begin
					soundEnable <= 0;				
					delay <= delay4;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 1;				
					delay <= delay6;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay13;
				end else if (zzzsenable) begin
					soundEnable <= 0;
					delay <= delay1;
				end else begin
					soundEnable <= 0;
					delay <= delay7;
				end
				//delay <= delay + 3000000;
		 end
		if ((timer_count >= ((timer_limit / 4) * 3)) && (timer_count < ((timer_limit / 8) * 7)))
		begin
				count <= 7; //debug
				if (hungerenable) begin
					soundEnable <= 0;
					delay <= delay6;
				end else if (boredenable) begin
					soundEnable <= 0;
					delay <= delay5;
				end else if (sickenable) begin
					soundEnable <= 0;				
					delay <= delay4;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 1;				
					delay <= delay3;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay13;
				end else if (zzzsenable) begin
					soundEnable <= 0;
					delay <= delay1;
				end else begin
					soundEnable <= 1;
					delay <= delay7;
				end
				//delay <= delay + 3000000;
		end
		if ((timer_count >= ((timer_limit / 8) * 7)) && (timer_count < timer_limit))
		begin
				count <= 8; //debug
				if (hungerenable) begin
					soundEnable <= 0;
					delay <= delay6;
				end else if (boredenable) begin
					soundEnable <= 0;
					delay <= delay5;
				end else if (sickenable) begin
					soundEnable <= 0;				
					delay <= delay4;
					delay <= delay + 3000000;
				end else if (dirtyenable) begin
					soundEnable <= 0;				
					delay <= delay3;
				end else if (dyingenable) begin
					soundEnable <= 1;
					delay <= delay13;
				end else if (zzzsenable) begin
					soundEnable <= 0;
					delay <= delay1;
				end else begin
					soundEnable <= 0;
					delay <= delay7;
				end
				//delay <= delay + 3000000;
		end
	 end
	 
assign read_audio_in			= audio_in_available & audio_out_allowed;

//assign left_channel_audio_out	= left_channel_audio_in+sound;
assign left_channel_audio_out	= soundVol ? sound : soundq;
assign right_channel_audio_out	= soundVol ? sound : soundq;
assign write_audio_out			= audio_in_available & audio_out_allowed;

	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		//.reset						(~KEY[0]),
		.reset						(0),

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(0)) avc (
		.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(0)
	);

	  
	  hex_decoder h0 (.c(current_state[3:0]), .display(HEX0));
     hex_decoder h1 (.c(current_state[4:4]), .display(HEX1));
	  hex_decoder h2 (.c(count[3:0]), .display(HEX2));
     hex_decoder h3 (.c(count[4:4]), .display(HEX3));
	  hex_decoder h4 (.c(age[3:0]), .display(HEX4));
	  hex_decoder h5 (.c(lifeCounter[3:0]), .display(HEX5));
	  
	  //assign LEDR[3] = soundHigh;
	  //assign LEDR[0] = draw_ball;
	  //assign LEDR[1] = soundDone;
	  //assign LEDR[2] = soundHungry;
	  //assign LEDR[4] = soundEnable;
	  //assign LEDR[5] = !enable;
	  
    datapath d0 (
        .clk(clk), .reset(reset),
		  .hungry(hungerenable), .bored(boredenable), .sick(sickenable), .dirty(dirtyenable), .dying(dyingenable), .deceased(deceased), .sleeping(zzzsenable), .age(age),
		  .foodGiven(foodGiven), .ballGiven(ballGiven), .broomGiven(broomGiven), .pillsGiven(pillsGiven), .firstAidGiven(firstAidGiven),
		  .draw_scrn_start(draw_scrn_start),
		  .draw_scrn_game_bg(draw_scrn_game_bg),
		  .draw_hungerbubble(draw_hungerbubble),
		  .draw_boredbubble(draw_boredbubble),
		  .draw_sickbubble(draw_sickbubble),
		  .draw_dyingbubble(draw_dyingbubble),
		  .draw_zzzs(draw_zzzs),
		  .draw_ball(draw_ball),
		  .draw_food(draw_food),
		  .draw_broom(draw_broom),
		  .draw_pills(draw_pills),
		  .draw_firstAid(draw_firstAid),
		  .draw_gameover(draw_gameover),
		  .draw_dirtybubble(draw_dirtybubble),
        .move_objects(move_objects),
        
        .nextframe(frame_tick),
		  .lifeCounter(lifeCounter),

        .plot_done(plot_done),

        .plot(plot), .x(x), .y(y), .color(color),
		  .done_moving(done_moving)
    );

    control c0 (
        .clk(clk), .reset(reset),

        .go(1), .plot_done(plot_done), .go_start(go_start),

        .frame_tick(frame_tick),
		  .done_moving(done_moving),
		  .ballGiven(ballGiven),
		  .foodGiven(foodGiven),
		  .broomGiven(broomGiven),
		  .pillsGiven(pillsGiven),
		  .firstAidGiven(firstAidGiven),
		  .deceased(deceased),
		   .hungerenable(hungerenable), .boredenable(boredenable), .sickenable(sickenable), .dirtyenable(dirtyenable), .dyingenable(dyingenable),
			.zzzsenable(zzzsenable),
        .draw_scrn_start(draw_scrn_start),
		  .draw_scrn_game_bg(draw_scrn_game_bg),
		  .draw_hungerbubble(draw_hungerbubble),
		  .draw_boredbubble(draw_boredbubble),
		.draw_sickbubble(draw_sickbubble),
		.draw_dirtybubble(draw_dirtybubble),
		.draw_dyingbubble(draw_dyingbubble),
		.draw_zzzs(draw_zzzs),
		.draw_ball(draw_ball),
		.draw_food(draw_food),
		.draw_broom(draw_broom),
		.draw_pills(draw_pills),
		.draw_firstAid(draw_firstAid),
		.draw_gameover(draw_gameover),
        .move_objects(move_objects),
		  .current_state(current_state)
        
    );

	vga_adapter #(
	     .RESOLUTION("320x240"),
        .MONOCHROME("FALSE"),
        .BITS_PER_COLOUR_CHANNEL(1)
        //.BACKGROUND_IMAGE("image.colour.mif")
		  ) vga (
			.resetn(!reset),
			.clock(CLOCK_50),
			.colour(color),
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

endmodule
