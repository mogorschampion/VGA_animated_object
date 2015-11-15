`timescale 1ns / 1ps

module pixelGeneration(clk, rst, push, switch, pixel_x, pixel_y, video_on, rgb);

input clk, rst;
input [3:0] push;
input [2:0] switch;
input [9:0] pixel_x, pixel_y;
input video_on;
output reg [2:0] rgb;

wire square_on, refr_tick;

//define screen size max values.
localparam MAX_X = 640;
localparam MAX_Y = 480;
//define square size and square velocity
localparam SQUARE_SIZE = 40;
localparam SQUARE_VEL = 5;

//boundaries of the square
wire [9:0] square_x_left, square_x_right, square_y_top, square_y_bottom;
reg [9:0] square_y_reg, square_y_next;
reg [9:0] square_x_reg, square_x_next;

//registers
always @(posedge clk) begin
	if(rst) begin
		square_y_reg <= 240;
		square_x_reg <= 320;
	end
	else begin
		square_y_reg <= square_y_next;
		square_x_reg <= square_x_next;
	end
end
//check screen refresh
assign refr_tick = (pixel_y ==481) && (pixel_x ==0);

//boundary circuit: assign stored values of y_top and x_left and calculate the y_bottom and x_right values by adding square size.
assign square_y_top = square_y_reg;
assign square_x_left = square_x_reg;
assign square_y_bottom = square_y_top + SQUARE_SIZE - 1;
assign square_x_right = square_x_left + SQUARE_SIZE - 1;

//rgb circuit
always @(*) begin
	rgb = 3'b000;
	if(video_on) begin
		if(square_on)
			rgb = switch;
		else
			rgb = 3'b110;
	end
end

assign square_on = ((pixel_x > square_x_left) && (pixel_x < square_x_right)) && ((pixel_y > square_y_top) && (pixel_y < square_y_bottom));

//object animation circuit
always @(*) begin
	square_y_next = square_y_reg;
	square_x_next = square_x_reg;
	if(refr_tick) begin
		if (push[0] && (square_x_right < MAX_X - 1)) begin // make sure that it stays on the screen
			square_x_next = square_x_reg + SQUARE_VEL; // right
		end 
		else if (push[1] && (square_x_left > 1 )) begin
			square_x_next = square_x_reg - SQUARE_VEL; // left
		end
		else if (push[2] && (square_y_bottom < MAX_Y - 1 )) begin
			square_y_next = square_y_reg + SQUARE_VEL; // down
		end
		else if (push[3] && (square_y_top > 1)) begin
			square_y_next = square_y_reg - SQUARE_VEL; // up
		end
	end
end

endmodule