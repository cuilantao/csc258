// Part 2 skeleton

module Project
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		LEDR,
		HEX0,
		HEX1,
		HEX2,
		HEX3
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [6:0] HEX0, HEX1, HEX2, HEX3;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output   [9:0] LEDR;
	
	wire resetn;
	assign resetn = KEY[0];
	assign LEDR[0] = finish_game;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire ldx;
	wire ldy;
	wire writeEn;
	wire finish_dino;
	wire draw;
	wire count_enable;
	wire erase;
	wire change;
	wire finish_erase;
	wire finish_ground;
	wire is_jump;
	wire draw_ground;
	wire ld_ground;
	wire [7:0] score;
	wire frame_updated;
	wire frame_counter;
	wire menu_enable;
	wire enable_count_ground;
	wire dino_frame_counter;
	wire finish_obstacle;
	wire finish_game;
	wire random;
	wire ld_menu;
	wire finish_menu;
	wire draw_menu;
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
	datapath d0(
					.clk(CLOCK_50),
					.ld_x(ldx),
					.ld_y(ldy),
					.ld_ground(ld_ground),
					.draw_ground(draw_ground),
					.finish_ground(finish_ground),
					.reset_n(resetn),
					.is_erase(erase),
					.is_change(change),
					.x_out(x),
					.random(random),
					.y_out(y),
					.shape(SW[0]),
					.ld_menu(ld_menu),
					.finish_menu(finish_menu),
					.color_out(colour),
					.jump(KEY[2]),
					.color_in(SW[3:1]),
					.score(score),
					.finish_dino(finish_dino),
					.menu_enable(menu_enable),
					.finish_erase(finish_erase),
					.draw(draw),
					.draw_menu(draw_menu),
					.finish_game(finish_game),
					.is_jump(is_jump),
					.finish_obstacle(finish_obstacle),
					.count_enable(count_enable),
					.frame_counter(frame_counter),
					.enable_count_ground(enable_count_ground),
					.frame_updated(frame_updated),
					.dino_frame_counter(dino_frame_counter));

    control c0(
				.clk(CLOCK_50),
				.reset_n(resetn),
				.go(KEY[1]),
				.start_menu(KEY[3]),
				.finish_erase(finish_erase),
				.ld_ground(ld_ground),
				.draw_ground(draw_ground),
				.finish_ground(finish_ground),
				.ld_x(ldx),
				.is_jump(is_jump),
				.ld_y(ldy),
				.draw_menu(draw_menu),
				.finish_obstacle(finish_obstacle),
				.writeEn(writeEn),
				.menu_enable(menu_enable),
				.draw(draw),
				.finish_dino(finish_dino),
				.ld_menu(ld_menu),
				.finish_menu(finish_menu),
				.count_enable(count_enable),
				.dino_frame_counter(dino_frame_counter),
				.is_erase(erase),
				.is_change(change),
				.frame_counter(frame_counter),
				.enable_count_ground(enable_count_ground),
				.frame_updated(frame_updated));
				
	lfsr r0 (
				.clk(CLOCK_50),
				.rst(!KEY[0]),
				.out(random)
				);
	hex_decoder H0(
		.hex_digit(score[3:0]),
		.segments(HEX0)
	);
	hex_decoder H1(
		.hex_digit(score[7:4]),
		.segments(HEX1)
	);
	hex_decoder H2(
		.hex_digit(4'b0000),
		.segments(HEX2)
	);
	hex_decoder H3(
		.hex_digit(4'b0110),
		.segments(HEX3)
	);
    
endmodule


module datapath
	(
		input clk,
		input ld_x, ld_y,
		input draw,
		input count_enable,
		input shape,
		input menu_enable,
		input frame_counter,
		input reset_n,
		input is_erase,
		input is_change,
		input dino_frame_counter,
		input draw_ground,
		input jump,
		input [3:0] random,
		input enable_count_ground,
		input ld_ground,
		input [2:0] color_in,
		input ld_menu,
		input draw_menu,
		output finish_menu,
		output reg finish_ground,
		output [7:0] x_out,
		output [6:0] y_out,
		output [2:0] color_out,
		output finish_dino,
		output reg finish_game,
		output finish_obstacle,
		output reg finish_erase,
		output reg frame_updated,
		output reg is_jump,
		output reg [7:0] score
	);
	reg [4:0] count;
	reg [4:0] menu_count;
	wire enable_frame;
	reg [2:0] frame_count;
	reg [27:0] frame_counter_value;
	reg [27:0] dino_counter_value;
	reg [2:0] count_x, count_y;
	reg [7:0] count_ground;
	reg [7:0] x;
	reg [6:0] y;
	reg [7:0] erase_x;
	reg [27:0] box_frame_counter;
	reg [27:0] score_counter;
	reg [6:0] erase_y;
	reg [7:0] x_orig;
	reg [6:0] y_orig;
	reg [7:0] x_menu;
	reg [6:0] y_menu;
	reg [6:0] obstacle;
	reg [6:0] y_ground;
	reg [2:0] color;
	reg [7:0] box_x_orig;
	reg [6:0] box_y_orig;
	reg [3:0] erase_box_x;
	reg [6:0] constant;
	reg [3:0] erase_box_y;
	reg is_moving_box;
	reg update_box;
	reg dir;
	reg top_bound;
	reg one_cycle;
	reg start_obstacle;
	reg finish_erase_box;
	reg enable_count_obstacle;
	//frame counter
	always @(posedge clk) begin
		if (!reset_n)
			frame_counter_value <= 28'd0;
		else if(frame_counter_value == 28'd250000)
			frame_counter_value <= 28'd0;
		else if(frame_counter == 1'b1)
			frame_counter_value <= frame_counter_value + 1'b1;
	end
	
	assign finish_obstacle = (frame_counter_value == 28'd250000) ? 1 : 0;
	
	always @(posedge clk) begin
		if (!reset_n)
			dino_counter_value <= 28'd0;
		else if(dino_counter_value == 28'd250000)
			dino_counter_value <= 28'd0;
		else if(dino_frame_counter == 1'b1)
			dino_counter_value <= dino_counter_value + 1'b1;
	end
	
	assign finish_dino = (dino_counter_value == 28'd250000) ? 1 : 0;
	
	
	//jump
	always @(posedge clk) begin
		if (!reset_n) begin
			is_jump <= 1'b0;
			is_moving_box <= 1'b0;
			start_obstacle <= 1'b0;
			enable_count_obstacle <= 1'b0;
		end
		else if (one_cycle == 1'b1) begin
			is_jump <= 1'b0;
			end
		else if (!jump) begin
			is_jump <= 1'b1;
			is_moving_box <= 1'b1;
			start_obstacle <= 1'b1;
			enable_count_obstacle <= 1'b1;
		end
	end 
	
//	always @(posedge clk) begin
//		if (!reset_n)
//			frame_count <= 3'd0;
//		else if(frame_count == 3'd5)
//			frame_count <= 3'd0;
//		else if(enable_frame == 1'b1)
//			frame_count <= frame_count + 1'b1;
//	end
//	
//	assign finish_dino = (frame_count == 3'd5) ? 1 : 0;

	always @(posedge clk) begin
		if(!reset_n) begin
			score_counter <= 28'd0;
			score <= 8'b0;
		end
		if (score_counter == 28'd50000000) begin
			if (finish_game) begin
				score_counter <= 28'd0;
				score <= score + 1;
			end
			else
				score_counter <= 28'd0;
		end
		else if(is_moving_box) begin
		begin
			score_counter <= score_counter + 1;
		end
	end
	end
	
	always @(posedge clk) begin
		if(!reset_n) begin
			box_x_orig <= 8'd151;
			box_y_orig <= 7'd98;
			constant <= 7'd98;
		end
		if(is_moving_box && update_box)
			box_x_orig <= box_x_orig - 1'b1;
		if (x_orig - box_x_orig == 13)
			box_y_orig <= constant - 15*random[2:0];
	end
	
	always @(posedge clk) begin
		if(!reset_n) begin
			box_frame_counter <= 28'd0;
			update_box <= 1'b0;
		end
		if (box_frame_counter == 28'd250000) begin
			box_frame_counter <= 28'd0;
			update_box <= 1'b1;
		end
		else if(is_moving_box) begin
		if (!finish_erase_box)
		begin
			update_box <= 1'b0;
			box_frame_counter <= box_frame_counter + 1;
		end
	end
	end
	
	//drawing dino
	always @(posedge clk) begin
		if (!reset_n) begin
			finish_ground <= 1'b0;
			finish_erase_box <= 1'b0;
			count_ground <= 8'd0;
			obstacle <= 7'd0;
			count <= 5'd0;
			erase_x <= 8'd0;
			erase_y <= 7'd0;
			erase_box_x <= 4'd0;
			finish_game <= 1'b1;
			erase_box_y <= 4'd0;
			one_cycle <= 1'b0;
			top_bound <= 1'b0;
		end
		if (finish_erase)begin
			count <= 5'd0;
			finish_erase <= 1'b0;
		end
		if (count_enable) begin
			if (!shape) begin
			if (count != 31) begin
			count <= count + 1;
			end
			end
			end
		if (menu_enable) begin
			if (menu_count == 19) begin
				menu_count <= 0;
			end
			else begin
				menu_count <= menu_count + 1'b1;
			end
		end
		
		if (box_x_orig - x_orig <= 2 || x_orig - box_x_orig <= 2) begin
				if (y_orig - box_y_orig  <= 2) begin
					finish_game <= 1'b0;
				end
		end

		if (ld_x)
				x_orig <= {1'b0, 7'b0001111};
		if (ld_y)
				y_orig <= 7'b1100100;
		if (ld_ground)
				y_ground <= 7'b1101010;
		if (one_cycle)
				top_bound <= 1'b0;
		if(ld_menu) begin
			x_menu <= 8'd70;
			y_menu <= 7'd50;
		end
		if (y_orig == 7'b1100100)begin
				dir <= 1'b0;
				if (top_bound == 1'b0)
					one_cycle <= 1'b0;
				else
					one_cycle <= 1'b1;
		end
		else if (y_orig == 7'b0111100) begin
				dir <= 1'b1;
				top_bound <= 1'b1;
			end
		if (is_change) begin
			if (!dir)
				y_orig <= y_orig - 1;
			else
				y_orig <= y_orig + 1;
		end
		
		if (draw_menu) begin
			color <= 3'b111;
			if (menu_count == 0) begin
				x <= x_menu;
				y <= y_menu;
			end
			else if (menu_count == 1) begin
				x <= x_menu;
				y <= y_menu + 1'b1;
			end
			else if (menu_count == 2) begin
				x <= x_menu;
				y <= y_menu + 2'd2;
			end
			else if (menu_count == 3) begin
				x <= x_menu;
				y <= y_menu + 2'd3;
			end
			else if (menu_count == 4) begin
				x <= x_menu+3'd4;
				y <= y_menu;
			end
			else if (menu_count == 5) begin
				x <= x_menu+3'd4;
				y <= y_menu+1'b1;
			end
			else if (menu_count == 6) begin
				x <= x_menu+3'd4;
				y <= y_menu+2'd2;
			end
			else if (menu_count == 7) begin
				x <= x_menu+3'd4;
				y <= y_menu+2'd3;
			end
			else if (menu_count == 8) begin
				x <= x_menu-2'd2;
				y <= y_menu+3'd5;
			end
			else if (menu_count == 9) begin
				x <= x_menu-2'd2;
				y <= y_menu+3'd6;
			end
			else if (menu_count == 10) begin
				x <= x_menu-1'b1;
				y <= y_menu+3'd7;
			end
			else if (menu_count == 11) begin
				x <= x_menu;
				y <= y_menu+4'd8;
			end
			else if (menu_count == 12) begin
				x <= x_menu+1'b1;
				y <= y_menu+4'd8;
			end
			else if (menu_count == 13) begin
				x <= x_menu+2'd2;
				y <= y_menu+4'd8;
			end
			else if (menu_count == 14) begin
				x <= x_menu+2'd3;
				y <= y_menu+4'd8;
			end
			else if (menu_count == 15) begin
				x <= x_menu+3'd4;
				y <= y_menu+4'd8;
			end
			else if (menu_count == 16) begin
				x <= x_menu+3'd5;
				y <= y_menu+3'd7;
			end
			else if (menu_count == 17) begin
				x <= x_menu+3'd6;
				y <= y_menu+3'd6;
			end
			else if (menu_count == 18) begin
				x <= x_menu+3'd6;
				y <= y_menu+3'd5;
			end
			
			
		end
		if (draw) begin
			if (!shape) begin
			color <= 3'b111;
			if (count == 0) begin
				x <= x_orig;
				y <= y_orig;
			end
			if (count == 1) begin
				x <= x_orig-1'b1;
				y <= y_orig;
			end
			if (count == 2) begin
				x <= x_orig-2'd2;
				y <= y_orig;
			end
			if (count == 3) begin
				x <= x_orig+1'b1;
				y <= y_orig;
			end
			if (count == 4) begin
				x <= x_orig+2'd2;
				y <= y_orig;
			end
			if (count == 5) begin
				x <= x_orig;
				y <= y_orig+1'b1;
			end
			if (count == 6) begin
				x <= x_orig;
				y <= y_orig + 2'd2;
			end
			if (count == 7) begin
				x <= x_orig;
				y <= y_orig - 1'b1;
			end
			if (count == 8) begin
				x <= x_orig;
				y <= y_orig - 2'd2;
			end
			if (count == 9) begin
				x <= x_orig - 1'b1;
				y <= y_orig + 2'd3;
			end
			if (count == 10) begin
				x <= x_orig + 1'b1;
				y <= y_orig + 2'd3;
			end
			if (count == 11) begin
				x <= x_orig + 2'd2;
				y <= y_orig + 3'd4;
			end
			if (count == 12) begin
				x <= x_orig - 2'd2;
				y <= y_orig + 3'd4;
			end
			if (count == 13) begin
				x <= x_orig + 2'd3;
				y <= y_orig + 3'd5;
			end
			if (count == 14) begin
				x <= x_orig - 2'd3;
				y <= y_orig + 3'd5;
			end
			if (count == 15) begin
				x <= x_orig - 2'd2;
				y <= y_orig - 3'd6;
			end
			if (count == 16) begin
				x <= x_orig - 2'd2;
				y <= y_orig - 3'd5;
			end
			if (count == 17) begin
				x <= x_orig - 2'd2;
				y <= y_orig - 3'd4;
			end
			if (count == 18) begin
				x <= x_orig - 2'd2;
				y <= y_orig - 3'd3;
			end
			if (count == 19) begin
				x <= x_orig - 1'b1;
				y <= y_orig - 3'd6;
			end
			if (count == 20) begin
				x <= x_orig - 1'b1;
				y <= y_orig - 3'd5;

			end
			if (count == 21) begin
				x <= x_orig - 1'b1;
				y <= y_orig - 3'd4;
			end
			if (count == 22) begin
				x <= x_orig - 1'b1;
				y <= y_orig - 3'd3;
			end
			if (count == 23) begin
				x <= x_orig;
				y <= y_orig - 3'd6;
			end
			if (count == 24) begin
				x <= x_orig;
				y <= y_orig - 3'd5;
			end
			if (count == 25) begin
				x <= x_orig;
				y <= y_orig - 3'd4;
			end
			if (count == 26) begin
				x <= x_orig;
				y <= y_orig - 3'd3;
			end
			if (count == 27) begin
				x <= x_orig + 1'b1;
				y <= y_orig - 3'd6;
			end
			if (count == 28) begin
				x <= x_orig + 1'b1;
				y <= y_orig - 3'd5;
			end
			if (count == 29) begin
				x <= x_orig + 1'b1;
				y <= y_orig - 3'd4;
			end
			if (count == 30) begin
				x <= x_orig + 1'b1;
				y <= y_orig - 3'd3;
			end
			if (count == 31) begin
				if (start_obstacle) begin
					if (obstacle == 7'd64)
						obstacle <= 6'd0;
					else if (enable_count_obstacle) begin
						color <= 3'b101;
						y <= box_y_orig + obstacle[5:3];
						x <= box_x_orig + obstacle[2:0];
						obstacle <= obstacle + 1'b1;
					end
				end
			end
			end
			else begin
				if (draw)
					color <= 3'b111;
				if (count == 0) begin
					x <= x_orig;
					y <= y_orig + 2'd2;
				end
				if (count == 1) begin
					x <= x_orig - 1'b1;
					y <= y_orig + 2'd2;
				end
				if (count == 2) begin
					x <= x_orig - 2'd2;
					y <= y_orig + 2'd2;
				end
				if (count == 3) begin
					x <= x_orig;
					y <= y_orig + 2'd3;
				end
				if (count == 4) begin
					x <= x_orig - 1'b1;
					y <= y_orig + 2'd3;
				end
				if (count == 5) begin
					x <= x_orig - 2'd2;
					y <= y_orig + 2'd3;
				end
				if (count == 6) begin
					x <= x_orig;
					y <= y_orig + 3'd4;
				end
				if (count == 7) begin
					x <= x_orig - 2'd2;
					y <= y_orig + 3'd4;
				end
				if (count == 8) begin
					x <= x_orig;
					y <= y_orig + 3'd5;
				end
				if (count == 9) begin
					x <= x_orig - 2'd2;
					y <= y_orig + 3'd5;
				end
				if (count == 10) begin
					x <= x_orig + 1'b1;
					y <= y_orig + 1'b1;
				end
				if (count == 11) begin
					x <= x_orig + 2'd2;
					y <= y_orig + 1'b1;
				end
				if (count == 12) begin
					x <= x_orig + 1'b1;
					y <= y_orig;
				end
				if (count == 13) begin
					x <= x_orig + 2'd2;
					y <= y_orig;
				end
				if (count == 14) begin
					x <= x_orig;
					y <= y_orig + 2'd3;
			end
			end
		end
		else if (draw_ground) begin
			if (count_ground == 8'd159) begin
				finish_ground <= 1'b1;
				count_ground <= 8'd0;
			end
			else if (enable_count_ground)begin
				color <= color_in;
				x <= count_ground;
				y <= y_ground;
				count_ground <= count_ground + 1'b1;
			end
		end
		else if(is_erase) begin
			color <= 3'b000;
			if(erase_y == 7'd106) begin
				finish_erase <= 1'b1;
				erase_y <= 7'd0;
				erase_x <= 8'd0;
			end
			else if(erase_x == 8'd160) begin
				erase_x <= 8'd0;
				erase_y <= erase_y + 1'b1;
			end
			else begin
				erase_x <= erase_x + 1'b1;
			x <= erase_x;
			y <= erase_y;
			end
		end
//		else if (erase_box && update_box) begin
//			color <= 3'b000;
//			if(erase_box_y == 4'd8)begin
//				finish_erase_box <= 1'b1;
//				erase_box_y <= 4'd0;
//				erase_box_x <= 4'd0;
//			end
//			else if(erase_box_x == 4'd8)begin
//				finish_erase_box <= 1'b0;
//				erase_box_x <= 4'd0;
//				erase_box_y <= erase_box_y + 1'b1;
//			end
//			else begin
//				finish_erase_box <= 1'b0;
//				erase_box_x <= erase_box_x + 1'b1;
//				x <= box_x_orig + erase_box_x;
//				y <= box_y_orig + erase_box_y;
//			end
//		end
		
			else begin
				if (start_obstacle) begin
					color <= 3'b000;
					if (obstacle == 7'd64)begin
						obstacle <= 6'd0;
					end
					else if (enable_count_obstacle) begin
						color <= 3'b101;
						y <= box_y_orig + obstacle[5:3];
						x <= box_x_orig + obstacle[2:0];
						obstacle <= obstacle + 1'b1;
					end
				end
			end
	end
	assign x_out = x; 
	assign y_out = y;
   assign color_out = color;
endmodule

module control
	(
		input clk,
		input reset_n,
		input go,
		input start_menu,
		input finish_obstacle,
		input finish_dino,
		input finish_ground,
		input frame_updated,
		input finish_erase,
		input is_jump,
		input finish_menu,
		output reg ld_x, ld_y, menu_enable, dino_frame_counter, draw_menu, ld_menu, ld_ground, enable_count_ground, draw_ground, writeEn, draw, count_enable, is_erase, is_change, frame_counter
	);
	
	reg [2:0] current_state, next_state;
	
	localparam 	start = 3'd0,
					start_wait = 3'd1,
					ground = 3'd2,
					menu = 3'd3,
					draw_dino = 3'd4,
					draw_obstacle = 3'd5,
					erase = 3'd6,
					change_x_y = 3'd7;
							
	always @(*) begin
		case (current_state)
			start: next_state = go ? start : start_wait;
			start_wait: next_state = go ? menu : start_wait;
			menu : next_state = start_menu ? menu : ground;
			ground: next_state = finish_ground ? draw_dino : ground;
			draw_dino: next_state = finish_dino ? erase : draw_dino;
			erase : begin
						if(finish_erase)begin
							if(is_jump)begin
								next_state = change_x_y;
							end
							else
								next_state = draw_dino;
						end
						end
			change_x_y : next_state = draw_dino;
			default : next_state = start;
		endcase
	end

	always @(*) begin
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_ground = 1'b0;
		ld_menu = 1'b0;
		draw_menu = 1'b0;
		writeEn = 1'b0;
		draw = 1'b0;
		count_enable = 1'b0;
		draw_ground = 1'b0;
		is_erase = 1'b0;
		dino_frame_counter = 1'b0;
		is_change = 1'b0;
		enable_count_ground = 1'b0;
		frame_counter = 1'b0;
		menu_enable = 1'b0;
		case (current_state)
			start: begin
				ld_x = 1'b1;
				ld_y = 1'b1;
			end
			start_wait: begin
				ld_x = 1'b1;
				ld_y = 1'b1;
				ld_ground =1'b1;
				ld_menu = 1'b1;
			end
			ground: begin
				draw_ground = 1'b1;
				enable_count_ground = 1'b1;
				writeEn = 1'b1;
			end
			menu: begin
				draw_menu = 1'b1;
				writeEn = 1'b1;
				menu_enable = 1'b1;
			end
			draw_dino: begin
				writeEn = 1'b1;
				dino_frame_counter = 1'b1;
				draw = 1'b1;
				count_enable = 1'b1;
				frame_counter = 1'b1;
			end
			erase: begin
				writeEn = 1'b1;
				is_erase = 1'b1;
				count_enable = 1'b1;
			end
			change_x_y: begin
				is_change = 1'b1;
			end
		endcase
	end
	
	always @(posedge clk) begin
		if (!reset_n)
			current_state <= start;
		else
			current_state <= next_state;
	end

endmodule


module lfsr (out, clk, rst);

  output reg [3:0] out;
  input clk, rst;

  wire feedback;

  assign feedback = ~(out[3] ^ out[2]);

always @(posedge clk, posedge rst)
  begin
    if (rst)
      out = 4'b0;
    else
      out = {out[2:0],feedback};
  end
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
