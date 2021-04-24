
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
	reg OUT;
	
	reg aux [23:0];// para correr mantiza
	reg diferencia [7:0]// variable para ver la diferencia entre exp
	
	typedef enum logic [2:0] {S0,S1,S2,S3,S4,S5,S11} State;
	
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
//		if (start == 1) begin
			sA <= A[31];
			sB <= B[31];
			expA <= A[30:23];
			expB <= B[30:23];
			mantA[22:0] <= A[22:0];
			mantB[22:0] <= B[22:0];	
			R <= 2'h00;
			OUT <= 2'd23;
			nextState <= S1;
//		end	
		end
		
		
	S1: begin //1  //etapa para mirar casos especiales y de no ser el caso mirar diferencia entre exp
//		if (start == 1 and ready ==0) begin //2
		
			if((expA !=5'b00000 and expB !=5'b00000) and (expA !=5'b11111 and expB !=5'b11111) and ((A != B) or ( (A==B)  and (oper==0)))  ) begin //3
				nextState <= S2;
				//se verifica que los exp no entren dentro de las excepciones 
				if (expA > expB) begin //4					
					mayA <= 1;  //expA mayor que B =1
					diferencia <= expA-expB;
					aux <= mantB;					
					end//4
					
				else if (expA < expB) begin //5				
					mayA <= 0;
					diferencia <= expB-expA;
					aux <= mantA;
				end //5
				
				else if (expA == expB) diferencia <=8'b00000000; 
					
			end//3
								
			else if(expA== 5'b00000 or expB ==5'b00000) begin//6 // se mira si los exp de algunos de las datos ingresados estan reservados para el caso del 0
				nextState <= S11;
				ready <= 1;
				if(expA== 5'b00000 ) begin//7 // en el caso de uno ser cero el resultado sera el otro numero en el caso de la suma
			
					if(oper ==0) 
						R<=B;  // 0+B=B
				
					else  begin //9		//0-B=-B
						R<=B;
						R[31] <= ~(R[31]) // se cambia el signo por el contrario
						end//9
					
				end//7
				
				else //caso donde expB=0
					R<=A; // A+0=0 y A-0=0
				
			end //6	
		
		
			else if(expA !=5'b11111 or expB !=5'b11111)  begin //10 // se mira si los exp de algunos de las datos ingresados estan reservados para el caso del NAn o infinito
				ready <= 1;
				nextState <= S11;
				if(expA== 5'b11111)
					R<=A; // en caso que alguno sea Nan o infinito el resultado sera ese numero
					
				else
					R<=B;
			
			end//10	
						
			else begin // A=B
				R<= 2'h00; // en caso que A=B  y sea resta A-B=0
				ready <= 1;
				nextState <= S11; 
			end
		
		
	end//1 
		
	S2: begin // igualar exp
	
//		if(start == 1 and ready ==0)begin
		nextState <= S3;
		if (mayA == 1 and diferencia != 0) begin
			expB <= expB + diferencia;
			aux <= aux >> diferencia;
		end
		else if (mayA == 0 and diferencia != 0) begin
			expA <= expA + diferencia;
			aux <= aux >> diferencia;
		end
//			end
//		else
//			nextState <= S1;
		end
		
		
	S3: begin // suma o resta ya con los exp iguales
	
//	if(start == 1 and ready ==0)begin
	nextState <= S4;
	if(oper==0) begin //SUMA // oper=0 suma y oper=1 resta
	
		if(A[31]==B[31]) begin //ambos numeros con signos iguales
			nextState <= S4;
			R[31] <= A[31]; //signo de la salida va a ser el signo de cualquiera de los dos  numeros ya que tienen igual signo		
			if (mayA == 1 and diferencia != 0) //A>B
				result <= mantA + aux;				
				
			else if (mayA == 0 and diferencia != 0 ) //B>A
				result <= mantB + aux;
				
			else if(diferencia == 0) // exp iguales
				result <= mantB + mantA;
		end
		
		else begin //A y B signos diferentes, suma
			
			if (mayA == 1 and diferencia != 0) begin
				result <= mantA + aux;
				R[31] <= A[31]; // si se suman el resultado tendra el signo del numero mayor, en este caso A
									// ya que el exp de A es mas grande				
			end
				
			else if (mayA == 0 and diferencia != 0 ) begin
				result <= mantB + aux;
				R[31] <= B[31]; // si se suman el resultado tendra el signo del numero mayor, en este caso B
									 // ya que el exp de B es mas grande				
			end
									 
			else if(diferencia == 0) begin //exp iguales
				result <= mantB + mantA;
				if (mantA > mantB) begin
						R[31] <= A[31]; // si se suman el resultado tendra el signo del numero mayor, en este caso A
															 // ya que la mantisa de A es mas grande
				end											 
				else if (mantB > mantA) begin
					
					R[31] <= B[31]; // de caso contrario mantisa de B mas grando, por tanto result tiene el signo de B
				
				end
				else begin
					
					R<= 2'h00;
				
				end
				
			end //suma se supone que esta bien
			
		end
			
			
	end
	
	else begin// RESTA // definir la resta , mirar bien 
		
		if(A[31]==B[31]) begin //ambos numeros con signos iguales
		
			if (mayA == 1 and diferencia != 0) begin//A>B
					result <= mantA - aux; //signo del resultado es el de A //arreglar
					
					if(A[31]==0) begin // los dos positivos A-B , siempre signo de A
						R[31] <= A[31];
					end
					
					if(A[31]==1) begin  // los dos son negativos A-B da el signo contrario a A
						R[31] <= ~A[31];
					end
			end
					
					
			else if (mayA == 0 and diferencia != 0 ) begin//B>A
			
			if(A[31]==0) begin  // los dos son positivos
					result <= mantB - aux; 
					R[31] <= ~B[31];      //signo del resultado es el contrario al de B //
			end
			
			if(A[31]==1) begin  // los dos son negativos
					result <= mantB - aux; 
					R[31] <= B[31];      //signo del resultado es el de B //
					
			end
			
			
			
			
			
			
			end
					
			else if(diferencia == 0) begin // exponentes iguales
				if(A[31]==0) begin //positivos 
				if(mantA > mantB) begin 
						result <= mantA - mantB; //A-B .A>B. 10-5=5
						R[31] <= A[31]; //signo del resultado es el de A
						nextState <= S4;
					end
				else if(mantB > mantA) begin
					result <= mantB - mantA; //A-B .B>A. 5-10=-5
					R[31] <= ~A[31]; //signo del resultado es el contrario al de A
					nextState <= S4;
					end
				end //melo
				
					
				end
			end
		
		else begin //A y B signos diferentes
		R[31] <= A[31];      //como el - le cambia el signo a B, A y B teminarian sumandose con el mismo signo
												 // ya que seria A-(-B) o -A-(B)
		
		if (mayA == 1 and diferencia != 0) begin//A>B
					result <= mantA + aux; 
					nextState <= S4;
			end
					
					
			else if (mayA == 0 and diferencia != 0 ) begin//B>A
					result <= mantB + aux; 
					nextState <= S4;
					
			end
					
			else if(diferencia == 0) begin //no importa cual mantisa es mayor ya que se van a terminar sumando
						result <= mantA + mantB;
						nextState <= S4;

				end		
		end
				
		end//melo
		
//	end
	
	
//	else
//			nextState <= S1;
//	
	end
	
	S4: begin // normalizar la mantisa  //10.00 //11.11 //01.0 //0.1
//	if(start == 1 and ready ==0)begin
		nextState <= S11;
		ready <= 1;
		if(oper==0) begin //suma  
		
			if(result[24]== 1) begin
				R[22:0] <= result[23:1];//11.11111 //restarle uno al exponente
				
				if(mayA)
					R[30:23] <= expA - 1'd1;
				
				else 
					R[30:23] <= expB - 1'd1;
				
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
			//1.xxx - 0.xxx =01.xxx 	
			//	1.xxx - 1.xxx =0.xxx
				if(diferencia != 0) begin
				
					R[22:0] <= result[22:0];//01.xxxxx
					nextState <= S11;
					ready <= 1;
					
					if(mayA) begin
					
						R[30:23] <= expA;
						
					end
					
					else begin
					
						R[30:23] <= expB;
					end
				end
				
			else begin //00.xxxx caso triste
				ready <= 1;
				nextState <= S11;
				for(i=0;i<24;i=i+1) begin
					if(result[i]==1) 
						OUT <=i;			//va guardar la posicion del ultimo bit donde encuentre 1			
				end
				
				if(OUT != 0)  //para que no haya excepcion en el result
					R[22: 22-OUT+1] <= result[(OUT-1):0];  //guardamos los numeros anteriores al primer uno y los enviamos a las primeras posiciones del resultado, ya probamos que funciona, GUT
				else
					R[0] <= result[0]; //Cuando el 1 esté en la posicion 0 de result
					
				if (expA + (24-OUT) < 254) // Si no existe overflow
					R[30:23] <= expA + (24-OUT);  
				else 
					R = ~R;	//Infinito
			end						
	end
	else nextState <= S1;
	
	
//		OUT=0;
//		if(B[3]==1) OUT=3;
//		if (B[2]==1) OUT=2;
//		if (B[1]==1) OUT=1;
//		else OUT=0;
//		
//		for(i=0;i<32;i=i+1)
//			if(B[i]==1) OUT <=i;
			
//		end
	end
	S11: begin
	
	if (start == 0 and ready = 1) 
		nextState <= S11;
		
	else begin 
		nextState <= S0;  //espero que start sea 0, que haya una nueva op
		ready <= 0;
	end
		
	end	
	
endmodule

module test_bench();

	logic clk, reset, start, oper; 
	logic [31:0] A, B;
	logic [31:0] R;
	logic ready;	
		
	addsub754_JJ tb(clk, reset, start, oper, A, B, R, ready);
	
	initial begin
	
		clk = 1;
		reset = 1; #40ns
		reset = 0; #40ns
		//4 -> 01000000100000000000000000000000, -4 -> 11000000100000000000000000000000
		//2 -> 01000000000000000000000000000000, -2 -> 11000000000000000000000000000000
		//5 -> 01000000101000000000000000000000, -5 -> 11000000101000000000000000000000
		
		//sumas
				 
		start = 1; oper = 0; A = 01000000100000000000000000000000; B = 01000000000000000000000000000000; #50ms; //signos iguales, distinto exponente, a=4 b=2
		start = 1; oper = 0; A = 01000000000000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos iguales, distinto exponente, a=2 b=4
		start = 1; oper = 0; A = 01000000101000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos iguales, mismo exponente, a=5 b=4
		start = 1; oper = 0; A = 01000000100000000000000000000000; B = 01000000101000000000000000000000; #50ms; //signos iguales, mismo exponente, a=4 b=5
		start = 1; oper = 0; A = 01000000100000000000000000000000; B = 11000000000000000000000000000000; #50ms; //signos distintos, distinto exponente, a=4 b=-2
		start = 1; oper = 0; A = 11000000000000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos distintos, distinto exponente, a=-2 b=4
		start = 1; oper = 0; A = 01000000100000000000000000000000; B = 11000000101000000000000000000000; #50ms; //signos distintos, mismo exponente, a=4 b=-5
		start = 1; oper = 0; A = 11000000101000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos distintos, mismo exponente, a=-5 b=4
		start = 1; oper = 0; A = 11000000101000000000000000000000; B = 11000000101000000000000000000000; #50ms; //mismo valor a=-5 b=-5
		
		//restas
		
		start = 1; oper = 1; A = 01000000100000000000000000000000; B = 01000000000000000000000000000000; #50ms; //signos iguales, distinto exponente, a=4 b=2
		start = 1; oper = 1; A = 01000000000000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos iguales, distinto exponente, a=2 b=4
		start = 1; oper = 1; A = 01000000101000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos iguales, mismo exponente, a=5 b=4
		start = 1; oper = 1; A = 01000000100000000000000000000000; B = 01000000101000000000000000000000; #50ms; //signos iguales, mismo exponente, a=4 b=5
		start = 1; oper = 1; A = 01000000100000000000000000000000; B = 11000000000000000000000000000000; #50ms; //signos distintos, distinto exponente, a=4 b=-2
		start = 1; oper = 1; A = 11000000000000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos distintos, distinto exponente, a=-2 b=4
		start = 1; oper = 1; A = 01000000100000000000000000000000; B = 11000000101000000000000000000000; #50ms; //signos distintos, mismo exponente, a=4 b=-5
		start = 1; oper = 1; A = 11000000101000000000000000000000; B = 01000000100000000000000000000000; #50ms; //signos distintos, mismo exponente, a=-5 b=4
		start = 1; oper = 1; A = 11000000101000000000000000000000; B = 11000000101000000000000000000000; #50ms; //mismo valor a=-5 b=-5
		$stop;
	end
	
	always #20ns Clk = ~Clk;
	
endmodule	
		