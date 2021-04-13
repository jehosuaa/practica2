//hola 

module addsub754_JJ(clk, reset, start, oper, A, B, R, ready);
	input logic clk, reset, start, oper;
	input logic [31:0] A, B;
	output logic [31:0] R;
	output logic ready;