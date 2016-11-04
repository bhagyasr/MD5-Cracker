`define SALT_A 32'h67452301
`define SALT_B 32'hefcdab89
`define SALT_C 32'h98badcfe
`define SALT_D 32'h10325476

// MD5 basic operation for EECE 643 Lab 3, Spring 2015.
//
// For Lab 3, compute an MD5 digest by performing the following steps:
// 1) Pad the message to 512 bits with zeros. The 128-bit message should be in
//   message[511:128] and the rest should be 0.
// 2) Perform 16 phases for each of the 4 rounds using the md5_operation
//   module. Start with round 0, phase 0 and end with round 3, phase 15.
//   Complete all 15 phases, in numerical order, of round N before moving to round N+1.
//   2.a] The initial input should be {`SALT_A, `SALT_B, `SALT_C, `SALT_D}.
//   2.b] The input to subsequent operations is the output of the previous operation.
// 3) If the output of the final operation is {A,B,C,D}, then the digest
//   equals {A+`SALT_A, B+`SALT_B, C+`SALT_C, D+`SALT_D}.
//
// Note that the final result is not a true MD5 digest due to byte ordering
// and incorrect message padding.
//
module md5_operation(input [1:0] round, input [3:0] phase, input [511:0] message, input [127:0] current_state, output [127:0] next_state);

	assign next_state = {current_state[31:0], round_operation(round, phase, message, current_state), current_state[95:32]};

	function [4:0] S(input [1:0] round, input [3:0] phase);
		case({round,phase[1:0]})
			// Round 1 (00)
			4'b00_00: S = 5'd7;
			4'b00_01: S = 5'd12;
			4'b00_10: S = 5'd17;
			4'b00_11: S = 5'd22;
			// Round 2 (01)
			4'b01_00: S = 5'd5;
			4'b01_01: S = 5'd9;
			4'b01_10: S = 5'd14;
			4'b01_11: S = 5'd20;
			// Round 3 (10)
			4'b10_00: S = 5'd4;
			4'b10_01: S = 5'd11;
			4'b10_10: S = 5'd16;
			4'b10_11: S = 5'd23;
			// Round 4 (11)
			4'b11_00: S = 5'd6;
			4'b11_01: S = 5'd10;
			4'b11_10: S = 5'd15;
			4'b11_11: S = 5'd21;
		endcase
	endfunction

	function [3:0] K(input [1:0] round, input [3:0] phase);
		case( {round, phase} )
			// Round 1 (00)
			// K = phase
			6'b00_0000: K = 4'd0; 
			6'b00_0001: K = 4'd1; 
			6'b00_0010: K = 4'd2; 
			6'b00_0011: K = 4'd3; 
			6'b00_0100: K = 4'd4; 
			6'b00_0101: K = 4'd5; 
			6'b00_0110: K = 4'd6; 
			6'b00_0111: K = 4'd7; 
			6'b00_1000: K = 4'd8; 
			6'b00_1001: K = 4'd9; 
			6'b00_1010: K = 4'd10; 
			6'b00_1011: K = 4'd11; 
			6'b00_1100: K = 4'd12; 
			6'b00_1101: K = 4'd13; 
			6'b00_1110: K = 4'd14; 
			6'b00_1111: K = 4'd15; 
			// Round 2 (01)
			// K = (phase*5 + 1)%16;
			6'b01_0000: K = 4'd1; 
			6'b01_0001: K = 4'd6; 
			6'b01_0010: K = 4'd11; 
			6'b01_0011: K = 4'd0; 
			6'b01_0100: K = 4'd5; 
			6'b01_0101: K = 4'd10; 
			6'b01_0110: K = 4'd15; 
			6'b01_0111: K = 4'd4; 
			6'b01_1000: K = 4'd9; 
			6'b01_1001: K = 4'd14; 
			6'b01_1010: K = 4'd3; 
			6'b01_1011: K = 4'd8; 
			6'b01_1100: K = 4'd13; 
			6'b01_1101: K = 4'd2; 
			6'b01_1110: K = 4'd7; 
			6'b01_1111: K = 4'd12; 
			// Round 3 (10)
			// K = (phase*3 + 5)%16;
			6'b10_0000: K = 4'd5; 
			6'b10_0001: K = 4'd8; 
			6'b10_0010: K = 4'd11; 
			6'b10_0011: K = 4'd14; 
			6'b10_0100: K = 4'd1; 
			6'b10_0101: K = 4'd4; 
			6'b10_0110: K = 4'd7; 
			6'b10_0111: K = 4'd10; 
			6'b10_1000: K = 4'd13; 
			6'b10_1001: K = 4'd0; 
			6'b10_1010: K = 4'd3; 
			6'b10_1011: K = 4'd6; 
			6'b10_1100: K = 4'd9; 
			6'b10_1101: K = 4'd12; 
			6'b10_1110: K = 4'd15; 
			6'b10_1111: K = 4'd2; 
			// Round 4 (11)
			// K = (phase*7)%16
			6'b11_0000: K = 4'd0; 
			6'b11_0001: K = 4'd7; 
			6'b11_0010: K = 4'd14; 
			6'b11_0011: K = 4'd5; 
			6'b11_0100: K = 4'd12; 
			6'b11_0101: K = 4'd3; 
			6'b11_0110: K = 4'd10; 
			6'b11_0111: K = 4'd1; 
			6'b11_1000: K = 4'd8; 
			6'b11_1001: K = 4'd15; 
			6'b11_1010: K = 4'd6; 
			6'b11_1011: K = 4'd13; 
			6'b11_1100: K = 4'd4; 
			6'b11_1101: K = 4'd11; 
			6'b11_1110: K = 4'd2; 
			default:    K = 4'd9; 
		endcase
	endfunction

	function [31:0] T(input [1:0] round, input [3:0] phase);
		case( {round, phase} )
			// Round 1 (00)
			6'b00_0000: T = 32'hd76aa478;
			6'b00_0001: T = 32'he8c7b756;
			6'b00_0010: T = 32'h242070db;
			6'b00_0011: T = 32'hc1bdceee;
			6'b00_0100: T = 32'hf57c0faf;
			6'b00_0101: T = 32'h4787c62a;
			6'b00_0110: T = 32'ha8304613;
			6'b00_0111: T = 32'hfd469501;
			6'b00_1000: T = 32'h698098d8;
			6'b00_1001: T = 32'h8b44f7af;
			6'b00_1010: T = 32'hffff5bb1;
			6'b00_1011: T = 32'h895cd7be;
			6'b00_1100: T = 32'h6b901122;
			6'b00_1101: T = 32'hfd987193;
			6'b00_1110: T = 32'ha679438e;
			6'b00_1111: T = 32'h49b40821;
			// Round 2 (01)
			6'b01_0000: T = 32'hf61e2562;
			6'b01_0001: T = 32'hc040b340;
			6'b01_0010: T = 32'h265e5a51;
			6'b01_0011: T = 32'he9b6c7aa;
			6'b01_0100: T = 32'hd62f105d;
			6'b01_0101: T = 32'h02441453;
			6'b01_0110: T = 32'hd8a1e681;
			6'b01_0111: T = 32'he7d3fbc8;
			6'b01_1000: T = 32'h21e1cde6;
			6'b01_1001: T = 32'hc33707d6;
			6'b01_1010: T = 32'hf4d50d87;
			6'b01_1011: T = 32'h455a14ed;
			6'b01_1100: T = 32'ha9e3e905;
			6'b01_1101: T = 32'hfcefa3f8;
			6'b01_1110: T = 32'h676f02d9;
			6'b01_1111: T = 32'h8d2a4c8a;
			// Round 3 (10)
			6'b10_0000: T = 32'hfffa3942;
			6'b10_0001: T = 32'h8771f681;
			6'b10_0010: T = 32'h6d9d6122;
			6'b10_0011: T = 32'hfde5380c;
			6'b10_0100: T = 32'ha4beea44;
			6'b10_0101: T = 32'h4bdecfa9;
			6'b10_0110: T = 32'hf6bb4b60;
			6'b10_0111: T = 32'hbebfbc70;
			6'b10_1000: T = 32'h289b7ec6;
			6'b10_1001: T = 32'heaa127fa;
			6'b10_1010: T = 32'hd4ef3085;
			6'b10_1011: T = 32'h04881d05;
			6'b10_1100: T = 32'hd9d4d039;
			6'b10_1101: T = 32'he6db99e5;
			6'b10_1110: T = 32'h1fa27cf8;
			6'b10_1111: T = 32'hc4ac5665;
			// Round 4 (11)
			6'b11_0000: T = 32'hf4292244;
			6'b11_0001: T = 32'h432aff97;
			6'b11_0010: T = 32'hab9423a7;
			6'b11_0011: T = 32'hfc93a039;
			6'b11_0100: T = 32'h655b59c3;
			6'b11_0101: T = 32'h8f0ccc92;
			6'b11_0110: T = 32'hffeff47d;
			6'b11_0111: T = 32'h85845dd1;
			6'b11_1000: T = 32'h6fa87e4f;
			6'b11_1001: T = 32'hfe2ce6e0;
			6'b11_1010: T = 32'ha3014314;
			6'b11_1011: T = 32'h4e0811a1;
			6'b11_1100: T = 32'hf7537e82;
			6'b11_1101: T = 32'hbd3af235;
			6'b11_1110: T = 32'h2ad7d2bb;
			6'b11_1111: T = 32'heb86d391;
			default:    T = 32'hxxxxxxxx;
		endcase
	endfunction

	function [31:0] round_operation(input [1:0] round, input [3:0] phase, input [511:0] message, input [127:0] current_state);
		reg [31:0] a, b, c, d;
		reg [31:0] before_shift;
		begin
			{a, b, c, d} = current_state;
			case(round)
				2'b00:   before_shift = (b&c | ~b&d);   // F
				2'b01:   before_shift = (b&d | c& ~d);  // G
				2'b10:   before_shift = (b ^ c ^ d);    // H
				default: before_shift = (c ^ (b | ~d)); // I
			endcase
			before_shift = before_shift + a + message[480-32*K(round, phase) +: 32] + T(round, phase);
			round_operation = b + ((before_shift << S(round, phase)) | (before_shift >> (32-S(round, phase))));
		end
	endfunction
endmodule
