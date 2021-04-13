
module addsub754_JJ(clk, reset, start, oper, A, B, R, ready);

	input logic clk, reset, start, oper;
	input logic [31:0] A, B;
	output logic [31:0] R;
	output logic ready;
	
	reg sA;
	reg sB;
	reg [7:0] expA;
	reg [7:0] expB;
	reg [22:0] mantA;
	reg [22:0] mantB;
	reg [22:0] result;
	reg mayA;
	
	signal aux [23:0]; aux[23] <= 1; // para correr mantiza

	
	State currentState, nextState;
	
	always_ff @(posedge reset, posedge clk) begin
	
		ashfjlahsdjh
		
	end
	
	always_comb begin 
	
	case (currentState)
	
	S0: begin
		sA <= A[31];
		sB <= B[31];
		expA <= A[30:23];
		expB <= B[30:23];
		mantA <= A[22:0];
		mantB <= B[22:0];		
		end
		
		
	S1: begin
		if (start == 1) begin
			if (expA > expB) begin
				mayA <= 1;  //expA mayor que B =1
				diferencia <= expA-expB;
				aux[22:0] <= mantB;
				end
			else begin
				mayA <= 0;
				diferencia <= expB-expA;
				aux[22:0] <= mantB;
			end
					
		else
			currentState <= S1;
		end
	
	S2: begin
		
		if (mayA == 1) begin
			expB <= expB + diferencia;
			aux <= aux >> diferencia;
			end
		else begin
			expA <= expA + diferencia;
			aux <= aux >> diferencia;
			end
		end
		
		
	S3: begin

			
		if (mayA == 1) begin
			result <= mantA + aux[22:0];
		else
			result <= mantB + aux[22:0];
		
			
		