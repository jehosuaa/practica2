
module addsub754_JJ(clk, reset, start, oper, A, B, R, ready);

	input logic clk, reset, start, oper; 
	input logic [31:0] A, B;
	output logic [31:0] R;
	output logic ready;
	
	reg sA;
	reg sB;
	reg [7:0] expA=8b'0;
	reg [7:0] expB=8b'0;
	reg [23:0] mantA; mantA[23] <= 1; // los primeros 23 bits son la mantisa y msb es el 1 que trae por defecto
	reg [23:0] mantB; mantB[23] <= 1;// los primeros 23 bits son la mantisa y msb es el 1 que trae por defecto
	reg [24:0] result=24b'0;
	reg mayA=0;
	
	signal aux [23:0];// para correr mantiza
	signal diferencia [7:0]// variable para ver la diferencia entre exp
	signal uno=0; // variable auxiliar para normalizar el resultado
	signal i=0;
	
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
		mantA[22:0] <= A[22:0];
		mantB[22:0] <= B[22:0];		
		end
		
		
	S1: begin
		if (start == 1) begin
			if (expA > expB) begin
				mayA <= 1;  //expA mayor que B =1
				diferencia <= expA-expB;
				aux <= mantB;
				end
			else if (expA < expB) begin
				mayA <= 0;
				diferencia <= expB-expA;
				aux <= mantA;
			end
			
			else if (expA == expB) begin
				diferencia <=8b'0
			end
					
		else
			currentState <= S1;
		end
	
	S2: begin // igualar exp
		
		if (mayA == 1 and diferencia != 0) begin
			expB <= expB + diferencia;
			aux <= aux >> diferencia;
			end
		else if (mayA == 0 and diferencia != 0) begin
			expA <= expA + diferencia;
			aux <= aux >> diferencia;
			end
		end
		
		
	S3: begin // suma o resta ya con los exp iguales

		if(oper==0) begin // oper=0 suma y oper=1 resta
			if (mayA == 1 and diferencia != 0)
				result <= mantA + aux;
			else if (mayA == 0 and diferencia != 0 )
				result <= mantB + aux;
			else if(diferencia == 0)
				result <= mantB + mantA;
			end
		end
		else // definir la resta , mirar bien   
		if (mayA == 1 and diferencia != 0)
				result <= mantA - aux;
			else if (mayA == 0 and diferencia != 0 )
				result <= mantB - aux;
			else if(diferencia == 0)
				if(mayA)
					result <= mantA - mantB;
					if(mayB)
					result <= mantB - mantA;
			end
	
	S4: begin // normalizar la mantisa  //10.00 //11.11 //1.0 //0.1
	
	
//		OUT=0;
//		if(B[3]==1) OUT=3;
//		if (B[2]==1) OUT=2;
//		if (B[1]==1) OUT=1;
//		else OUT=0;
//		
//		for(i=0;i<32;i=i+1)
//			if(B[i]==1) OUT <=i;
			
		end
			
	
		
			
		