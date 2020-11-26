;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                   Biblioteca MemoriasDec                        *
;*                          UTFPR              		               *
;*         DESENVOLVIDO POR	ADRIANO REICHERT         		       *
;*   VERSÃO: 1.0                           DATA: 30/10/2015        *
;*               												   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*           										   			   *
;*             	  	 Memórias FLASH e E2PROM					   *
;*-----------------------------------------------------------------*
;* A Biblioteca MemoriasDec Apresenta no LCD os valores em  	   *
;* Base Decimal							       				       *
;* A Biblioteca MemoriasHex Apresenta no LCD os valores em  	   *
;* Base Hexadecimal							       				   *
;* Apenas uma destas Bibliotecas deve ser incluida ao projeto,	   *
;* As duas ao mesmo tempo entram em conflito					   *
;*-----------------------------------------------------------------*
;* Requer Include da Biblioteca Teclado							   *
;* Requer Include da Biblioteca LCD							       *
;* Requer Include da Biblioteca Decimal						       *	
;*-----------------------------------------------------------------*
;* Função ESCR_E2PROM   										   *		
;* Função LEIT_E2PROM 											   *
;* Função ESCR_FLASH											   *
;* Função LEIT_FLASH 											   *
;* Função INICIALIZA_DISPLAY_E2PROM								   *
;* Função MENU_E2PROM											   *
;* Função ATUALIZA_DISPLAY_ENDERECO								   *
;* Função ATUALIZA_DISPLAY_DADO									   *
;* Função LIMPA_DISPLAY_DADO									   *
;* Função INICIALIZA_E2PROM 									   *					   
;*-----------------------------------------------------------------*
;* Variáveis para serem declaradas no código principal:            *
;* ENDERECO		;Biblioteca MemoriasDec							   *
;* ENDERECO_H	;Biblioteca MemoriasDec						       *
;* ENDERECO_L	;Biblioteca MemoriasDec						   	   *
;* DADO			;Biblioteca MemoriasDec							   *
;* DADO_H		;Biblioteca MemoriasDec							   *
;* DADO_L		;Biblioteca MemoriasDec							   *
;* AUXTECLA		;Biblioteca MemoriasDec							   *									   			   
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MEMORIA:

	MOVF	ENDERECO, W
	XORLW	D'20'
	BTFSS	STATUS, Z
		GOTO	AQUI
	movlw	0X00
	movwf	ENDERECO

AQUI:
	movf	TEMPERATURA_c,W
	movwf	DADO
	call	ESCREVE_E2PROM
	
	movlw	.5
	call	DELAY
	
	movf	TEMPERATURA_d,W
	movwf	DADO
	incf	ENDERECO
	call	ESCREVE_E2PROM
	
	movlw	.5
	call	DELAY
	
	movf	TEMPERATURA_u,W
	movwf	DADO
	incf	ENDERECO
	call	ESCREVE_E2PROM
	
	movlw	.5
	call	DELAY
	
	movf	TEMPERATURA_x,W
	movwf	DADO
	incf	ENDERECO
	call	ESCREVE_E2PROM
	
	incf	ENDERECO
	return


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*               	     FUNÇÃO ESCR_E2PROM   	     	           *
;*                                                   			   *
;* Está função Recebe como Argumento um DADO e um ENDERECO, e faz  * 
;* a escrita na E2PROM do DADO na posição passada pelo ENDERECO    *
;* --------------------------------------------------------------- *
;* Variáveis de Entrada:         |   Variáveis de Saída:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* DADO		                     | 			                   	   *
;* ENDERECO		                 | 			                   	   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
ESCREVE_E2PROM 

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
	movwf	EECON2  	;OBRIGATÓRIO. 
	movlw	0xAA 
	movwf	EECON2  	;OBRIGATÓRIO.
	bsf		EECON1,WR   ;INICIA ESCRITA. 
	btfsc	EECON1,WR 
	goto$-1 
	bcf		EECON1,WREN 
	BANK0 
	return


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*               	     FUNÇÃO LEIT_E2PROM    	     	           *
;*                                                   			   *
;* Está função Recebe como Argumento um ENDERECO, então faz a  	   * 
;* leitura da E2PROM na posição passada pelo ENDERECO,	           *
;* O conteúdo desta posição é passado para DADO	           		   *
;* --------------------------------------------------------------- *
;* Variáveis de Entrada:         |   Variáveis de Saída:    	   *
;*     (Argumentos)              |       (Retornos)   			   *
;* ENDERECO		                 | DADO				               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LEIT_E2PROM 
;	bcf		INTCON,GIE	;DesLiga chave geral de int

	movf   	ENDERECO,W 
	BANK2    			;BANKSEL EEADR 
	movwf  	EEADR 
	BANK3    			;BANKSEL EECON1 
	bcf    	EECON1,EEPGD 
	bsf    	EECON1,RD 
	BANK2     			;BANKSEL EEDATA 
	movf	EEDATA,W 
	BANK0     			;BANKSEL DADO 
	movwf	DADO 

;	bsf		INTCON,GIE	;Liga chave geral de int
	return

