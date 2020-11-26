;----------------------------------------------------------------------------
;						BIBLIOTECA PARA LCD									|
; Disciplina: Microcontroladores											|
; Desenvolvido por: Rodrigo Antonio Sbardeloto Kraemer						|
; 		 			Mateus Milani											|
;Data:	30/06/2016															|
;----------------------------------------------------------------------------
;                             DESCRICAO GERAL                             

;Esta biblioteca imprime o valor da temperatura medido pelo sensor.
;----------------------------------------------------------------------------
;Funcao ON_LCD
;Funcao	ESCREVE
;Funcao	DELAY

;----------------------------------------------------------------------------
;			VARIAVEIS A SEREM DECLARADAS NO CODIGO PRINCIPAL

;	TEMPO_xms - tempo a ser determinado
;	TEMPO_ms - tempo a ser contado, em milisegundos
;
;----------------------------------------------------------------------------
;		REGISTRADORES A SEREM CONFIGURADOS NO CODIGO PRINCIPAL

;	T1CON(00110000)	- 5,4: Prescaler em 1:8
;					- 3: oscillator off
;					- 1: clock interno
;					- 0: stop TMR1
;	PIE1(00000001) - Habilita TMR1
;	TMR1H = 0b11111111;
;	TMR1L = 0b11010111;		conta 40us
;	INTCON(11000000) - Habilita interrupcoes
;----------------------------------------------------------------------------
;		PINOS A SEREM CONFIGURADOS NO CODIGO PRINCIPAL

;SAIDAS
;	PORTE,0 - RS (selecao de registro)
;	PORTE,1 - ENABLE (inicia o ciclo de leitura/escrita)

;ENTRADAS

;----------------------------------------------------------------------------
;								FUNCAO ON_LCD
;
;Protocolo para inicializacao do LCD, deixando-o preparado para uso.
;----------------------------------------------------------------------------
ON_LCD:				

	bcf 	RS 			; SELECIONA O DISPLAY P/ COMANDOS
	movlw 	0X38 		; ESCREVE COMANDO 0X38 PARA
	call 	ESCREVE	 	; INICIALIZACAO
	movlw	.12
	call	DELAY		; DELAY DE 12MS
	
	movlw	0X38 		; ESCREVE COMANDO 0X38 PARA
	call	ESCREVE		; INICIALIZACAO
	movlw	.12
	call	DELAY
	movlw	0X06 		; ESCREVE COMANDO 0X06 PARA
	call	ESCREVE 	; INICIALIZACAO
	movlw	.12
	call	DELAY
	
	movlw	0X0C		; ESCREVE COMANDO PARA
	call	ESCREVE		; INTERFACE DE 8 VIAS DE DADOS
						; DISPLAY: ON
						; BLINK: OFF
						; CURSOR: OFF
	movlw	.12
	call	DELAY
	
	movlw	0X01 		; ESCREVE COMANDO PARA
	call	ESCREVE	; LIMPAR TODO O DISPLAY
	movlw	.12
	call	DELAY		; DELAY DE 12MS
	
	bsf		RS
	
	movlw	0x83		;Posiciona o cursor na primeira linha
	bcf		RS
	call	ESCREVE
	bsf		RS

	movlw	'T'
	call	ESCREVE
	movlw	'e'
	call	ESCREVE
	movlw	'm'
	call	ESCREVE
	movlw	'p'
	call	ESCREVE
	movlw	'e'
	call	ESCREVE
	movlw	'r'
	call	ESCREVE
	movlw	'a'
	call	ESCREVE
	movlw	't'
	call	ESCREVE
	movlw	'u'
	call	ESCREVE
	movlw	'r'
	call	ESCREVE
	movlw	'a'
	call	ESCREVE
	
	return

;----------------------------------------------------------------------------
;								FUNCAO DELAY
;
;Rotina de delay generica. Deve-se entrar com o valor desejado em milisegundos
;----------------------------------------------------------------------------
DELAY:
	movwf	TEMPO_xms		
	movlw	.250			
	movwf	TEMPO_ms		;move 250 para a variavel TEMPO_ms

ESPERA:
	nop					
	decfsz	TEMPO_ms		;Decrementa a variavel para contar 1ms
	goto	ESPERA			;Se nao for zero volta para o inicio da funcao 
	
	decfsz	TEMPO_xms		;Decrementa a variavel para multiplicar o 1ms
	goto	ESPERA	
	
	return

;----------------------------------------------------------------------------
;								FUNCAO ESCREVE
;
;Processo para escrita de um determinado dado, ou comando, no LCD. Para
;comando, deve-se limpar RS antes de chama-la e setar apos seu termino.
;----------------------------------------------------------------------------

ESCREVE:
	bsf		ENABLE 		 
	movwf	PORTD	 	
	bcf 	ENABLE 		
	
	movlw	.250		;Aguarda um tempo de 250us para estabilizacao.
	movwf	TEMPO_us
	nop
	decfsz	TEMPO_us,f
	goto 	$-2
	
	return
;----------------------------------------------------------------------------
;								FUNCAO IMPRIME
;
;Imprime na tela do LCD no seguinte formato
;linha 1 - Temperatura (centralizado)
;linha 2 - 35.0 ºC (centralizado)
;----------------------------------------------------------------------------
IMPRIME:
	movlw	0xC4		;Posiciona o cursor na segunda linha
	bcf		RS
	call	ESCREVE
	bsf		RS
	
	movf	TEMPERATURA_c,W
	call	ESCREVE
	
	movf	TEMPERATURA_d,W
	call	ESCREVE
	
	movf	TEMPERATURA_u,W
	call	ESCREVE
	
	movlw	'.'
	call	ESCREVE

	movf	TEMPERATURA_x,W
	call	ESCREVE
		
	movlw	' '
	call	ESCREVE

	movlw	'C'
	call	ESCREVE

	return

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    FUN??O INICIALIZA_E2PROM   	     	       *
;*                                                   			   *
;* Esta Fun??o escreve 0x00 em todas as posi??es da mem?ria 	   * 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
INICIALIZA_E2PROM 
	movlw	.0
	movwf	DADO
	movwf	ENDERECO
	call	ESCR_E2PROM

	movlw	.255
	movwf	ENDERECO
	call	ESCR_E2PROM 
	
LOOP_MEMORIA:
	decfsz	ENDERECO
	goto	LIMPA_POSICAO
	return

LIMPA_POSICAO
	call	ESCR_E2PROM 
	goto	LOOP_MEMORIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*               	     FUN??O ESCR_E2PROM   	     	           *
;*                                                   			   *
;* Est? fun??o Recebe como Argumento um DADO e um ENDERECO, e faz  * 
;* a escrita na E2PROM do DADO na posi??o passada pelo ENDERECO    *
;* --------------------------------------------------------------- *
;* Vari?veis de Entrada:         |   Vari?veis de Sa?da:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* DADO		                     | 			                   	   *
;* ENDERECO		                 | 			                   	   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
ESCR_E2PROM 

	movf    DADO,W 
	BANK2     			;BANKSEL EEDATA 
	movwf   EEDATA 
	BANK0 
	movf    ENDERECO,W 
	BANK2     			;BANKSEL EEADR 
	movwf	EEADR 
	BANK3     			;BANKSEL EECON1 
	bcf		EECON1,EEPGD 
	bsf		EECON1,WREN 
	movlw	0x55 
	movwf	EECON2  	;OBRIGAT?RIO. 
	movlw	0xAA 
	movwf	EECON2  	;OBRIGAT?RIO.
	bsf		EECON1,WR   ;INICIA ESCRITA. 
	btfsc	EECON1,WR 
	goto$-1 
	bcf		EECON1,WREN 
	BANK0 

	return

