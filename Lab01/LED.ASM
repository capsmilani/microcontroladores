; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CÓDIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Lab01 - Chaves e LED's
; Aluno: Matheus Milani de Assunção
; Data:	31/03/2016
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRIÇÃO GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Chave A liga LEDs 0 e 4, B liga LEDs 1 e 5, C liga LEDs 2 e 6, D liga 
; LEDs 3 e 7.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURAÇÃO DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Habilitar o dip switch CH3 posição 6 (posição ON para cima);
;Habilitar o dip CH5,1-4 (posição ON para cima);
;Habilitar todos os dips de CH4 (posição ON para cima);
;Desabilitar as demais chaves DIP;
;Manter o jumper J3 e J4 na posição A (1 e 2);
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         CONFIGURAÇÕES PARA GRAVAÇÃO                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 __CONFIG _WDT_OFF & _XT_OSC & _LVP_OFF & _DEBUG_ON & _BODEN_OFF

;_CP_OFF 	==> MEMÓRIA DE PROGRAMA DESPROTEGIDA CONTRA LEITURA.
;_WRT_OFF 	==> SEM PERMISSÃO PARA ESCREVER NA MEMÓRIA DE PROGRAMA
;				DURANTE EXECUÇÃO DO PROGRAMA.
;_DEBUG_ON	==> DEBUG ATIVADO.
;_CPD_OFF 	==> MEMÓRIA EEPROM PROTEGIDA CONTRA LEITURA.
;_LVP_OFF 	==> PROGRAMAÇÃO EM BAIXA TENSÃO DESABILITADA.
;_WDT_OFF 	==> WDT DESATIVADO.
;_BODEN_OFF	==> BROWN-OUT DESATIVADO. 
;_PWRTE_ON 	==> POWER-ON RESET ATIVADO.
;_XT_OSC 	==> OSCILADOR CRISTAL (4MHz).

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ARQUIVOS DE DEFINIÇÕES                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P16F877.INC>		;ARQUIVO PADRÃO MICROCHIP PARA 16F877

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         DEFINIÇÃO DAS CONSTANTES                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                	        	MACROS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINIÇÃO DAS VARIÁVEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

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
; *                               ENTRADAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE CHAVEA          PORTB, 0         ; ENTRADA PARA A CHAVE A
#DEFINE CHAVEB          PORTB, 1         ; ENTRADA PARA A CHAVE B
#DEFINE CHAVEC          PORTB, 2         ; ENTRADA PARA A CHAVE C
#DEFINE CHAVED          PORTB, 3         ; ENTRADA PARA A CHAVE D
 

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                SAÍDAS                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE LED0			PORTD, 0	     ; SAÍDA PARA LED 0
#DEFINE LED1            PORTD, 1         ; SAÍDA PARA LED 1
#DEFINE LED2            PORTD, 2         ; SAÍDA PARA LED 2
#DEFINE LED3            PORTD, 3         ; SAÍDA PARA LED 3 
#DEFINE LED4            PORTD, 4         ; SAÍDA PARA LED 4
#DEFINE LED5            PORTD, 5         ; SAÍDA PARA LED 5
#DEFINE LED6            PORTD, 6         ; SAÍDA PARA LED 6
#DEFINE LED7            PORTD, 7         ; SAÍDA PARA LED 7

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	ORG	H'0000'                 ;ENDEREÇO DE INICIO DO PROGRAMA
	goto	inicio

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               VETOR DE INTERRUPÇÃO DO MICROCONTROLADOR                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	H'0004'                 ;ENDEREÇO INICIAL DA INTERRUPÇÃO.

Interrupcao:				;FUNÇÃO PARA TRATAMENTO DA INTERRUPÇÃO

	retfie
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURAÇÕES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina são inicializadas as portas de I/O do microcontrolador, os
; periféricos que serão usados e as configurações dos registradores 
; especiais (SFR). 

inicio:
	BANK1					;ALTERA PARA O BANCO 1.
	movlw	B'00000000'
	movwf	TRISD			        ;TODAS AS PORTAS DE D SÃO SAIDAS
	movlw	B'11111111'
	movwf   TRISB				; RB0 ATE RB3 É ENTRADA, AS DEMAIS SÃO ENTRADA POR RECOMENDACAO
	movlw	B'11101111'
	movwf	TRISC;				; RC4 DEFINIDO COMO SAIDA, OS DEMAIS SÃO ENTRADA POR RECOMENDACAO
	BANK0					;RETORNA PARA O BANCO 0.
	movlw	B'00000000'
	movwf	PORTD				; DEFININDO O VALOR INICIAL DA PORTA D
	bcf		PORTC, RC4		; DEFININDO O VALOR DE RC4, QUE É CONSTANTE
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZAÇÃO DA RAM                       *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  LIMPA DE TODA A RAM DO BANC0 0, INDO DE 0X20 A 0X7F.
	movlw	0x20
	movwf	FSR				;APONTA O ENDEREÇAMENTO INDIRETO PARA
							;A PRIMEIRA POSIÇÃO DA RAM.
LIMPA_RAM
	clrf	INDF			;LIMPA A POSIÇÃO ATUAL.
	incf	FSR,F			;INCREMENTA PONTEIRO P/ A PRÓX. POS.
	movf	FSR,W
	xorlw	0x80			;COMPARA PONTEIRO COM A ÚLT. POS. +1.
	btfss	STATUS,Z		;JÁ LIMPOU TODAS AS POSIÇÕES?
	goto	LIMPA_RAM		;NÃO, LIMPA A PRÓXIMA POSIÇÃO.
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