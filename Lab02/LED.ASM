; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   C�DIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Teclado e LED's
; Aluno: Matheus Milani de Assun��o	
; Data:	01/04/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRI��O GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Ao pressionar as teclas de 1 a 8, os LEDs correspondentes (1
; a 8) s�o ligados. Ap�s soltar a tecla, continua ligado. Somente
; ao pressionar novamente s�o desligados.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURA��O DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Habilitar o dip switch CH3,1-4 (posi��o ON para cima);
; Habilitar o dip CH5,1-4 (posi��o ON para cima);
; Habilitar todos os dips de CH4 (posi��o ON para cima);
; Desabilitar as demais chaves DIP;
; Manter o jumper J3 e J4 na posi��o A (1 e 2);
; L1 � RC0; L2 � RC1; C1 � RB0; C2 � RB1...

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
T1	EQU		.250
VEZES	EQU	D'30'
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                	        	MACROS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINI��O DAS VARI�VEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CBLOCK	0X20			; POSI��O INICIAL DA RAM
		UAU					; VARI�VEL PARA CONTAR APROX. 1 ms
		TEMPO_XMS			; PER�ODO PARA COMANDO DO LED
;		FLAG				; AUXILIAR PARA DETECTAR SE BOT�O EST� LIGADO
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
#DEFINE FLAG0 FLAG, 0			; DEFININDO AS FLAGS
#DEFINE FLAG1 FLAG, 1
#DEFINE FLAG2 FLAG, 2
#DEFINE FLAG3 FLAG, 3
#DEFINE FLAG4 FLAG, 4
#DEFINE FLAG5 FLAG, 5
#DEFINE FLAG6 FLAG, 6
#DEFINE FLAG7 FLAG, 7

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                               ENTRADAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE COL0	PORTB, 0
#DEFINE COL1	PORTB, 1
#DEFINE COL2	PORTB, 2
#DEFINE COL3	PORTB, 3

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                SA�DAS                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE LED0	PORTD, 0
#DEFINE LED1	PORTD, 1
#DEFINE LED2	PORTD, 2
#DEFINE LED3	PORTD, 3
#DEFINE LED4	PORTD, 4
#DEFINE LED5	PORTD, 5
#DEFINE LED6	PORTD, 6
#DEFINE LED7	PORTD, 7
#DEFINE LIN0	PORTC, 0
#DEFINE LIN1	PORTC, 1

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
	movlw	B'11111100'		; DEFINE AS PORTAS 0 A 1 COMO SAIDA, AS DEMAIS S�O INPUT POR RECOMENDA��O
	movwf	TRISC
	movlw	B'11111111'		; DEFINE AS PORTAS 0 A 3 COMO ENTRADA, AS DEMAIS S�O INPUT POR RECOMENDA��O
	movwf	TRISB
	movlw	B'00000000'		; DEFINE AS PORTAS 0 A 7 COMO SAIDA
	movwf	TRISD
	BANK0					; RETORNA PARA O BANCO 0.
	movlw	H'FF'
	movwf	PORTD			; ALTA TODAS AS SA�DAS
	movlw	B'00000010'		
	movwf	PORTC			; ALTERNADA NAS SAIDAS DE C
	movlw	H'00'
	movwf	FLAG			; DEFININDO ALTO PARA TODA A FLAG
	
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
	movlw	T1				; INCICIALIZA TODO INICIO DE CODIGO AS VARIAVEIS 
	movwf	TEMPO_XMS		; TEMPO_XMS E A VARIAVEL UAU
	movlw	VEZES
	movwf	UAU	
							; ALTERNA OS VALORES DE LINHA
	BTFSC LIN0				
		GOTO $ + 3			; SE LIN0 FOR 1, PULA PRA DEIXA-LO 0
	BSF LIN0
		GOTO $ + 2	
	BCF LIN0
	BTFSC LIN1				; SE LIN1 FOR 1, PULA PRA DEIXA-LO 0
		GOTO $ + 3
	BSF LIN1
		GOTO $ + 2
	BCF LIN1		

						; VERIFICA SE ALGUM BOT�O FOI APERTADO
	BTFSS LIN0
		GOTO VERIFICA_LINHA0; VERIFICANDO A PRIMEIRA LINHA
LINHA1:
	BTFSS LIN1
		GOTO VERIFICA_LINHA1; VERIFICANDO A SEGUNDA LINHA

	GOTO MAIN

;*****************************************************************************
VERIFICA_LINHA0:

	BTFSC COL0				; SE ALGUMA COLUNA TIVER NIVEL BAIXO ENTRA NA CONDI��O
		GOTO LAB0
		CALL ENROLA�AO		; CHAMA A FUN��O DE DELAY
		CALL LIGA_0			; CHAMA A FUN��O DE LIGAR O LED
			GOTO $ + 2
		LAB0:
		BCF FLAG0			; SE O BOTAO N�O EST� MAIS APERTADO, DEFINE 0 PARA A FLAG
	BTFSC COL1	
		GOTO LAB1
		CALL ENROLA�AO
		CALL LIGA_1
			GOTO $ + 2
		LAB1:
		BCF FLAG1
	BTFSC COL2
		GOTO LAB2
		CALL ENROLA�AO
		CALL LIGA_2
			GOTO $ + 2
		LAB2:
		BCF FLAG2
	BTFSC COL3
		GOTO LAB3
		CALL ENROLA�AO
		CALL LIGA_3
			GOTO $ + 2
		LAB3:
		BCF FLAG3
	GOTO LINHA1
;*****************************************************************************


;*****************************************************************************
VERIFICA_LINHA1:

	BTFSC COL0				; SE ALGUMA COLUNA TIVER NIVEL BAIXO ENTRA NA CONDI��O
		GOTO LAB4
		CALL ENROLA�AO
		CALL LIGA_4
			GOTO $ + 2
		LAB4:
		BCF FLAG4
	BTFSC COL1	
		GOTO LAB5
		CALL ENROLA�AO
		CALL LIGA_5
			GOTO $ + 2
		LAB5:
		BCF FLAG5
	BTFSC COL2
		GOTO LAB6
		CALL ENROLA�AO
		CALL LIGA_6
			GOTO $ + 2
		LAB6:
		BCF FLAG6
	BTFSC COL3
		GOTO LAB7
		CALL ENROLA�AO
		CALL LIGA_7
			GOTO $ + 2
		LAB7:
		BCF FLAG7
	GOTO MAIN
;*****************************************************************************

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	             		  ROTINAS DE LIGAR LED's 			   	            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_0
	BTFSC FLAG0			; VERIFICA SE O BOT�O J� EST� APERTADO
		GOTO $ + 7
	BTFSS LED0			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL0	
	BCF LED0			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL0:	
	BSF LED0			; DESLIGA O LED
	BSF FLAG0			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_1
	BTFSC FLAG1
		GOTO $ + 7
	BTFSS LED1			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL1	
	BCF LED1			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL1:	
	BSF LED1			; DESLIGA O LED
	BSF FLAG1			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_2
	BTFSC FLAG2
		GOTO $ + 7
	BTFSS LED2			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL2	
	BCF LED2			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL2:	
	BSF LED2			; DESLIGA O LED
	BSF FLAG2			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_3
	BTFSC FLAG3
		GOTO $ + 7
	BTFSS LED3			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL3	
	BCF LED3			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL3:	
	BSF LED3			; DESLIGA O LED
	BSF FLAG3			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_4
	BTFSC FLAG4
		GOTO $ + 7
	BTFSS LED4			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL4	
	BCF LED4			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL4:	
	BSF LED4			; DESLIGA O LED
	BSF FLAG4			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_5
	BTFSC FLAG5
		GOTO $ + 7
	BTFSS LED5			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL5	
	BCF LED5			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL5:	
	BSF LED5			; DESLIGA O LED
	BSF FLAG5			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_6
	BTFSC FLAG6
		GOTO $ + 7
	BTFSS LED6			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL6	
	BCF LED6			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL6:	
	BSF LED6			; DESLIGA O LED
	BSF FLAG6			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
LIGA_7
	BTFSC FLAG7
		GOTO $ + 7
	BTFSS LED7			; VERIFICA SE O LED TA LIGADO/DESLIGADO 
		GOTO LABEL7	
	BCF LED7			; LIGA O LED
		GOTO $ + 2			; PULA PARA O RETORNO
	LABEL7:	
	BSF LED7			; DESLIGA O LED
	BSF FLAG7			; MUDA O VALOR DE FLAG
RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	               ROTINA DE DELAY (DE 1ms AT� 255ms)       	            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
ENROLA�AO						; FUN��O DELAY
	movlw	T1					; MOVE A CONST. DE TEMPO "250" PARA WORK
	movwf	TEMPO_XMS			; MOVE O CONTEUDO DE WORK PARA A VARIAVEL TEMPO_XMS
AUX
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
	DECFSZ	TEMPO_XMS,F			; DIMINUI TEMPO_XMS AT� QUE SEJA 0
		GOTO	AUX
	DECFSZ	UAU,F				; DECREMENTA UAU AT� QUE SEJA 0
		GOTO	ENROLA�AO
	MOVLW	VEZES
	MOVWF	UAU
	RETURN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; *                                                                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA