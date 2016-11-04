`define SALT_A 32'h67452301
`define SALT_B 32'hefcdab89
`define SALT_C 32'h98badcfe
`define SALT_D 32'h10325476

module md5_single_cycle(output [127:0] digest, output valid, output [127:0] value, input clk, rst, input [127:0] message, input new_message);
	wire [511:0] padded_message;
	wire [127:0] state [64:0];

	genvar round, phase;
	generate
		for( round = 0; round < 4; round = round + 1 ) begin: round_stage
			for( phase = 0; phase < 16; phase = phase + 1 ) begin : phase_stage
				md5_operation md5(.round(round[1:0]), .phase(phase[3:0]), .message(padded_message), .current_state(state[round*16+phase]), .next_state(state[round*16+phase+1]));
			end
		end
	endgenerate

	assign state[0] = {`SALT_A, `SALT_B, `SALT_C, `SALT_D};
	assign digest = { state[64][127:96]+`SALT_A, state[64][95:64]+`SALT_B, state[64][63:32]+`SALT_C, state[64][31:0]+`SALT_D};
	assign padded_message = {message, 384'd0};
	assign value = message;
	assign valid = 1;
endmodule
