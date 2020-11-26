;----------------------------------------------------------------------------
;						BIBLIOTECA PARA SENSOR LM35							|
; Disciplina: Microcontroladores											|
; Desenvolvido por: Rodrigo Antonio Sbardeloto Kraemer						|
; 		 			Mateus Milani											|
;Data:	30/06/2016															|
;----------------------------------------------------------------------------
;                             DESCRICAO GERAL                             

;Esta biblioteca le os valores de tensao do sensor de temperatura LM35 (pino 
; RA3) e converte para temperatura. Faixa de operacao (+150 ate -55)
;Utiliza a Biblioteca Atirmetica para fazer as contas.
;----------------------------------------------------------------------------
;* Função ESPERA_CONVERSAO 							 			   
;* Função COPIA_RES_CONVERSAO              						  
;* Função COPIA_RESOLUCAO             							   
;* Função DECODE_DIGITO             							   

;----------------------------------------------------------------------------
;			VARIAVEIS A SEREM DECLARADAS NO CODIGO PRINCIPAL

;	TEMPERATURA_c -	centena
;	TEMPERATURA_d - dezena
;	TEMPERATURA_u - unidade
;	TEMPERATURA_x1
;	TEMPERATURA_x - casa apos a virgula
;				    Variaveis que armazenam a temperatura, ja convertida, 
;					pronta para ser armazenada e exibida.
;	NUM1_H
;	NUM1_L		Variaveis para guardar os valores convertidos pelo A/D
;					que sao armazenados em ADRESH (bank0) e ADRESL (bank1).
;
;----------------------------------------------------------------------------
;		REGISTRADORES A SEREM CONFIGURADOS NO CODIGO PRINCIPAL

;	BANK1
;	ADCON1(10000010)		;7: 	RIGHT justified
							;3-0: 	Analog (RA3)
							;	  	Analog (RA2)
							;	  	Analog (RA1)
							;	  	Analog (RA0)

;	BANK0
;	ADCON0(10001000)		;Configuracao do conversor ADC
							;7-6: Fosc/32
							;5-3: channel 1 (RA1, AN1)
							;2: Convertendo ou nao
							;1: nao implementado
							;0: ligado ou desligado (manter desligado, 
							;economiza energia)
							



;----------------------------------------------------------------------------
SENSOR:
	bsf		ADCON0,2		

;----------------------------------------------------------------------------
;                      FUNÇÃO ESPERA_CONVERSAO	               	   
;                                                   			   
; Esta rotina deve ser chamada quando uma conversão A/D for iniciada. 											   
; O programa fica preso em um loop até que a conversão termine,   
; para então retornar.   										  
; Não possui argumentos nem retornos.   				           
;----------------------------------------------------------------------------
ESPERA_CONVERSAO:
	btfsc	ADCON0,2				;Testa FLAG
	goto	ESPERA_CONVERSAO	;Enquanto ADCON0,2 = 1 a Conversão 
								;ainda não terminou
	
;----------------------------------------------------------------------------
;                    FUNÇÃO COPIA_RES_CONVERSAO	               
;                                                   			   
; Esta rotina copia o resultado de uma coversão A/D para as       
; variáveis de entrada da função MULTIPLICA_10x8 da Biblioteca	   
; Aritmetica.													   
;-----------------------------------------------------------------
; Para ADRESH e ADRESL Justificados a Direita                     
;-----------------------------------------------------------------
; ADRESH e ADRESL Registers: Datasheet Pag 116  				   
; Os registradores ADRESH e ADRESL guardam a parte alta e a	   
; parte baixa, respectivamente, do resultado da conversão A/D.    
;-----------------------------------------------------------------
; Esta função copia: ADRESH -> NUM1_H  	   				       
;   				  ADRESL -> NUM1_L   					  	   
;----------------------------------------------------------------------------
COPIA_RES_CONVERSAO:
	BANK1
	movf	ADRESL,W

	BANK0
	movwf	MULT_1_L
	movf	ADRESH,W
	movwf	MULT_1_H
	
	movf	MULT_1_L,W
	movwf	TEMPERATURA

;----------------------------------------------------------------------------
;                    	FUNÇÃO COPIA_RESOLUCAO	               	   
;                                                   			   
; Esta rotina copia a resolução do conversor A/D, (que foi        
; definida aqui mesmo), para uma variável de entrada da função    
; MULTIPLICA_10x8 da Biblioteca Aritmetica2.					   
;-----------------------------------------------------------------
; Nesta rotina a resolução do coversor A/D será setada, conforme: 
; Resoloução = Vref/L                                     		   
; Onde: Vref: Fundo de escala                                     
;       L:    Niveis de Quantização = (2^N)-1                     
;       N:    Número de bits                                      
;-----------------------------------------------------------------
; Esta função copia: Resolução(Literal) -> MULT_2 	   			   
;----------------------------------------------------------------------------
COPIA_RESOLUCAO
	movlw	.5		
	movwf	MULT_2	

	call	MULTIPLICA_10x8
	
	
;----------------------------------------------------------------------------
;                    	FUNÇÃO DECODE_DIGITO	               	   
;                                                   			   
; Esta rotina Isola os Dígitos do resultado da Conversão A/D      
; para mandar, individualmente para o LCD (deve somar 48 
; para converter para ASCII)					   
; --------------------------------------------------------------- 
; Variáveis de Entrada:          |   Variáveis de Saída:    	   
;     (Argumentos)               |       (Retornos)   			   
; PRODUTO_H 	                 | NUM1                  	  	   
; PRODUTO_L     	             | NUM2 				      	   
;   		  	                 | NUM3							   
;   		  	                 | NUM4							   
;   		  	                 | NUM5							   
;-----------------------------------------------------------------
; Esta rotina deve ser chamada depois que o resultado da          
; Conversão A/D for multiplicado pela Resolução, através da 	   	
; função MULTIPLICA_10x8 da Biblioteca Aritmetica2. O retorno	   
; desse produto será argumento desta rotina.					  
;----------------------------------------------------------------------------
DECODE_DIGITO
;divide por 10MIL	0x2710
	movlw	0x27	;10000
	movwf	DIVISOR_H
	movlw	0x10	;16
	movwf	DIVISOR_L
	movf	PRODUTO_L,W
	movwf	DIVIDENDO_L
	movf	PRODUTO_H,W
	movwf	DIVIDENDO_H
	call	DIVIDE_16x16
	movf	QUOCIENTE_L,W
	addlw	.48
	movwf	TEMPERATURA_m

;divide por 1MIL	0x3E8
	movlw	0x03
	movwf	DIVISOR_H
	movlw	0xE8
	movwf	DIVISOR_L
	movf	RESTO_L,W
	movwf	DIVIDENDO_L
	movf	RESTO_H,W
	movwf	DIVIDENDO_H
	call	DIVIDE_16x16
	movf	QUOCIENTE_L,W
	addlw	.48
	movwf	TEMPERATURA_c

;divide por 100
	movlw	.100
	movwf	DIVISOR_L
	clrf	DIVISOR_H
	movf	RESTO_L,W
	movwf	DIVIDENDO_L
	movf	RESTO_H,W
	movwf	DIVIDENDO_H
	call	DIVIDE_16x16
	movf	QUOCIENTE_L,W
	addlw	.48
	movwf	TEMPERATURA_d

;divide por 10
	movlw	.10
	movwf	DIVISOR_L
	clrf	DIVISOR_H
	movf	RESTO_L,W
	movwf	DIVIDENDO_L
	movf	RESTO_H,W
	movwf	DIVIDENDO_H
	call	DIVIDE_16x16
	movf	QUOCIENTE_L,W
	addlw	.48
	movwf	TEMPERATURA_u
	
	movf	RESTO_L,W
	addlw	.48
	movwf	TEMPERATURA_x
	
	clrf	RESTO_L
	return	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	