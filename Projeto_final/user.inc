;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   Biblioteca USER	                           *
;*                          UTFPR              		               *
;*         DESENVOLVIDO POR	MATHEUS MILANI DE ASSUNÇÃO			   *
;*						E RODRIGO SBARDELOTO KRAEMER	           *
;*   VERSÃO: 1.0                           DATA: 30/06/2016        *
;*               												   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;* ESTÁ BIBLIOTECA NÃO REQUER INCLUDE   	  				       *
;* A BIBLIOTECA USER FAZ A COMUNICAÇÃO DO KIT DIDATICO COM 		   *
;* O PC VIA USART, RECEBENDO DADOS DO USUARIO VERIFICANDO O BOTÃO  *
;* PRESSIONADO E TRANSMITINDO DADOS NA MEMORIA CORRESPONDENTE A    * 
;* ESTE VALOR PRESSIONADO  						                   *
;*-----------------------------------------------------------------*
;* Função USER										     	  	   *						   
;*-----------------------------------------------------------------*
;* Variáveis para serem declaradas no código principal:            *
;* 	ENDERECO1				; ROTINA PRINCIPAL			 		   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  FUNÇÃO USER						               *
;*                                                   			   *
;* ESTÁ FUNÇÃO TEM COMO ARGUMENTO A VARIAVEL TEMPERATURA       	   *
;* --------------------------------------------------------------- *
;* Variáveis de Entrada:         |   Variáveis de Saída:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* ENDERECO1					 |   	                  		   *
;* BOTAO						 |	  	                  	  	   *
;* FLAG			                 |   	                  	  	   *
;*-----------------------------------------------------------------*
;* ESTÁ ROTINA DEVE SER CHAMADA DEPOIS QUE O USUARIO PRESSIONAR    *
;* UMA TECLA DEPOIS FAZENDO-SE BUSCAR NA MEMORIA E2PROM O VALOR    *
;* CORRESPONDENTE NA MEMORIA E O ENVIANDO PARA O PC. E ESTE ESTADO *
;* FOI DEFINIDO COMO ESTADO NUMERO 6.							   *
;*-----------------------------------------------------------------*
USUARIO:
	BCF		INTCON, GIE							
	
	MOVF	ENDERECO2, W	; VARIAVEL RECEBIDA DO TERMINAL(PC)
	XORLW	D'50'
	BTFSS	STATUS, Z
		GOTO PROX1
	MOVF	ENDERECO1, W
	ADDLW	D'4'
	MOVWF	ENDERECO1
PROX1:
	XORLW	D'51'
	BTFSS	STATUS, Z
		GOTO PROX2
	MOVF	ENDERECO1, W
	ADDLW	D'8'
	MOVWF	ENDERECO1
PROX2:
	XORLW	D'52'
	BTFSS	STATUS, Z
		GOTO PROX3
	MOVF	ENDERECO1, W
	ADDLW	D'12'
	MOVWF	ENDERECO1
PROX3:
	XORLW	D'53'
	BTFSS	STATUS, Z
		GOTO PROX4
	MOVF	ENDERECO1, W
	ADDLW	D'16'
	MOVWF	ENDERECO1
PROX4:
; PRINTA O VALOR DA CENTENA-------------------------------------------------
	; BUSCA NA MEMORIA E2PROM
	MOVF   	ENDERECO1, W 	
	BANK2    			;BANKSEL EEADR 
	MOVWF  	EEADR 
	BANK3    			;BANKSEL EECON1 
	BCF    	EECON1, EEPGD 
	BSF    	EECON1, RD 
	BANK2     			;BANKSEL EEDATA 
	MOVF	EEDATA, W 
	BANK0     			;BANKSEL DADO 
	
	; BUSCA NA MEMORIA E2PROM
	MOVWF	TXREG			;Carrega dados para transmissao
	BANK1
		BTFSS	TXSTA,TRMT		;Testa quando a transmissao acabou
			GOTO	$-1
		BCF		TXSTA,TRMT
	BANK0
	movlw	.30
	call	DELAY
;---------------------------------------------------------------------------	
; PRINTA O VALOR DEZENA-----------------------------------------------------
	; BUSCA NA MEMORIA E2PROM
	INCF	ENDERECO1
	MOVF   	ENDERECO1, W 
	BANK2    			;BANKSEL EEADR 
	MOVWF  	EEADR 
	BANK3    			;BANKSEL EECON1 
	BCF    	EECON1, EEPGD 
	BSF    	EECON1, RD 
	BANK2     			;BANKSEL EEDATA 
	MOVF	EEDATA, W 
	BANK0     			;BANKSEL DADO 
	
	MOVWF	TXREG			;Carrega dados para transmissao
	BANK1
		BTFSS	TXSTA,TRMT		;Testa quando a transmissao acabou
			GOTO	$-1
		BCF		TXSTA,TRMT
	BANK0
	movlw	.30
	call	DELAY
;---------------------------------------------------------------------------	
; PRINTA O VALOR UNIDADE----------------------------------------------------
	; BUSCA NA MEMORIA E2PROM
	INCF	ENDERECO1
	MOVF   	ENDERECO1, W 

	BANK2    			;BANKSEL EEADR 
	MOVWF  	EEADR 
	BANK3    			;BANKSEL EECON1 
	BCF    	EECON1, EEPGD 
	BSF    	EECON1, RD 
	BANK2     			;BANKSEL EEDATA 
	MOVF	EEDATA, W 
	BANK0     			;BANKSEL DADO 

	MOVWF	TXREG			;Carrega dados para transmissao
	BANK1
		BTFSS	TXSTA,TRMT		;Testa quando a transmissao acabou
			GOTO	$-1
		BCF		TXSTA,TRMT
	BANK0
	
	MOVLW	','
	MOVWF	TXREG			;Carrega dados para transmissao
	BANK1
		BTFSS	TXSTA,TRMT		;Testa quando a transmissao acabou
			GOTO	$-1
		BCF		TXSTA,TRMT
	BANK0
	movlw	.30
	call	DELAY
;---------------------------------------------------------------------------	
; PRINTA O VALOR FRACIONARIO------------------------------------------------
	; BUSCA NA MEMORIA E2PROM
	INCF	ENDERECO1
	MOVF   	ENDERECO1, W 
	BANK2    			;BANKSEL EEADR 
	MOVWF  	EEADR 
	BANK3    			;BANKSEL EECON1 
	BCF    	EECON1, EEPGD 
	BSF    	EECON1, RD 
	BANK2     			;BANKSEL EEDATA 
	MOVF	EEDATA, W 
	BANK0     			;BANKSEL DADO 
	
	MOVWF	TXREG			;Carrega dados para transmissao
	BANK1
		BTFSS	TXSTA,TRMT		;Testa quando a transmissao acabou
			GOTO	$-1
		BCF		TXSTA,TRMT
	BANK0
	
	movlw	.30
	call	DELAY
;---------------------------------------------------------------------------	
; VAI PARA NOVA LINHA-------------------------------------------------------	
	MOVLW	D'10'
	MOVWF	TXREG			;Carrega dados para transmissao
	BANK1
		BTFSS	TXSTA,TRMT		;Testa quando a transmissao acabou
			GOTO	$-1
		BCF		TXSTA,TRMT
	BANK0
	movlw	.30
	call	DELAY
;---------------------------------------------------------------------------
	CLRF	ENDERECO1
	BCF		FLAG, 6
	BSF		INTCON, GIE
RETURN
