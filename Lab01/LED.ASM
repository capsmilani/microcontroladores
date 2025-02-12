; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   C�DIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Lab01 - Chaves e LED's
; Aluno: Matheus Milani de Assun��o
; Data:	31/03/2016
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRI��O GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Chave A liga LEDs 0 e 4, B liga LEDs 1 e 5, C liga LEDs 2 e 6, D liga 
; LEDs 3 e 7.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURA��O DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Habilitar o dip switch CH3 posi��o 6 (posi��o ON para cima);
;Habilitar o dip CH5,1-4 (posi��o ON para cima);
;Habilitar todos os dips de CH4 (posi��o ON para cima);
;Desabilitar as demais chaves DIP;
;Manter o jumper J3 e J4 na posi��o A (1 e 2);
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
; *                               ENTRADAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE CHAVEA          PORTB, 0         ; ENTRADA PARA A CHAVE A
#DEFINE CHAVEB          PORTB, 1         ; ENTRADA PARA A CHAVE B
#DEFINE CHAVEC          PORTB, 2         ; ENTRADA PARA A CHAVE C
#DEFINE CHAVED          PORTB, 3         ; ENTRADA PARA A CHAVE D
 

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                SA�DAS                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE LED0			PORTD, 0	     ; SA�DA PARA LED 0
#DEFINE LED1            PORTD, 1         ; SA�DA PARA LED 1
#DEFINE LED2            PORTD, 2         ; SA�DA PARA LED 2
#DEFINE LED3            PORTD, 3         ; SA�DA PARA LED 3 
#DEFINE LED4            PORTD, 4         ; SA�DA PARA LED 4
#DEFINE LED5            PORTD, 5         ; SA�DA PARA LED 5
#DEFINE LED6            PORTD, 6         ; SA�DA PARA LED 6
#DEFINE LED7            PORTD, 7         ; SA�DA PARA LED 7

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	ORG	H'0000'                 ;ENDERE�O DE INICIO DO PROGRAMA
	goto	inicio

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               VETOR DE INTERRUP��O DO MICROCONTROLADOR                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	H'0004'                 ;ENDERE�O INICIAL DA INTERRUP��O.

Interrupcao:				;FUN��O PARA TRATAMENTO DA INTERRUP��O

	retfie
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURA��ES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina s�o inicializadas as portas de I/O do microcontrolador, os
; perif�ricos que ser�o usados e as configura��es dos registradores 
; especiais (SFR). 

inicio:
	BANK1					;ALTERA PARA O BANCO 1.
	movlw	B'00000000'
	movwf	TRISD			        ;TODAS AS PORTAS DE D S�O SAIDAS
	movlw	B'11111111'
	movwf   TRISB				; RB0 ATE RB3 � ENTRADA, AS DEMAIS S�O ENTRADA POR RECOMENDACAO
	movlw	B'11101111'
	movwf	TRISC;				; RC4 DEFINIDO COMO SAIDA, OS DEMAIS S�O ENTRADA POR RECOMENDACAO
	BANK0					;RETORNA PARA O BANCO 0.
	movlw	B'00000000'
	movwf	PORTD				; DEFININDO O VALOR INICIAL DA PORTA D
	bcf		PORTC, RC4		; DEFININDO O VALOR DE RC4, QUE � CONSTANTE
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZA��O DA RAM                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  LIMPA DE TODA A RAM DO BANC0 0, INDO DE 0X20 A 0X7F.
	movlw	0x20
	movwf	FSR				;APONTA O ENDERE�AMENTO INDIRETO PARA
							;A PRIMEIRA POSI��O DA RAM.
LIMPA_RAM
	clrf	INDF			;LIMPA A POSI��O ATUAL.
	incf	FSR,F			;INCREMENTA PONTEIRO P/ A PR�X. POS.
	movf	FSR,W
	xorlw	0x80			;COMPARA PONTEIRO COM A �LT. POS. +1.
	btfss	STATUS,Z		;J� LIMPOU TODAS AS POSI��ES?
	goto	LIMPA_RAM		;N�O, LIMPA A PR�XIMA POSI��O.
					;SIM, CONTINUA O PROGRAMA.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	                       	ROTINA PRINCIPAL                            *
; *	      				        		            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN:

	BTFSS	CHAVEA		; VERIFICA A CHAVE A, SE TA EM 1 PULA A PROX. LINHA
      	  GOTO	LIGA1		; VAI PARA A LIGA1, SE A CHAVE ESTIVER FECHADA 
	BSF	LED0		; DESLIGA LED0
	BSF	LED4		; DESLIGA LED4

MAIN2:
	BTFSS	CHAVEB		; VERIFICA A CHAVE B, SE TA EM 1 PULA A PROX. LINHA
	  GOTO	LIGA2		; VAI PARA A LIGA2, SE A CHAVE ESTIVER FECHADA
	BSF	LED1		; DESLIGA LED1
	BSF	LED5		; DESLIGA LED5

MAIN3:
	BTFSS	CHAVEC		; VERIFICA A CHAVE C, SE TA EM 1 PULA A PROX. LINHA
	  GOTO	LIGA3		; VAI PARA A LIGA3, SE A CHAVE ESTIVER FECHADA
	BSF	LED2		; DESLIGA LED2
	BSF	LED6		; DESLIGA LED6

MAIN4:
	BTFSS	CHAVED		; VERIFICA A CHAVE D, SE TA EM 1 PULA A PROX. LINHA
	  GOTO	LIGA4		; VAI PARA A LIGA4, SE A CHAVE ESTIVER FECHADA
	BSF	LED3		; DESLIGA LED3	
	BSF	LED7		; DESLIGA LED7

	GOTO MAIN		; LOOP PARA MAIN
;*******************************************************************************
LIGA1:
	BCF	LED0		; LIGA O LED0
	BCF	LED4		; LIGA O LED4
	GOTO MAIN2		
;*******************************************************************************
;*******************************************************************************
LIGA2
	BCF	LED1		; LIGA O LED1
	BCF	LED5		; LIGA O LED5
	GOTO MAIN3
;*******************************************************************************
;*******************************************************************************
LIGA3
	BCF	LED2		; LIGA O LED2
	BCF	LED6		; LIGA O LED6
	GOTO MAIN4
;*******************************************************************************
;*******************************************************************************
LIGA4
	BCF	LED3		;LIGA O LED3
	BCF	LED7		;LIGA O LED7
	GOTO MAIN
;*******************************************************************************


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; *                                                                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA