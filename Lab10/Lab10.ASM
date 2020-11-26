; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CÓDIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: PWM 1
; Aluno: Matheus Milani de Assunção	
; Data:	17/06/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRIÇÃO GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Utilize a saída PWM1 (RC2), para controlar a intensidade
; luminosa da lâmpada;
; Utilize as teclas 0 a 3 para controlar a intensidade, com:
; 0: 0%;
; 1: 33%
; 2: 66%
; 3: 100%

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURAÇÃO DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Configurar as chaves e jumpers:
; Habilitar a chave CH2,2 (posição ON para cima)
; Habilitar a chave CH3,1 (posição ON para cima)
; Habilitar as chaves CH5,1 a CH5,4 (posição ON para cima)
; Desabilitar as demais chaves DIP
; Manter o jumper J1 e J2 na posição B
; Manter o jumper J3 e J4 na posição A

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

	CBLOCK	0X20				; POSIÇÃO INICIAL DA RAM
								; PRESSIONADA
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

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO.

Interrupcao:			;FUNÇÃO PARA TRATAMENTO DA INTERRUPÇÃO

	retfie
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURAÇÕES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina são inicializadas as portas de I/O do microcontrolador, os
; periféricos que serão usados e as configurações dos registradores 
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

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	                       	ROTINA PRINCIPAL                                *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN								; UTILIZANDO APENAS 8BITS DO PWM

	BTFSC	PORTB, 0				; TESTA SE O PRIMEIRO BOTÃO FOI CLICADO
		GOTO	$ + 5				
	MOVLW	B'00000000'				;
	MOVWF	CCPR1L					; DESLIGA A LAMPADA	
	BCF		CCP1CON, 4				;
	BCF		CCP1CON, 5				;
	
	BTFSC	PORTB, 1				; TESTA SE O SEGUNDO BOTÃO FOI CLICADO
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