module lab4_top(input clk_in, output [9:0] leds, output [6:0] hex5_n, hex4_n, hex3_n, hex2_n, hex1_n, hex0_n, input [9:0] sw, input [3:0] key_n);

	wire clk; // Internal clock after PLL
	wire pll_locked; // PLL in locked state
	wire rst_n_in;   // Reset button
	wire rst_n;      // System reset, including locked condition of PLL

	assign rst_n_in = key_n[0];
	assign rst_n = pll_locked & rst_n_in;

	// PLL circuit
	// 100 MHz is for the pipelined and, possibly, iterative implementation. Change this module for the
	// single cycle implementation to about 2.5 MHz.
	pll_100MHz pll0(.refclk(clk_in), .rst(~rst_n_in), .outclk_0(clk), .locked(pll_locked));

	lab4 lab40(.clk(clk), .leds(leds), .hex5_n(hex5_n), .hex4_n(hex4_n), .hex3_n(hex3_n), .hex2_n(hex2_n), .hex1_n(hex1_n), .hex0_n(hex0_n), .sw(sw), .key_n({key_n[3:1],rst_n}));

endmodule
