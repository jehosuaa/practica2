
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
	
		if(Reset)
			currentState <= S0;
		else
			currentState <= nextState;
	
	end
	
//cuando coloco S11 me refiero al estado final, como aun no hemos defino cuantos estados tenemos puse uno alto
	
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
		
		
	S1: begin //1  //etapa para mirar casos especiales y de no ser el caso mirar diferencia entre exp
		if (start == 1 and ready ==0) begin //2
		
			if((expA !=5'b00000 and expB !=5'b00000) and (expA !=5'b11111 and expB !=5'b11111) ) begin //3
			
				//se verifica que los exp no entren dentro de las excepciones 
				if (expA > expB) begin //4
					
					mayA <= 1;  //expA mayor que B =1
					diferencia <= expA-expB;
					aux <= mantB;
					nextState <= S2;
					
					end//4
					
				else if (expA < expB) begin //5
				
					mayA <= 0;
					diferencia <= expB-expA;
					aux <= mantA;
					nextState <= S2;
					
				end //5
				
				else if (expA == expB) diferencia <=8'b00000000 //yo creo que en vez de else if se puede poner un else
					
			end//3
								
			else if(expA== 5'b00000 or expB ==5'b00000) begin//6 // se mira si los exp de algunos de las datos ingresados estan reservados para el caso del 0
		
				if(expA== 5'b00000 ) begin//7 // en el caso de uno ser cero el resultado sera el otro numero en el caso de la suma
			
					if(oper ==0) begin //8
						R<=B;  // 0+B=B
						ready <= 1;
						nextState <= S11;
						end //8
				
					else  begin //9		//0-B=-B
						R<=B;
						R[31] <= ~(R[31]) // se cambia el signo por el contrario
						ready <= 1;
						nextState <= S11;
						end//9
					
				end//7
				
				else begin//caso donde expB=0
				 R<=A; // A+0=0 y A-0=0
				 ready <= 1;
				 nextState <= S11;
				 end
				
			end //6	
		
		
			else  begin //10 // se mira si los exp de algunos de las datos ingresados estan reservados para el caso del NAn o infinito
		
			if(expA== 5'b11111) begin 
			   R<=A; // en caso que alguno sea Nan o infinito el resultado sera ese numero
				ready <= 1;
				nextState <= S11;
				end
				
			else  begin 
				R<=B;
				ready <= 1;
				nextState <= S11;
				end
			
			end//10	
			
			
		end//2
		
		else
			nextState <= S1;
		end
			
		
		
		
	
	S2: begin // igualar exp
	
		if(start == 1 and ready ==0)begin
		
			if (mayA == 1 and diferencia != 0) begin
				expB <= expB + diferencia;
				aux <= aux >> diferencia;
				end
			else if (mayA == 0 and diferencia != 0) begin
				expA <= expA + diferencia;
				aux <= aux >> diferencia;
				end
			end
		else
			nextState <= S1;
		end
		
		
	S3: begin // suma o resta ya con los exp iguales
	
	if(start == 1 and ready ==0)begin
	
		if(oper==0) begin //SUMA // oper=0 suma y oper=1 resta
		
			if(A[31]==B[31]) begin //ambos numeros con signos iguales
			
				R[31] <= A[31]; //signo de la salida va a ser el signo de cualquiera de los dos  numeros ya que tienen igual signo
			
				if (mayA == 1 and diferencia != 0)
					result <= mantA + aux;
					nextState <= S4;
					
					
				else if (mayA == 0 and diferencia != 0 )
					result <= mantB + aux;
					nextState <= S4;
					
				else if(diferencia == 0)
					result <= mantB + mantA;
					nextState <= S4;
			end
			
			else begin //A y B signos diferentes
				
				if (mayA == 1 and diferencia != 0) begin
					result <= mantA + aux;
					R[31] <= A[31]; // si se suman el resultado tendra el signo del numero mayor, en este caso A
										// ya que el exp de A es mas grande
					nextState <= S4;
					
				end
					
				else if (mayA == 0 and diferencia != 0 ) begin
					result <= mantB + aux;
					R[31] <= B[31]; // si se suman el resultado tendra el signo del numero mayor, en este caso B
										 // ya que el exp de B es mas grande
					nextState <= S4;
					
				end
										 
				else if(diferencia == 0) begin
					result <= mantB + mantA;
					if (mantA > mantB) begin
							R[31] <= A[31]; // si se suman el resultado tendra el signo del numero mayor, en este caso A
																 // ya que la mantisa de A es mas grande
							nextState <= S4;
																 
					end											 
				   else begin
						
						R[31] <= B[31]; // de caso contrario mantisa de B mas grando, por tanto result tiene el signo de B
						nextState <= S4;
					
					end
					
				end
				
			end
				
				
		end
		
		else begin// RESTA // definir la resta , mirar bien 
		
		if(A[31]==B[31]) begin //ambos numeros con signos iguales
		
			if (mayA == 1 and diferencia != 0)//A>B
					result <= mantA - aux; //signo del resultado es el de A
					R[31] <= A[31];
					
					
			else if (mayA == 0 and diferencia != 0 )//B>A
					result <= mantB - aux; 
					R[31] <= ~B[31];      //signo del resultado es el contrario al de B
					
			else if(diferencia == 0) begin
					if(mayA) begin 
						result <= mantA - mantB;
						R[31] <= A[31]; //signo del resultado es el de A
					end
					if(mayB) begin
						result <= mantB - mantA;
						R[31] <= ~B[31]; //signo del resultado es el contrario al de B
					end
				end
			end
		
		else begin //A y B signos diferentes
		
		end
		
		
		end
		
	end
	
	
	else
			nextState <= S1;
	
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
			
	
		
			
		