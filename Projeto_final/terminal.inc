;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   Biblioteca TERMINAL                           *
;*                          UTFPR              		               *
;*         DESENVOLVIDO POR	MATHEUS MILANI DE ASSUNÇÃO			   *
;*						E RODRIGO SBARDELOTO KRAEMER	           *
;*   VERSÃO: 1.0                           DATA: 30/06/2016        *
;*               												   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;* NÃO REQUER INCLUDE DE OUTRAS BIBLIOTECAS  				       *
;* A BIBLIOTECA TERMINAL FAZ A COMUNICAÇÃO DO KIT DIDATICO COM     *
;* O PC VIA USART, APENAS TRANSMITINDO DADOS                       *
;*-----------------------------------------------------------------*
;* Função TERMINAL										       	   *						   
;*-----------------------------------------------------------------*
;* Variáveis para serem declaradas no código principal:            *
;* AUXTRANS					; ROTINA PRINCIPAL			 		   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  FUNÇÃO TERMINAL					               *
;*                                                   			   *
;* ESTÁ FUNÇÃO TEM COMO ARGUMENTO A VARIAVEL TEMPERATURA       	   *
;* --------------------------------------------------------------- *
;* Variáveis de Entrada:         |   Variáveis de Saída:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* TEMPERATURA_c                 |   	                  	  	   *
;* TEMPERATURA_d                 |   	                  	  	   *
;* TEMPERATURA_u                 |   	                  	  	   *
;* TEMPERATURA_x                 |   	                  	  	   *
;* FLAG			                 |   	                  	  	   *
;*-----------------------------------------------------------------*
;* ESTÁ ROTINA DEVE SER CHAMADA DEPOIS QUE A VARIAVEL TEMPERATURA  *
;* FOR CONVERTIDA EM CENTENA, DEZENA, UNIDADE E NUMERO FRACIONARIO *		
;* E TEM COMO ESTADO NA MAQUINA DE ESTADOS NUMERO 3				   *
;*-----------------------------------------------------------------*
SEND:	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_c,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL

	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_d,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_u,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movlw	'.'
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movf	TEMPERATURA_x,W
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movlw	'C'
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	movlw	.30
	call	DELAY
	
	BCF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	movlw	.10
	MOVWF	TXREG		;MOVE O DADO A SER TRANSMITIDO PARA O BUFFER DO TRANSMISSOR
	BANK1
	BTFSS 	TXSTA,TRMT	;JÁ TRANSMITIU O DADO?
	GOTO 	$-1
	BANK0
	BSF		INTCON,GIE		;; HABILITA INTERRUPCAO GLOBAL
	
	bcf		FLAG,3
	
RETURN
