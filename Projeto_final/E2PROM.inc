;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   Biblioteca E2PROM	                           *
;*                          UTFPR              		               *
;*         DESENVOLVIDO POR	MATHEUS MILANI DE ASSUNÇÃO			   *
;*						E RODRIGO SBARDELOTO KRAEMER	           *
;*   VERSÃO: 1.0                           DATA: 30/06/2016        *
;*               												   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;* ESTÁ BIBLIOTECA NÃO REQUER INCLUDE   	  				       *
;* A BIBLIOTECA E2PROM  GRAVA DADOS NA MEMORIA E2PROM DO 		   *
;* MICROCONTROLADOR, SENDO GRAVADO EM APENAS 5 ESPAÇOS DA MEMORIA. *
;*-----------------------------------------------------------------*
;* Função E2PROM									     	  	   *						   
;*-----------------------------------------------------------------*
;* Variáveis para serem declaradas no código principal:            *
;* 	ENDERECO				; ROTINA PRINCIPAL			 		   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  FUNÇÃO E2PROM					               *
;*                                                   			   *
;* ESTÁ FUNÇÃO TEM COMO ARGUMENTO A VARIAVEL TEMPERATURA       	   *
;* --------------------------------------------------------------- *
;* Variáveis de Entrada:         |   Variáveis de Saída:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* TEMPERATURA_c				 |   	                  	  	   *
;* TEMPERATURA_d				 |   	                  	  	   *
;* TEMPERATURA_u				 |   	                  	  	   *
;* TEMPERATURA_x				 |   	                  	  	   *
;* FLAG			                 |   	                  	  	   *
;*-----------------------------------------------------------------*
;* ESTÁ ROTINA DEVE SER CHAMADA A CADA 30 SEGUNDO PARA GRAVA O 	   *
;* VALOR ATUAL DA TEMPERATURA NA MEMORIA E2PROM, NÃO DEPENDENDO    *
;* DE OUTRO ESTADO. ESTE ESTADO TEM GRAU 5.						   *
;*-----------------------------------------------------------------*
MEMORIA:	
	MOVF	ENDERECO, W
	XORLW	D'20'
	BTFSS	STATUS, Z
		GOTO	AQUI
	CLRF	ENDERECO
AQUI:
	MOVF    TEMPERATURA_c, W 
	BANK2     			;BANKSEL EEDATA 
	MOVWF   EEDATA 
	BANK0 
	MOVF    ENDERECO, W 
	BANK2     			;BANKSEL EEADR 
	MOVWF	EEADR 
	BANK3     			;BANKSEL EECON1 
	BCF		EECON1, EEPGD 
	BSF		EECON1, WREN 
	BCF		INTCON, GIE
	MOVLW	0x55 
	MOVWF	EECON2  	;OBRIGATÓRIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGATÓRIO.
	BSF		EECON1, WR   ;INICIA ESCRITA. 
	BTFSC	EECON1, WR 
		GOTO	$ - 1 
	BSF		INTCON, GIE
	BCF		EECON1, WREN 
	BANK0 
	
	
	MOVF    TEMPERATURA_d, W 
	BANK2     			;BANKSEL EEDATA 
	MOVWF   EEDATA 
	BANK0 
	INCF	ENDERECO
	MOVF    ENDERECO, W 
	BANK2     			;BANKSEL EEADR 
	MOVWF	EEADR 
	BANK3     			;BANKSEL EECON1 
	BCF		EECON1, EEPGD 
	BSF		EECON1, WREN 
	BCF		INTCON, GIE
	MOVLW	0x55 
	MOVWF	EECON2  	;OBRIGATÓRIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGATÓRIO.
	BSF		EECON1, WR   ;INICIA ESCRITA. 
	BTFSC	EECON1, WR 
		GOTO	$ - 1 
	BSF		INTCON, GIE
	BCF		EECON1, WREN 
	BANK0 

	
	MOVF    TEMPERATURA_u, W 
	BANK2     			;BANKSEL EEDATA 
	MOVWF   EEDATA 
	BANK0 
	INCF	ENDERECO
	MOVF    ENDERECO, W 
	BANK2     			;BANKSEL EEADR 
	MOVWF	EEADR 
	BANK3     			;BANKSEL EECON1 
	BCF		EECON1, EEPGD 
	BSF		EECON1, WREN 
	BCF		INTCON, GIE
	MOVLW	0x55 
	MOVWF	EECON2  	;OBRIGATÓRIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGATÓRIO.
	BSF		EECON1, WR   ;INICIA ESCRITA. 
	BTFSC	EECON1, WR 
		GOTO	$ - 1 
	BSF		INTCON, GIE
	BCF		EECON1, WREN 
	BANK0 
	
	MOVF    TEMPERATURA_x, W 
	BANK2     			;BANKSEL EEDATA 
	MOVWF   EEDATA 
	BANK0 
	INCF	ENDERECO
	MOVF    ENDERECO, W 
	BANK2     			;BANKSEL EEADR 
	MOVWF	EEADR 
	BANK3     			;BANKSEL EECON1 
	BCF		EECON1, EEPGD 
	BSF		EECON1, WREN 
	BCF		INTCON, GIE
	MOVLW	0x55 
	MOVWF	EECON2  	;OBRIGATÓRIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGATÓRIO.
	BSF		EECON1, WR   ;INICIA ESCRITA. 
	BTFSC	EECON1, WR 
		GOTO	$ - 1 
	BSF		INTCON, GIE
	BCF		EECON1, WREN 
	BANK0 
	INCF	ENDERECO
	
RETURN
