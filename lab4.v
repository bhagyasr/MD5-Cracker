module lab4(input clk, output reg [9:0] leds, output [6:0] hex5_n, hex4_n, hex3_n, hex2_n, hex1_n, hex0_n, input [9:0] sw, input [3:0] key_n);

	wire action, left, right;        // Main user buttons
	wire capture, start_crack;       // Action button results based on mode switch
	wire [127:0] target_digest;      // MD5 digest that the system is trying to find
	wire [15:0] target_digest_valid; // Which bits of the target digest are valid to display
	wire [127:0] current_digest;     // Current MD5 digest computed by the system
	wire [127:0] current_value;      // Value that generated the current MD5 digest
	wire current_digest_valid;       // Current MD5 digest is valid
	wire target_matched;             // Indicates when a match to the target digest is found
	reg counter_state;
	reg [127:0] counter_value;
	wire counter_enable;
	reg [127:0] display_value;
	reg [15:0] display_valid;
	wire [3:0] display_position;
	wire pll_locked;
	wire action_in_n, left_in_n, right_in_n, rst_n;
	reg found;
	reg [127:0] found_value;

	// Counter states
	localparam COUNTER_STATE_IDLE    = 1'b0;
	localparam COUNTER_STATE_RUNNING = 1'b1;

	// Rename the buttons
	assign {action_in_n, left_in_n, right_in_n, rst_n} = key_n;

	// Convert the main buttons to a one-time pulse
	one_time action_edge(.pulse_out(action), .clk(clk), .signal(action_in_n), .rst_n(rst_n));
	one_time left_edge(.pulse_out(left), .clk(clk), .signal(left_in_n), .rst_n(rst_n));
	one_time right_edge(.pulse_out(right), .clk(clk), .signal(right_in_n), .rst_n(rst_n));
	assign capture = action & ~sw[9];
	assign start_crack = action & sw[9];

	// Module to get the target digest from the user
	user_input user_input0(.user_data(target_digest), .user_data_valid(target_digest_valid), .window_position(display_position), .clk(clk), .rst_n(rst_n), .left(left), .right(right), .load(capture), .data_in(sw[7:0]));

	// Compare the current to the target digest
	assign target_matched = (target_digest == current_digest) && current_digest_valid;

	// Counter generation logic
	assign counter_enable = current_digest_valid && ~target_matched;
	always @ (posedge clk) begin
		if( ~rst_n ) begin
			counter_state <= COUNTER_STATE_IDLE;
			counter_value <= 128'd0;
			leds <= 10'd1;
		end
		else begin
			case( counter_state )
				COUNTER_STATE_IDLE: begin
					if( start_crack ) begin
						counter_state <= COUNTER_STATE_RUNNING;
					end
					leds <= 10'd1;
					counter_value <= 128'd0;
				end
				COUNTER_STATE_RUNNING: begin
					if( counter_enable ) begin
						counter_value <= counter_value + 128'd1;
						leds <= {leds[8:0],leds[9]};
					end
				end
			endcase
		end
	end

	// MD5 computation logic
	// Iterative (multiple cycle) solution
	//md5_iterative md5_it0(.digest(current_digest), .valid(current_digest_valid), .value(current_value), .clk(clk), .rst(~rst_n), .message(counter_value), .new_message(start_crack | counter_enable));
	//
	// Single cycle solution
	//md5_single_cycle md5_sc0(.digest(current_digest), .valid(current_digest_valid), .value(current_value), .clk(clk), .rst(~rst_n), .message(counter_value), .new_message(start_crack | counter_enable));
	//
	// Pipelined implementation
	md5_pipelined md5_pipe0(.digest(current_digest), .valid(current_digest_valid), .value(current_value), .clk(clk), .rst(~rst_n), .message(counter_value), .new_message(start_crack | counter_enable));

	// Logic to compare result and save the corresponding counter value
	always @ (posedge clk) begin
		if( ~rst_n ) begin
			found <= 1'b0;
			found_value <= 128'd0;
		end
		else begin
			if( start_crack ) begin
				found <= 1'b0;
			end
			else if( target_matched & current_digest_valid ) begin
				found <= 1'b1;
				found_value <= current_value;
			end
		end
	end

	// Mux to control what gets displayed
	always @ (*) begin
		if( sw[9] ) begin
			display_value = found_value;
			display_valid = {16{found}};
		end
		else begin
			display_value = target_digest;
			display_valid = target_digest_valid;
		end
	end
	display display0(.hex5_n(hex5_n), .hex4_n(hex4_n), .hex3_n(hex3_n), .hex2_n(hex2_n), .hex1_n(hex1_n), .hex0_n(hex0_n), .state(display_value), .state_valid(display_valid), .index(display_position));

endmodule
