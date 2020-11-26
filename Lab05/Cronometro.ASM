; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CÓDIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Cronômetro
; Aluno: Matheus Milani de Assunção	
; Data:	15/04/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRIÇÃO GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Utilize a interrupção do Timer 0 como referência para temporizar 1 segundo.
; Escreva o tempo no display 7 segmentos: 00.00 (MM.SS).
; Ao pressionar a tecla 1 deve iniciar a contagem do cronômetro, atualizando o
; Display a cada segundo. Ao pressionar a tecla 2, a contagem deve ser parada.
; Com a tecla 3 a contagem é zerada, voltando o display para 00.00.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURAÇÃO DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Habilitar o dip switch CH3,1-4 (posição ON para cima);
; Habilitar todos os dips de CH4 (posição ON para cima);
; Habilitar o dip CH5,1-4 (posição ON para cima);
; Habilitar o dip CH6,1-4 (posição ON para cima);
; Desabilitar as demais chaves DIP;
; Manter o jumper J3 na posição B e J4 na posição A;
; L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...
; RE0 habilita o display 7 segmentos;
; D0 = ., D1 = g, D2 = f, D3 = e...

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         CONFIGURAÇÕES PARA GRAVAÇÃO                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 __CONFIG _WDT_OFF & _XT_OSC & _LVP_OFF & _DEBUG_ON & _BODEN_OFF

; _CP_OFF 	==> MEMÓRIA DE PROGRAMA DESPROTEGIDA CONTRA LEITURA.
; _WRT_OFF 	==> SEM PERMISSÃO PARA ESCREVER NA MEMÓRIA DE PROGRAMA
;				DURANTE EXECUÇÃO DO PROGRAMA.
; _DEBUG_ON	==> DEBUG ATIVADO.
; _CPD_OFF 	==> MEMÓRIA EEPROM PROTEGIDA CONTRA LEITURA.
; _LVP_OFF 	==> PROGRAMAÇÃO EM BAIXA TENSÃO DESABILITADA.
; _WDT_OFF 	==> WDT DESATIVADO.
; _BODEN_OFF	==> BROWN-OUT DESATIVADO. 
; _PWRTE_ON 	==> POWER-ON RESET ATIVADO.
; _XT_OSC 	==> OSCILADOR CRISTAL (4MHz).

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ARQUIVOS DE DEFINIÇÕES                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P16F877.INC>		;ARQUIVO PADRÃO MICROCHIP PARA 16F877

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         DEFINIÇÃO DAS CONSTANTES                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
T1	EQU		.250
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                	        	MACROS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINIÇÃO DAS VARIÁVEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CBLOCK	0x20 			; POSIÇÃO INICIAL DA RAM
		TEMPO_XMS			; VARIAVEL PARA DELAY
		UAU					; VARIAVEL PARA DELAY
		SEG_UNI				; VARIAVEL PARA UNIDADE DE SEGUNDO
		SEG_DEZ				; VARIAVEL PARA DEZENA DE SEGUNDO
		MIN_UNI				; VARIAVEL PARA UNIDADE DE MINUTO
		MIN_DEZ				; VARIAVEL PARA DEZENA DE MINUTO
		SAVE_W				; VARIAVEL PARA GUARDAR O VALOR DE W NA INTERUPÇÃO
		SAVE_STATUS			; VARIAVEL PARA GUARDAR O VALOR DE STATUS NA INTERRUPÇÃO
		VAR					; VARIAVEL RESPONSAVEL PARA AJUDAR NA CONTAGEM DE TMR0
		FLAG				; VARIAVEL RESPONSAVEL PELA MAQUINA DE FLAGS
		QUAL_DISP
	ENDC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      DEFINIÇÃO DOS BANCOS DA RAM                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
BANK0	MACRO					;SELECIONA BANK0 DE MEMÓRIA.
				bcf STATUS,RP1
				bcf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK0.

BANK1	MACRO					;SELECIONA BANK1 DE MEMÓRIA.
				bcf STATUS,RP1
				bsf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK1.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                 FLAG                                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                               ENTRADAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                SAÍDAS                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO.
	goto	Inicio

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               VETOR DE INTERRUPÇÃO DO MICROCONTROLADOR                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x04			; ENDEREÇO INICIAL DA INTERRUPÇÃO.
Interrupcao:			; FUNÇÃO PARA TRATAMENTO DA INTERRUPÇÃO

	MOVWF	SAVE_W			; GUARDA O VALOR DE W
	SWAPF	STATUS,W		; INVERTE OS NIBBLES PARA NÃO TER RISCO DE ALTERA-LOS
	MOVWF	SAVE_STATUS		; GUARDA O STATUS

	BTFSS	INTCON, 2
		GOTO	COME
	BCF		INTCON, 2
	MOVLW	D'6'
	MOVWF	TMR0
	DECFSZ	VAR
		GOTO	COME
	MOVLW	D'250'
	MOVWF	VAR
	BTFSC	FLAG, 5
		INCF	SEG_UNI, F
COME:

	SWAPF	 SAVE_STATUS, W
	MOVWF	 STATUS 	; RECUPERA STATUS
	SWAPF	 SAVE_W, F
	SWAPF	 SAVE_W, W 		

RETFIE
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURAÇÕES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina são inicializadas as portas de I/O do microcontrolador, os
; periféricos que serão usados e as configurações dos registradores 
; especiais (SFR). 

Inicio:

BANK1					; ALTERA PARA O BANCO 1.
	MOVLW	B'10100000'		;;
	MOVWF	INTCON			;;
	MOVLW	B'00000101'		;; VALORES PARA FUNCIONAR O CONTADOR TMR0
	MOVWF	OPTION_REG		;;
	MOVLW	B'00000101'		;;
	MOVWF	ADCON1			;;
	MOVLW	B'11011111'		; PORTA UTILIZADA COMO SAIDA RA5
	MOVWF	TRISA
	MOVLW	B'11111111'		; PORTAS UTILIZADAS COMO ENTRADA 0, 1 E 2
	MOVWF	TRISB
	MOVLW	B'11111110'		; PORTA UTILIZADA COMO SAIDA PORTA 0
	MOVWF	TRISC
	MOVLW	B'00000000'		; TODAS AS PORTAS D SÃO SAIDAS
	MOVWF	TRISD
	MOVLW	B'11111000'		; PORTAS UTILIZADAS COMO SAIDA 0, 1 E 2
	MOVWF	TRISE
BANK0					; RETORNA PARA O BANCO 0.
	MOVLW	B'11011111'		; VALOR PARA O TRANSISTOR PARA LIGAR O DISPLAY
	MOVWF	PORTA
	MOVLW	B'11111110'		; LINHA 0 É A UNICA LIGADA 
	MOVWF	PORTC	
	MOVLW	B'00000000'		; VALORES DOS LED'S SÃO TODOS '1', APAGADO
	MOVWF	PORTD			
	MOVLW	B'11111000'		; VALOR PARA OS TRANSISTORES PARA LIGAR O DISPLAY 
	MOVWF	PORTE		


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZAÇÃO DA RAM                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  LIMPA DE TODA A RAM DO BANC0 0, INDO DE 0X20 A 0X7F.
	movlw	0x20
	movwf	FSR				; APONTA O ENDEREÇAMENTO INDIRETO PARA
							; A PRIMEIRA POSIÇÃO DA RAM.
LIMPA_RAM
	clrf	INDF			; LIMPA A POSIÇÃO ATUAL.
	incf	FSR,F			; INCREMENTA PONTEIRO P/ A PRÓX. POS.
	movf	FSR,W
	xorlw	0x80			; COMPARA PONTEIRO COM A ÚLT. POS. +1.
	btfss	STATUS,Z		; JÁ LIMPOU TODAS AS POSIÇÕES?
	goto	LIMPA_RAM		; NÃO, LIMPA A PRÓXIMA POSIÇÃO.
							; SIM, CONTINUA O PROGRAMA.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZAÇÃO DAS VARIAVEIS                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	B'00000000'			; MAQUINA DE FLAGS, SEMPRE ENTRA NA FLAG0 QUANDO INICIALIZADA 
	MOVWF	FLAG
	BSF		FLAG, 0
	BSF		FLAG, 4
	BSF		FLAG, 5
	MOVLW	D'125'				; VARxTMR0x64 = 4000000
	MOVWF	VAR
	CLRF	SEG_UNI				; VARIAVEL PARA UNIDADE DE SEGUNDO
	CLRF	SEG_DEZ				; VARIAVEL PARA DEZENA DE SEGUNDO
	CLRF	MIN_UNI				; VARIAVEL PARA UNIDADE DE MINUTO
	CLRF	MIN_DEZ				; VARIAVEL PARA DEZENA DE MINUTO
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      ROTINAS E SUBROTINAS                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
TABELA:
	;MOVFW	SEG_UNI
	ADDWF	PCL, F				; ADICIONA O VALOR DA VARIAVEL AO PCL, QUE PULA PARA QUAL RETORNO DESEJA
		RETLW	B'00000011'		; 0 - RETORNA OS VALORES PARA ACIONAR OS LED's    
		RETLW	B'10011111'		; 1
		RETLW	B'00100101'		; 2
		RETLW	B'00001101'		; 3
		RETLW	B'10011001'		; 4
		RETLW	B'01001001'		; 5
		RETLW	B'01000001'		; 6
		RETLW	B'00011111'		; 7
		RETLW	B'00000001'		; 8
		RETLW	B'00011001'		; 9
		RETLW	B'00010001'		; A
		RETLW	B'11000001'		; b
		RETLW	B'01100011'		; C
		RETLW	B'10000101'		; d
		RETLW	B'01100001'		; E
		RETLW	B'01110001'		; F
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
START_CRON:

	BSF	FLAG, 5
	BCF	FLAG, 1

RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
RESET_CRON:

	CLRF	SEG_UNI				; VARIAVEL PARA UNIDADE DE SEGUNDO
	CLRF	SEG_DEZ				; VARIAVEL PARA DEZENA DE SEGUNDO
	CLRF	MIN_UNI				; VARIAVEL PARA UNIDADE DE MINUTO
	CLRF	MIN_DEZ				; VARIAVEL PARA DEZENA DE MINUTO
	BCF		FLAG, 5
	BCF		FLAG, 2

RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
STOP_CRON:

	BCF		FLAG, 5
	BCF		FLAG, 3

RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ATUALIZA_CRON:
	MOVF	SEG_UNI, W
	XORLW	D'10'
	BTFSS	STATUS, Z
		GOTO	FIM
	INCF	SEG_DEZ
	CLRF	SEG_UNI

	;MOVF	SEG_DEZ, W
	;XORLW	D'6'
	;BTFSS	STATUS, Z
	;	GOTO	FIM
	;INCF	MIN_UNI
	;CLRF	SEG_DEZ

	;MOVF	MIN_UNI, W
	;XORLW	D'10'
	;BTFSS	STATUS, Z
	;	GOTO	FIM
	;INCF	MIN_DEZ
	;CLRF	MIN_UNI
FIM:
	CALL PRINT
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
PRINT:
	MOVLW	B'11111000'
	MOVWF	PORTE
	;BCF		PORTE, 0
	;BSF		PORTE, 1
	;BSF		PORTE, 2
	;BSF		PORTA, 5
	MOVLW	B'11111111'
	MOVWF	PORTA
	MOVLW	B'00001111'
	ANDWF	SEG_UNI, W
	
	CALL	TABELA
	;MOVLW	B'00011001'	
	MOVWF	PORTD
	CALL	DELAY

	;MOVLW	B'11111101'
	;MOVWF	PORTE
	;BCF		PORTE, 0
	;BSF		PORTE, 1
	;BSF		PORTE, 2
	;BSF		PORTA, 5
	;MOVLW	B'11111111'
	;MOVWF	PORTA
	;MOVLW	B'00001111'
	;ANDWF	SEG_DEZ, W
	
	;CALL	TABELA
	;MOVLW	B'00011001'	
	;MOVWF	PORTD
	;CALL	DELAY

RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
DELAY: 							; FUNÇÃO DELAY
	MOVLW	D'250'
	MOVWF	UAU	
DELAY_2:
	MOVLW	T1					; MOVE A CONST. DE TEMPO "250" PARA WORK
	MOVWF	TEMPO_XMS				; MOVE O CONTEUDO DE WORK PARA A VARIAVEL TEMPO_XMS
DELAY_1:
	NOP							; REPETE-SE 10x NOP PARA DAR 10 CICLOS DE MAQUINA
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ	TEMPO_XMS,F			; DIMINUI TEMPO_XMS ATÉ QUE SEJA 0
		GOTO	DELAY_1
	DECFSZ	UAU,F				; DECREMENTA UAU ATÉ QUE SEJA 0
		GOTO	DELAY_2
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
DELAY_DISP:							; FUNÇÃO DELAY
	MOVLW	D'50'
	MOVWF	UAU	
DELAY_3:
	NOP
	DECFSZ	UAU,F				; DECREMENTA UAU ATÉ QUE SEJA 0
		GOTO	DELAY_3
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; - -  
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	                       	ROTINA PRINCIPAL                                *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	BTFSC	FLAG, 0
		CALL	LE_TECLADO
	
	BTFSC	FLAG, 1
		CALL	START_CRON

	BTFSC	FLAG, 2
		CALL	RESET_CRON

	BTFSC	FLAG, 3
		CALL	STOP_CRON
	
	BTFSC	FLAG, 4
		CALL	ATUALIZA_CRON

GOTO MAIN

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
LE_TECLADO
	BTFSS	PORTB, 0
		GOTO	$ + 4
;		CALL	DELAY
		NOP
		BTFSS	PORTB, 0
			BSF	FLAG, 1	
	BTFSS	PORTB, 1
		GOTO	$ + 4
;		CALL	DELAY
		NOP
		BTFSS	PORTB, 1
			BSF	FLAG, 2
	BTFSS	PORTB, 2
		GOTO	$ + 4
;		CALL	DELAY
		NOP
		BTFSS	PORTB, 2
			BSF	FLAG, 3
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA