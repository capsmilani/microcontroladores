; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   C�DIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: RS-232
; Aluno: Matheus Milani de Assun��o	
; Data:	30/06/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRI��O GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Configure a USART para comunica��o RS-232, com 19200 bps, 8 bits, sem paridade;
; Pode utilizar interrup��o ou flag;
; Utilize um terminal no computador para enviar ao kit, via RS-232, 
; as teclas alfanum�ricas pressionadas;
; O kit deve devolver a letra ou n�mero seguinte ao pressionado;

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURA��O DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Habilitar a chave CH2,6 e 7 (posi��o ON para cima)
; Desabilitar as demais chaves DIP.

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
		RECEBIDO				; VARIAVEL UTILIZADA COMO BUFFER  
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
BANK1					
	MOVLW	B'01000000'			; HABILITANDO INTERRUP��ES EXTERNAS
	MOVWF	INTCON
	MOVLW	B'00110000'			; HABILITANDO AS FLAGS DE Tx E Rx
	MOVWF	PIE1
	MOVLW	B'11000000'			; NECESSARIO SER HABILITADO 
	MOVWF	TRISC
	MOVLW	B'00000111'
	MOVWF	OPTION_REG
	MOVLW	B'00100110'			; LIGANDO A TRANSMISS�O DE DADOS/ EM ALTA VELOCIDADE/ SEM BIT DE PARIDADE
	MOVWF	TXSTA					
	MOVLW	B'00110011'			; VALOR OBTIDO DO CALCULO OBTIDO NO DATASHEET
	MOVWF	SPBRG					
BANK0					; RETORNA PARA O BANCO 0.
	MOVLW	B'00000000'
	MOVWF	PIR1
	MOVLW	B'10011000'			; PORTA SERIAL ATIVADA/RECEBIMENTO CONTINUO
	MOVWF	RCSTA					

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

MAIN
	BTFSS	PIR1, 5				; TESTA SE FOI MANDADO ALGUMA COISA
		GOTO	$ - 1
	MOVF	RCREG, W 			; REGISTRADOR QUE RECEBE DADOS
	MOVWF	RECEBIDO			
	INCF	RECEBIDO, W			; INCREMENTA O DADO OBTIDO
	MOVWF	TXREG				; REGISTRADOR QUE TRANSMITE OS DADOS
	BANK1
	BSF		TXSTA, TXEN			; LIGA A TRANSMISS�O
	TRANSMITINDO:
		BTFSS	TXSTA, TRMT		; FICA AT� TERMINAR DE TRANSMITIR OS DADOS
			GOTO	TRANSMITINDO
		BCF	TXSTA, TXEN			; DESLIGA A TRANSMISS�O
	BANK0
GOTO	MAIN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; *                                                                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA