; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   C�DIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: PWM 1
; Aluno: Matheus Milani de Assun��o	
; Data:	17/06/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRI��O GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Utilize a sa�da PWM1 (RC2), para controlar a intensidade
; luminosa da l�mpada;
; Utilize as teclas 0 a 3 para controlar a intensidade, com:
; 0: 0%;
; 1: 33%
; 2: 66%
; 3: 100%

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURA��O DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Configurar as chaves e jumpers:
; Habilitar a chave CH2,2 (posi��o ON para cima)
; Habilitar a chave CH3,1 (posi��o ON para cima)
; Habilitar as chaves CH5,1 a CH5,4 (posi��o ON para cima)
; Desabilitar as demais chaves DIP
; Manter o jumper J1 e J2 na posi��o B
; Manter o jumper J3 e J4 na posi��o A

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         CONFIGURA��ES PARA GRAVA��O                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 __CONFIG _WDT_OFF & _XT_OSC & _LVP_OFF & _DEBUG_ON & _BODEN_OFF

;_CP_OFF 	==> MEM�RIA DE PROGRAMA DESPROTEGIDA CONTRA LEITURA.
;_WRT_OFF 	==> SEM PERMISS�O PARA ESCREVER NA MEM�RIA DE PROGRAMA
;				DURANTE EXECU��O DO PROGRAMA.
;_DEBUG_ON	==> DEBUG ATIVADO.
;_CPD_OFF 	==> MEM�RIA EEPROM PROTEGIDA CONTRA LEITURA.
;_LVP_OFF 	==> PROGRAMA��O EM BAIXA TENS�O DESABILITADA.
;_WDT_OFF 	==> WDT DESATIVADO.
;_BODEN_OFF	==> BROWN-OUT DESATIVADO. 
;_PWRTE_ON 	==> POWER-ON RESET ATIVADO.
;_XT_OSC 	==> OSCILADOR CRISTAL (4MHz).

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ARQUIVOS DE DEFINI��ES                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P16F877.INC>		;ARQUIVO PADR�O MICROCHIP PARA 16F877

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         DEFINI��O DAS CONSTANTES                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                	        	MACROS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINI��O DAS VARI�VEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CBLOCK	0X20				; POSI��O INICIAL DA RAM
								; PRESSIONADA
	ENDC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      DEFINI��O DOS BANCOS DA RAM                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
BANK0	MACRO					;SELECIONA BANK0 DE MEM�RIA.
				bcf STATUS,RP1
				bcf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK0.

BANK1	MACRO					;SELECIONA BANK1 DE MEM�RIA.
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
; *                                SA�DAS                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO.
	goto	Inicio

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               VETOR DE INTERRUP��O DO MICROCONTROLADOR                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O.

Interrupcao:			;FUN��O PARA TRATAMENTO DA INTERRUP��O

	retfie
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURA��ES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina s�o inicializadas as portas de I/O do microcontrolador, os
; perif�ricos que ser�o usados e as configura��es dos registradores 
; especiais (SFR). 

Inicio:
BANK1					; ALTERA PARA O BANCO 1.
	MOVLW	B'11111010'		; DEFINE AS PORTAS 0 E 1 COMO SAIDA
	MOVWF	TRISC
	MOVLW	B'11111111'		; DEFINE AS PORTAS 0 A 7 COMO ENTRADA
	MOVWF	TRISB
	MOVLW	B'00000000'
	MOVWF	INTCON
	MOVLW	B'00000010'
	MOVWF	PIE1
	MOVLW	B'00000000'
	MOVWF	PIE2
	MOVLW	B'01100011'		; DEFINE 99 PARA PR2
	MOVWF	PR2
	MOVLW	B'00000000'
	MOVWF	OPTION_REG
BANK0					; RETORNA PARA O BANCO 0.
	MOVLW	B'00000010'
	MOVWF	PIR1
	MOVLW	B'00000001'
	MOVWF	PIR2
	MOVLW	B'00000100'		; HABILITANDO O TMR2
	MOVWF	T2CON
	MOVLW	B'11111110'		; LIGANDO A LINHA 0 DO TECLADO
	MOVWF	PORTC			
	MOVLW	B'00001100'		; LIGANDO O CCP1 COMO PWM
	MOVWF	CCP1CON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZA��O DA RAM                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  LIMPA DE TODA A RAM DO BANC0 0, INDO DE 0X20 A 0X7F.
	movlw	0x20
	movwf	FSR				; APONTA O ENDERE�AMENTO INDIRETO PARA
							; A PRIMEIRA POSI��O DA RAM.
LIMPA_RAM
	clrf	INDF			; LIMPA A POSI��O ATUAL.
	incf	FSR,F			; INCREMENTA PONTEIRO P/ A PR�X. POS.
	movf	FSR,W
	xorlw	0x80			; COMPARA PONTEIRO COM A �LT. POS. +1.
	btfss	STATUS,Z		; J� LIMPOU TODAS AS POSI��ES?
	goto	LIMPA_RAM		; N�O, LIMPA A PR�XIMA POSI��O.
					; SIM, CONTINUA O PROGRAMA.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	                       	ROTINA PRINCIPAL                                *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN								; UTILIZANDO APENAS 8BITS DO PWM

	BTFSC	PORTB, 0				; TESTA SE O PRIMEIRO BOT�O FOI CLICADO
		GOTO	$ + 5				
	MOVLW	B'00000000'				;
	MOVWF	CCPR1L					; DESLIGA A LAMPADA	
	BCF		CCP1CON, 4				;
	BCF		CCP1CON, 5				;
	
	BTFSC	PORTB, 1				; TESTA SE O SEGUNDO BOT�O FOI CLICADO
		GOTO	$ + 5
	MOVLW	B'00010101'				;
	MOVWF	CCPR1L					; ATRIBUI 33% DO VALOR PARA A LAMPADA
	BSF		CCP1CON, 4				;
	BCF		CCP1CON, 5				;
		
	BTFSC	PORTB, 2
		GOTO	$ + 5
	MOVLW	B'00101010'				;
	MOVWF	CCPR1L					; ATRIBUI 66% DO VALOR PARA A LAMPADA
	BCF		CCP1CON, 4				;
	BSF		CCP1CON, 5				;
	
	BTFSC	PORTB, 3
		GOTO	$ + 5
	MOVLW	B'00111111'				;
	MOVWF	CCPR1L					; ATRIBUI 100% DO VALOR PARA A LAMPADA
	BSF		CCP1CON, 4				;
	BSF		CCP1CON, 5				;
		
GOTO	MAIN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	               VALOR INICIAL DA LINHA				       	            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; *                                                                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA