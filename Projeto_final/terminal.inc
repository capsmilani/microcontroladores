;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   Biblioteca TERMINAL                           *
;*                          UTFPR              		               *
;*         DESENVOLVIDO POR	MATHEUS MILANI DE ASSUN��O			   *
;*						E RODRIGO SBARDELOTO KRAEMER	           *
;*   VERS�O: 1.0                           DATA: 30/06/2016        *
;*               												   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;* N�O REQUER INCLUDE DE OUTRAS BIBLIOTECAS  				       *
;* A BIBLIOTECA TERMINAL FAZ A COMUNICA��O DO KIT DIDATICO COM     *
;* O PC VIA USART, APENAS TRANSMITINDO DADOS                       *
;*-----------------------------------------------------------------*
;* Fun��o TERMINAL										       	   *						   
;*-----------------------------------------------------------------*
;* Vari�veis para serem declaradas no c�digo principal:            *
;* AUXTRANS					; ROTINA PRINCIPAL			 		   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  FUN��O TERMINAL					               *
;*                                                   			   *
;* EST� FUN��O TEM COMO ARGUMENTO A VARIAVEL TEMPERATURA       	   *
;* --------------------------------------------------------------- *
;* Vari�veis de Entrada:         |   Vari�veis de Sa�da:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* TEMPERATURA_c                 |   	                  	  	   *
;* TEMPERATURA_d                 |   	                  	  	   *
;* TEMPERATURA_u                 |   	                  	  	   *
;* TEMPERATURA_x                 |   	                  	  	   *
;* FLAG			                 |   	                  	  	   *
;*-----------------------------------------------------------------*
;* EST� ROTINA DEVE SER CHAMADA DEPOIS QUE A VARIAVEL TEMPERATURA  *
;* FOR CONVERTIDA EM CENTENA, DEZENA, UNIDADE E NUMERO FRACIONARIO *		
;* E TEM COMO ESTADO NA MAQUINA DE ESTADOS NUMERO 3				   *
;*-----------------------------------------------------------------*
SEND:	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_c,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL

	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_d,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_u,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movlw	'.'
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_x,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movlw	'C'
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movlw	.10
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;J� TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	bcf		FLAG,3
	
RETURN
