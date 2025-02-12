;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   Biblioteca E2PROM	                           *
;*                          UTFPR              		               *
;*         DESENVOLVIDO POR	MATHEUS MILANI DE ASSUN��O			   *
;*						E RODRIGO SBARDELOTO KRAEMER	           *
;*   VERS�O: 1.0                           DATA: 30/06/2016        *
;*               												   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;* EST� BIBLIOTECA N�O REQUER INCLUDE   	  				       *
;* A BIBLIOTECA E2PROM  GRAVA DADOS NA MEMORIA E2PROM DO 		   *
;* MICROCONTROLADOR, SENDO GRAVADO EM APENAS 5 ESPA�OS DA MEMORIA. *
;*-----------------------------------------------------------------*
;* Fun��o E2PROM									     	  	   *						   
;*-----------------------------------------------------------------*
;* Vari�veis para serem declaradas no c�digo principal:            *
;* 	ENDERECO				; ROTINA PRINCIPAL			 		   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  FUN��O E2PROM					               *
;*                                                   			   *
;* EST� FUN��O TEM COMO ARGUMENTO A VARIAVEL TEMPERATURA       	   *
;* --------------------------------------------------------------- *
;* Vari�veis de Entrada:         |   Vari�veis de Sa�da:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* TEMPERATURA_c				 |   	                  	  	   *
;* TEMPERATURA_d				 |   	                  	  	   *
;* TEMPERATURA_u				 |   	                  	  	   *
;* TEMPERATURA_x				 |   	                  	  	   *
;* FLAG			                 |   	                  	  	   *
;*-----------------------------------------------------------------*
;* EST� ROTINA DEVE SER CHAMADA A CADA 30 SEGUNDO PARA GRAVA O 	   *
;* VALOR ATUAL DA TEMPERATURA NA MEMORIA E2PROM, N�O DEPENDENDO    *
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
	MOVWF	EECON2  	;OBRIGAT�RIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGAT�RIO.
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
	MOVWF	EECON2  	;OBRIGAT�RIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGAT�RIO.
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
	MOVWF	EECON2  	;OBRIGAT�RIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGAT�RIO.
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
	MOVWF	EECON2  	;OBRIGAT�RIO. 
	MOVLW	0xAA 
	MOVWF	EECON2  	;OBRIGAT�RIO.
	BSF		EECON1, WR   ;INICIA ESCRITA. 
	BTFSC	EECON1, WR 
		GOTO	$ - 1 
	BSF		INTCON, GIE
	BCF		EECON1, WREN 
	BANK0 
	INCF	ENDERECO
	
RETURN
