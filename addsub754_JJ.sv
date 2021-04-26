module addsub754_JJ(clk, reset, start, oper, A, B, R, ready);

	input logic clk, reset, start, oper; 
	input logic [31:0] A;
	input logic [31:0] B;
	output logic [31:0] R;
	output logic ready;
	
	reg [7:0] expA=8'b0;
	reg [7:0] expB=8'b0;
	reg [23:0] mantA; // los primeros 23 bits son la mantisa y msb es el 1 que trae p|| defecto
	reg [23:0] mantB;// los primeros 23 bits son la mantisa y msb es el 1 que trae p|| defecto    
	reg [24:0] result;
	reg mayA;
	reg [31:0] rA,rB;
	reg [7:0] OUT;
	reg [23:0] aux ;// para correr mantiza
	reg [7:0]diferencia ;// variable para ver la diferencia entre exp
	logic [7:0]i;


	integer j=0;
	
	typedef enum logic [2:0] {S0,S1,S2,S3,S4,S6,S11} State;
	
	
	State currentState, nextState;
	
	always_ff @(posedge reset, posedge clk) begin
		

		if(reset) 
			currentState <= S11;
			
		else
			currentState <= nextState;

	
	end
	


	
	always_comb  begin //logica de siguiente estado
	
		case (currentState)
	
	
	S0:begin
		
		if(start) nextState <= S1;
		else nextState <= S0;
		
		end
	S1: begin 
	if(((expA !=8'b00000000) && (expB !=8'b00000000)) && ((expA !=8'b11111111) && (expB !=8'b11111111)) && ((rA != rB) || ( (rA == rB)  && (oper == 0 )))  ) begin
				nextState <= S2;
				//ready <= 1;
		end
			else nextState <= S11;
	end
	
	S2: nextState <= S3;
	S3: nextState <= S4;
	S4: begin
	
		if(((oper==0 && (rA[31]== rB[31]))|| (oper==1 && (rA[31]!=rB[31])))) begin 
		nextState <= S11; 
		//ready <= 1;
		
		end
		else nextState <= S6; 
	
	end
	S6: begin 
		nextState <= S11;
		//ready <= 1;
		
		end
	S11: begin
		if (start==0 ) nextState <= S0;
					
		  else begin
		  
		  nextState <= S11;
		  
		  end
		 end
	default: 
				nextState <= S11;
	
	endcase
	
	end
	
	
	
	always_ff @( posedge clk)  begin
	
	case (currentState)
	
	S0: begin
	
	    ready <= 0;
		 rA<=A;
		 rB<=B;
		result <=25'b0;
		mantA[23] <= 1;
		mantB[23] <= 1;
		expA <= A[30:23];
		expB <= B[30:23];
		mantA[22:0] <= A[22:0];
		mantB[22:0] <= B[22:0];	
		R <= 2'h00;
		OUT <= 8'b00000000;
		end
		
		
	S1: begin //1  //etapa para mirar casos especiales y de no ser el caso mirar diferencia entre exp
	
		
			if(((expA !=8'b00000000) && (expB !=8'b00000000)) && ((expA !=8'b11111111) && (expB !=8'b11111111)) && ((rA != rB) || ( (rA == rB)  && (oper == 0 )))  ) begin //3
				
				
				if (expA > expB) begin //4					
					mayA <= 1;  //expA may|| que B =1
					diferencia <= expA-expB;
					aux <= mantB;					
					end//4
					
				else if (expA < expB) begin //5				
					mayA <= 0;
					diferencia <= expB-expA;
					aux <= mantA;
				end //5
				
				//else if (expA == expB) diferencia <=8'b00000000; 
				else  diferencia <=8'b00000000;
					
			end//3
								
			else if(expA== 8'b00000000 || expB ==8'b00000000) begin//6 // se mira si los exp de algunos de las datos ingresados estan reservados para el caso del 0
				
				if(expA== 8'b00000000 ) begin//7 // en el caso de uno ser cero el resultado sera el otro numero en el caso de la suma
			
					if(oper ==0) 
						R <= rB;  // 0+B=B
				
					else  begin //9		//0-B=-B
						R[30:0] <= rB[30:0];
						R[31] <= ~(rB[31]); // se cambia el signo p|| el contrario
						end//9
					
				end//7
				
				else //caso donde expB=0
					R <= rA; // A+0=A y A-0=A
				
			end //6	
		
		
			else if(expA ==8'b11111111 || expB ==8'b11111111)  begin //10 **// se mira si los exp de algunos de las datos ingresados estan reservados para el caso del NAn o infinito
				//ready <= 1;
				//nextState <= S11;
				if(expA== 8'b11111111)
					R <= rA; // en caso que alguno sea Nan o infinito el resultado sera ese numero
					
				else
					R <= rB;
			
			end//10	
						
			else begin // A=B
				R <= 2'h00; // en caso que A=B  y sea resta A-B=0
				//ready <= 1;
				//nextState <= S11; 
			end
		
		
	
	//end
	//else nextState <= S11;
	
	end//1 
		
	S2: begin // igualar exp
	
		
		if (mayA == 1 && diferencia != 8'b0) begin
			expB <= expB + diferencia;//+ diferencia ***
			aux <= aux >> diferencia;
		end
		else if (mayA == 0 && diferencia != 8'b0) begin
			expA <= expA + diferencia;
			aux <= aux >> diferencia;
		end
		else   aux <=23'b0000000000000000000000000;

		
	end
		
		
	S3: begin // suma o resta ya con los exp iguales
	

	if((oper==0 && (rA[31]== rB[31]))|| (oper==1 && (rA[31]!=rB[31]))) begin //SUMA // oper=0 suma y oper=1 resta
	
	
		if(rA[31]== rB[31]) begin //ambos numeros con signos iguales y suma , entonces sumo
	
			R[31] <= rA[31]; //signo de la salida va a ser el signo de cualquiera de los dos  numeros ya que tienen igual signo		
			if (mayA == 1 && diferencia != 0) //A>B
				result <= mantA + aux;				
				
			else if (mayA == 0 && diferencia != 0 ) //B>A
				result <= mantB + aux;
				
			//else if(diferencia == 0) // exp iguales
			else 
				result <= mantB + mantA;
		end
		
		else begin	//signo diferente y resta , entonces sumo	 //A- -B  -A-+B
		           
			R[31] <= rA[31]; //Simepre signo de A
			if (mayA == 1 && diferencia != 0) begin 
				result = mantA + aux;
								
			end
				
			else if (mayA == 0 && diferencia != 0 ) begin
				result = mantB + aux;
							
			end
									 
			
			else  begin //exp iguales
			
				result <= mantB + mantA;

			end //suma se supone que esta bien
			
		end
			
			
	end
	
	else begin// RESTA /// Resto  ((oper==1 && (A[31]==B[31]))|| (oper==0 && (A[31]!=B[31]))) 
		
		if(rA[31]== rB[31]) begin //ambos numeros con signos iguales y resta, entonces resto  A-B
		
			if (mayA == 1 && diferencia != 0) begin//A>B
					result <= mantA - aux; //signo del resultado es el de A 
					R[31] <= rA[31];
					
					
			end
					
					
			else if (mayA == 0 && diferencia != 0 ) begin//B>A
				result <= mantB - aux;
				R[31] <= ~rA[31];
			
			
			end
					
		
			else  begin //exp iguales
			 
				if(mantA > mantB) begin 
						result <= mantA - mantB; //A-B .A>B. 10-5=5
						R[31] <= rA[31]; //signo del resultado es el de A
						//nextState <= S4;
					end
					
				else if(mantB > mantA) begin
					result <= mantB - mantA; //A-B .B>A. 5-10=-5
					R[31] <= ~rA[31]; //signo del resultado es el contrario al de A
					//nextState <= S4;
					end
				
					
				end
			end
		
		else begin //A y B signos diferentes y suma , entonce resto
					//A + -B   -A + B
		
		if (mayA == 1 && diferencia != 0) begin//A>B //la operacion conserva el signo de A
				
				R[31] <= rA[31];
				
				if(rA[31]==0) 
					result <= mantA - aux;
				
				else 
					result <= aux - mantA;

					
			end
					
					
		else if (mayA == 0 && diferencia != 0 ) begin//B>A //A + -B   -A + B
		
					R[31] <= rB[31];
				
				if(rA[31]==0) 
					result <= aux - mantB;
				
				else 
					result <= mantB - aux;
					
			end
					
		else begin //exp iguales A + -B   -A + B
		
		
				
		
		
				if(mantA > mantB) begin 
				
					R[31] <= rA[31];
					result <= mantA - mantB;
					
					
					
				end	
		
					
				else if(mantB > mantA) begin
						R[31] <= rB[31];
						result <= mantB - mantA;
				end

				end		
		end
				
		end//melo
		

   
	
	end
	
	S4: begin // normalizar la mantisa  //10.00 //11.11 //01.0 //0.1
	

		
		if(((oper==0 && (rA[31]== rB[31]))|| (oper==1 && (rA[31]!=rB[31])))) begin //suma

			ready <= 1;
		
			if(result[24]== 1) begin
				R[22:0] <= result[23:1];//11.11111 //restarle uno al exponente
				
				if(mayA ==1 && diferencia != 0)
					R[30:23] <= expA + 1'd1;
				
				else if(mayA ==0 && diferencia != 0) 
					R[30:23] <= expB + 1'd1;
					
				else begin
					R[30:23] <= expB + 1'd1;
				
				end
				
			end
			
			else begin
			
				R[22:0] <= result[22:0];//01.11111
				
				if(mayA) 
					R[30:23] <= expA;

				
				else 
					R[30:23] <= expB;
	
			end
		end
			
		else  begin//resta
			//   01.xxx - 00.1xxx =01.xxx 	
			
//				if(diferencia != 0) begin   //24 23 22
//														// 0   1
//														
//				
//					R[22:1] <= result[21:0];//01.xxxxx

				for(i=8'b00000000;i<8'b00011000;i=i+8'b00000001) begin
					if(result[j]==1) begin
						 OUT =i;			//va guardar la posicion del ultimo bit donde encuentre 1
						 //result<=result<< j;
					end
					j= j+1;
					//else OUT <=8'b00000000;
				end

			ready <= 1;
			//nextState <= S11;
			result<=result <<(8'b00011001-OUT);
			
			if ((expA  + (8'b00010111-OUT)) < 8'b11111110) // Si no existe overflow
						R[30:23] <= expA - (8'b00010111-OUT);  
			else 
					R <= ~R;	//Infinito
		
				
				
	end
	

	end
	
	
	
	
	S6: begin
	
	R[22:0] <= result[24:2];

	
	end
	
	S11: begin
	
	j<=0;
	i <=8'b00000000;
	expA <= 8'b00000000;
	expB <= 8'b00000000;
	mantA <= 23'b00000000000000000000000;
	mantB <= 23'b00000000000000000000000;	

	OUT <= 8'b00000000;
	aux <= 23'b00000000000000000000000;
	diferencia <= 8'b00000000;
	result <= 24'b000000000000000000000000;
	rA <= 2'h00;
	rB <= 2'h00;
	
	

	
	end
		
	

	default: 
				
		R <= 2'h00;
				
		endcase
	end
	
endmodule

module test_bench();

	logic Clk, reset, start, oper; 
	logic [31:0] A, B;
	logic [31:0] R;
	logic ready;	
		
	addsub754_JJ tb(Clk, reset, start, oper, A, B, R, ready);
	
	initial begin
	
		A=2'h00;
		B=2'h00;
		Clk = 1;
		reset = 1; #40ns;
		start = 0;#10ns
		reset = 0; #40ns;
		oper=0;#2ns
		//4 -> 01000000100000000000000000000000, -4 -> 11000000100000000000000000000000
		//2 -> 01000000000000000000000000000000, -2 -> 11000000000000000000000000000000
		//5 -> 01000000101000000000000000000000, -5 -> 11000000101000000000000000000000
		
		//sumas
				 
		//start = 1; oper = 0; A =32'b01000000100000000000000000000000; B =32'b01000000000000000000000000000000; #150ns; //signos iguales, distinto exponente, a=4 b=2
	//start = 1; oper = 0; A =32'b01000000000000000000000000000000; B =32'b01000000100000000000000000000000; #400ns; //signos iguales, distinto exponente, a=2 b=4
	// start = 1; oper = 0; A =32'b01000000101000000000000000000000; B =32'b01000000100000000000000000000000; #400ns; //signos iguales, mismo exponente, a=5 b=4
	//start = 1; oper = 0; A =32'b01000000100000000000000000000000; B =32'b01000000101000000000000000000000; #400ns; //signos iguales, mismo exponente, a=4 b=5
	//start = 1; oper = 0; A =32'b01000000100000000000000000000000; B =32'b11000000000000000000000000000000; #400ns; //signos distintos, distinto exponente, a=4 b=-2
	//start = 1; oper = 0; A =32'b11000000000000000000000000000000; B =32'b01000000100000000000000000000000; #400ns; //signos distintos, distinto exponente, a=-2 b=4
	//start = 1; oper = 0; A =32'b01000000100000000000000000000000; B =32'b11000000101000000000000000000000; #400ns; //signos distintos, mismo exponente, a=4 b=-5
	//start = 1; oper = 0; A =32'b11000000101000000000000000000000; B =32'b01000000100000000000000000000000; #240ns; //signos distintos, mismo exponente, a=-5 b=4
	//start = 1; oper = 0; A =32'b11000000101000000000000000000000; B =32'b11000000101000000000000000000000; #240ns; //mismo val|| a=-5 b=-5
		
		//restas  
	//start = 1; oper = 1; A =32'b01000001110000000000000000000000; B =32'b01000000000000000000000000000000; #400ns; //signos iguales, distinto exponente, a=24 b=2	
	//start = 1; oper = 1; A =32'b01000000100000000000000000000000; B =32'b01000000000000000000000000000000; #400ns; //signos iguales, distinto exponente, a=4 b=2
																																			
	//start = 1; oper = 1; A =32'b01000000100000000000000000000000; B =32'b01000000100000000000000000000000; #300ns; //
																																			
	//start = 1; oper = 1; A =32'b01000000101000000000000000000000; B =32'b01000000100000000000000000000000; #280ns; //signos iguales, mismo exponente, a=5 b=4
	//start = 1; oper = 1; A =32'b01000000100000000000000000000000; B =32'b01000000101000000000000000000000; #300ns; //signos iguales, mismo exponente, a=4 b=5
	//start = 1; oper = 1; A =32'b01000000100000000000000000000000; B =32'b11000000000000000000000000000000; #300ns; //signos distintos, distinto exponente, a=4 b=-2
	//start = 1; oper = 1; A =32'b11000000000000000000000000000000; B =32'b01000000100000000000000000000000; #300ns; //signos distintos, distinto exponente, a=-2 b=4
	//start = 1; oper = 1; A =32'b01000000100000000000000000000000; B =32'b11000000101000000000000000000000; #300ns; //signos distintos, mismo exponente, a=4 b=-5
	//start = 1; oper = 1; A =32'b11000000101000000000000000000000; B =32'b01000000100000000000000000000000; #450ns; //signos distintos, mismo exponente, a=-5 b=4
	//start = 1; oper = 1; A =32'b11000000101000000000000000000000; B =32'b11000000101000000000000000000000; #300ns; //mismo val|| a=-5 b=-5
	//start = 1; oper = 1; A =32'b00000000000000000000000000000000; B =32'b11000000101000000000000000000000; #300ns; // a=0 b=-5
	//start = 1; oper = 1; A =32'b11000000101000000000000000000000; B =32'b00000000000000000000000000000000; #300ns; // a=-5 b=0
	//start = 1; oper = 0; A =32'b00000000000000000000000000000000; B =32'b11000000101000000000000000000000; #400ns; // a=0 b=-5 suma
	//start = 1; oper = 0; A =32'b11000000101000000000000000000000; B =32'b00000000000000000000000000000000; #300ns; // a=-5 b=0
	//start = 1; oper = 0; A =32'b11111111111100000000000000000000; B =32'b00000000000000000000000000000000; #300ns; // a=-Nand b=0
	//start = 1; oper = 1; A =32'b11111111111100000000000000000000; B =32'b00000000000000000000000000000000; #300ns; // a=-Nand b=0
	//start = 1; oper = 1; A =32'b01000000100000000000000000000000; B =32'b11111111111100000000000000000000; #150ns; // a=4 b=nand
	//start = 1; oper = 0; A =32'b01000000100000000000000000000000; B =32'b11111111111100000000000000000000; #150ns; // a=4 b=nand
	start = 1; oper = 1; A =32'b00000000000000000000000000000000; B =32'b11111111111100000000000000000000; #300ns;	//a=0 b=nand
	start =0;#20ns;
	start = 1; oper = 1; A =32'b01000010111100010000000000000000; B =32'b00111111000000000000000000000000; #400ns;	//a=120.5 b=0.5
		$stop;
		
	end
	
	always #20ns Clk = ~Clk;
	
endmodule	
		