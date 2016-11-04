`define SALT_A 32'h67452301
`define SALT_B 32'hefcdab89
`define SALT_C 32'h98badcfe
`define SALT_D 32'h10325476

module md5_pipelined(output [127:0] digest, output valid, output [127:0] value, input clk, rst, input [127:0] message, input new_message);
	reg [127:0] state_in [63:1];
	wire [127:0] state_out [63:0];
	reg [127:0] stage_message [63:1];
	reg [63:1] stage_valid;

	genvar round, phase;
	generate
		for( round = 0; round < 4; round = round + 1 ) begin: round_stage
			for( phase = 0; phase < 16; phase = phase + 1 ) begin : phase_stage
				if( (round == 0) && (phase == 0) ) 
					md5_operation md5_0(.round(round[1:0]), .phase(phase[3:0]), .message({message,384'd0}), .current_state({`SALT_A,`SALT_B,`SALT_C,`SALT_D}), .next_state(state_out[round*16+phase]));
				else
					md5_operation md5_all(.round(round[1:0]), .phase(phase[3:0]), .message({stage_message[round*16+phase],384'd0}), .current_state(state_in[round*16+phase]), .next_state(state_out[round*16+phase]));
			end
		end
	endgenerate

	genvar i;
	generate
		for( i = 1; i < 64; i = i + 1 ) begin : messages
			always @ (posedge clk) begin
				if( i == 1 )
					stage_message[1] <= message;
				else begin
					stage_message[i] <= stage_message[i-1];
					if( ~stage_valid[62] )
						stage_message[63] <= stage_message[63];
				end
				state_in[i] <= state_out[i-1];
				if( ~stage_valid[62] )
					state_in[63] <= state_in[63];
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if( rst ) begin
			stage_valid <= 63'd0;
		end
		else begin
			if( stage_valid[62] )
				stage_valid <= {stage_valid[62:1], new_message};
			else
				stage_valid <= {stage_valid[63], stage_valid[61:1], new_message};
		end
	end

	assign digest = { state_out[63][127:96]+`SALT_A, state_out[63][95:64]+`SALT_B, state_out[63][63:32]+`SALT_C, state_out[63][31:0]+`SALT_D};
	assign valid = stage_valid[63];
	assign value = stage_message[63];
endmodule
