; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   C�DIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Display LCD
; Aluno: Matheus Milani de Assun��o	
; Data:	12/05/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRI��O GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Utilize a interrup��o do Timer 0 como refer�ncia para temporizar 1 segundo.
; Escreva o tempo no display LCD:
; Linha 1: seus nomes, centralizado;
; Linha 2: 00:00:00 (HH:MM:SS);
; Ao pressionar a tecla 1 deve iniciar a contagem do cron�metro,
; atualizando o display a cada segundo.
; Ao pressionar a tecla 2, a contagem deve ser parada.
; Com a tecla 3 a contagem � zerada, voltando o display para 00:00:00.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURA��O DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Habilitar o dip switch CH3,1-4 (posi��o ON para cima);
; Habilitar todos os dips de CH4 (posi��o ON para cima);
; Habilitar o dip CH5,1-4 (posi��o ON para cima);
; Desabilitar as demais chaves DIP;
; Manter o jumper J3 na posi��o A e J4 na posi��o B;
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

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                	        	MACROS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINI��O DAS VARI�VEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CBLOCK	0X20			; POSI��O INICIAL DA RAM
		TEMPO_1				; VARIAVEL PARA DELAY
		UAU					; VARIAVEL PARA DELAY
		SEG_UNI				; VARIAVEL PARA UNIDADE DE SEGUNDO
		SEG_DEZ				; VARIAVEL PARA DEZENA DE SEGUNDO
		MIN_UNI				; VARIAVEL PARA UNIDADE DE MINUTO
		MIN_DEZ				; VARIAVEL PARA DEZENA DE MINUTO
		HRS_UNI
		HRS_DEZ
		SAVE_W				; VARIAVEL PARA GUARDAR O VALOR DE W NA INTERUP��O
		SAVE_STATUS			; VARIAVEL PARA GUARDAR O VALOR DE STATUS NA INTERRUP��O
		VAR					; VARIAVEL RESPONSAVEL PARA AJUDAR NA CONTAGEM DE TMR0
		FLAG				; VARIAVEL RESPONSAVEL PELA MAQUINA DE FLAGS
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

#DEFINE		E			PORTE, 1
#DEFINE		RS			PORTE, 0	


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

	ORG	0x04			; ENDERE�O INICIAL DA INTERRUP��O.
Interrupcao:			; FUN��O PARA TRATAMENTO DA INTERRUP��O

	MOVWF	SAVE_W			; GUARDA O VALOR DE W
	SWAPF	STATUS,W		; INVERTE OS NIBBLES PARA N�O TER RISCO DE ALTERA-LOS
	MOVWF	SAVE_STATUS		; GUARDA O STATUS

	BTFSS	INTCON, 2		; VERIFICA SE A INTERRUP��O FOI POR CAUSA DO TMR0
		GOTO	COME		; SE N�O FOI VAI PARA O FIM
	BCF		INTCON, 2		; SE N�O FOI LIMPA O FLAG DE OPTION_REG
	MOVLW	.6				; ATRIBUI VALOR 6 PARA O TIMER 0
	MOVWF	TMR0			; TIMER 0 VAI DE 6 AT� 256
	DECFSZ	VAR				; DECREMENTA VAR AT� CHEGAR A 0
		GOTO	COME		;  FAZ TMR0 250 VEZES QUE � O TAMANHO DE VAR
	MOVLW	D'250'			; RENOVA O VALOR DA VARIAVEL VAR
	MOVWF	VAR	
	BTFSC	FLAG, 6			; VERIFICA SE A FLAG DE PARAR O CONTADOR EST� 1	
		INCF	SEG_UNI, F	; SE N�O ESTIVER, INCREMENTA O VALOR DE UNIDADES DE SEGUNDOS
COME:

	SWAPF	 SAVE_STATUS,W
	MOVWF	 STATUS 	; RECUPERA STATUS
	SWAPF	 SAVE_W,F
	SWAPF	 SAVE_W,W 		

RETFIE
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURA��ES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina s�o inicializadas as portas de I/O do microcontrolador, os
; perif�ricos que ser�o usados e as configura��es dos registradores 
; especiais (SFR). 

Inicio:

BANK1						; ALTERA PARA O BANCO 1.
	MOVLW	B'10100000'		;;
	MOVWF	INTCON			;;
	MOVLW	B'00000101'		;; VALORES PARA FUNCIONAR O CONTADOR TMR0
	MOVWF	OPTION_REG		;;
	MOVLW	B'00000111'		;;
	MOVWF	ADCON1			;;
	MOVLW	B'11111111'		; PORTAS UTILIZADAS COMO ENTRADA 0, 1 E 2
	MOVWF	TRISB
	MOVLW	B'11111110'		; PORTA UTILIZADA COMO SAIDA PORTA 0
	MOVWF	TRISC
	MOVLW	B'00000000'		; TODAS AS PORTAS D S�O SAIDAS
	MOVWF	TRISD
	MOVLW	B'00000000'		; PORTAS UTILIZADAS COMO SAIDA 0, 1 
	MOVWF	TRISE
BANK0						; RETORNA PARA O BANCO 0.
	MOVLW	B'11111110'		; LINHA 0 � A UNICA LIGADA 
	MOVWF	PORTC			
	MOVLW	B'11111111'		; VALORES DOS LED'S S�O TODOS '1', APAGADO
	MOVWF	PORTD			


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
; *	                       	INICIALIZA��O DO LCD                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	
INICIALIZA_LCD:
	BCF		RS
	MOVLW	H'38'
	CALL 	ESCREVE
	MOVLW	D'12'
	CALL 	DELAY_MS
	MOVLW	H'38' 		; ESCREVE COMANDO 0X38 PARA INICIALIZA��O
	CALL	ESCREVE		 	
	MOVLW	D'12'
	CALL	DELAY_MS
	MOVLW	H'6' 		; ESCREVE COMANDO 0X38 PARA INICIALIZA��O
	CALL	ESCREVE
	MOVLW	D'12'
	CALL	DELAY_MS 		 
	MOVLW	H'0C'		; ESCREVE COMANDO PARA
	CALL	ESCREVE		; INTERFACE DE 8 VIAS DE DADOS
	MOVLW	D'12'
	CALL	DELAY_MS
	MOVLW	H'01' 		; ESCREVE COMANDO PARA
	CALL	ESCREVE 	; LIMPAR TODO O DISPLAY
	MOVLW	D'12'
	CALL	DELAY_MS 		
	BSF		RS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZA��O DAS VARIAVEIS                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	B'01110001'			; MAQUINA DE FLAGS, SEMPRE ENTRA NA FLAG0 QUANDO INICIALIZADA 
	MOVWF	FLAG
	MOVLW	D'250'				; VARxTMR0x64 = 4000000
	MOVWF	VAR
	GOTO	MAIN



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

DELAY_MS:
	movwf	UAU		;recebe W determinado antes desta funcao ser chamada
	movlw	.250			
	movwf	TEMPO_1		;move 250 para a variavel TEMPO_ms
	
	
DELAY_1:
	nop					
	decfsz	TEMPO_1		;Decrementa a variavel para contar 1ms
		goto	DELAY_1			;Se nao for zero volta para o inicio da funcao 
	
	decfsz	UAU		;Decrementa a variavel para multiplicar o 1ms
		goto	DELAY_1	
	
	return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ESCREVE:
	BSF		E	 			;ENVIA UM PULSO DE ENABLE AO DISPLAY
	MOVWF	PORTD
	BCF 	E 
	MOVLW	D'250'
	MOVWF	UAU
	NOP
	DECFSZ	UAU, F
		GOTO	$ - 2 	
			
RETURN 					; RETORNA
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

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
	
	BTFSC	FLAG, 5
		CALL	ATUALIZA_DISP		

GOTO MAIN


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
LE_TECLADO
	BTFSC	PORTB, 0		; TESTAR SE A PORTA DE COME�AR FOI PRESSIONADA
		GOTO	$ + 4		; SE N�O VAI PARA A PROXIMA PORTA
		NOP
;		CALL DELAY			; CHAMA O DELAY PARA EVITAR O DEBOUNCE
		BTFSS	PORTB, 0	; TESTANDO DE NOVO APOS O TEMPO DO DELAY
			BSF	FLAG, 1		; SE FOI PRESSIONADA ENTRA NO ESTADO DE INICIAR O CRONOMETRO
	
	BTFSC	PORTB, 1		; TESTAR SE A PORTA DE COME�AR FOI PRESSIONADA
		GOTO	$ + 4		; SE N�O VAI PARA A PROXIMA PORTA
;		CALL DELAY			; CHAMA O DELAY PARA EVITAR O DEBOUNCE
		NOP
		BTFSS	PORTB, 1	; TESTANDO DE NOVO APOS O TEMPO DO DELAY
			BSF	FLAG, 2		; SE FOI PRESSIONADA ENTRA NO ESTADO DE RESETAR O CRONOMETRO

	BTFSC	PORTB, 2		; TESTAR SE A PORTA DE COME�AR FOI PRESSIONADA
		GOTO	$ + 4		; SE N�O VAI PARA A PROXIMA PORTA
;		CALL DELAY			; CHAMA O DELAY PARA EVITAR O DEBOUNCE
		NOP
		BTFSS	PORTB, 2	; TESTANDO DE NOVO APOS O TEMPO DO DELAY
			BSF	FLAG, 3		; SE FOI PRESSIONADA ENTRA NO ESTADO DE PARAR O CRONOMETRO
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
START_CRON
	BSF	FLAG, 4
	BCF	FLAG, 1
	BSF	FLAG, 6
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
RESET_CRON					; SE FOR PRESSIONADO O BOT�O DE RESET 
	CLRF	SEG_UNI			; LIMPA TODAS AS VARIAVEIS 
	CLRF	SEG_DEZ			; DE SEGUNDOS E MINUTOS
	CLRF	MIN_UNI
	CLRF	MIN_DEZ
	CLRF	HRS_UNI
	CLRF	HRS_DEZ
	BCF		FLAG, 2
	BSF		FLAG, 3
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
STOP_CRON					; SE FOR PRESSIONADO O BOT�O DE PARAR
	BCF	FLAG, 4				; N�O ENTRA NO LA�O DE ATUALIZAR O CRONOMETRO
	BCF	FLAG, 6
	BCF	FLAG, 3 
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ATUALIZA_CRON:
	MOVF	SEG_UNI, W
	XORLW	D'10'			; VERIFICA SE UNIDADES DE SGUNDOS � IGUAL A 10 
	BTFSS	STATUS, Z		; A "RESPOSTA" FICA ARMAZENADA EM STATUS, AI TESTAMOS 
		GOTO	AQUI		; SE N�O FOR 10 VAI PARA O FINAL 
	INCF	SEG_DEZ, F		; SEN�O INCREMENTA A DEZENA DE SEGUNDOS 
	CLRF	SEG_UNI			; E ZERA A UNIDADES

	MOVF	SEG_DEZ, W
	XORLW	D'6'
	BTFSS	STATUS, Z
		GOTO	AQUI
	INCF	MIN_UNI, F
	CLRF	SEG_DEZ

	MOVF	MIN_UNI, W
	XORLW	D'10'
	BTFSS	STATUS, Z
		GOTO	AQUI
	INCF	MIN_DEZ, F
	CLRF	MIN_UNI
	
	MOVF	MIN_DEZ, W
	XORLW	D'6'
	BTFSS	STATUS, Z
		GOTO	AQUI
	INCF	HRS_UNI, F
	CLRF	MIN_DEZ

	MOVF	HRS_UNI, W
	XORLW	D'10'
	BTFSS	STATUS, Z
		GOTO	AQUI
	INCF	HRS_DEZ, F
	CLRF	HRS_UNI	

AQUI:
	BSF	FLAG, 5				; TODA VEZ QUE O CRONOMETRO FOR ATUALIZADO O DISPLAY TAMBEM SER� 
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ATUALIZA_DISP
	BCF		RS	; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW 	H'85' 		; COMANDO PARA POSICIONAR O CURSOR
	CALL 	ESCREVE 		; LINHA 0 / COLUNA 0
	BSF 	RS 		; SELECIONA O DISPLAY P/ DADOS

	MOVLW	'M'
	CALL	ESCREVE
	MOVLW	'a'
	CALL	ESCREVE
	MOVLW	't'
	CALL	ESCREVE
	MOVLW	'h'
	CALL	ESCREVE
	MOVLW	'e'
	CALL	ESCREVE
	MOVLW	'u'
	CALL	ESCREVE
	MOVLW	's'
	CALL	ESCREVE


	BCF 	RS 		; SELECIONA O DISPLAY P/ COMANDO
	MOVLW 	H'C0'		; COMANDO PARA POSICIONAR O CURSOR
	CALL 	ESCREVE 		; LINHA 2 / COLUNA 0
	BSF 	RS 

	MOVF	HRS_DEZ, W
	ADDLW	D'48'
	CALL 	ESCREVE
	
	MOVF	HRS_UNI, W
	ADDLW	D'48'
	CALL 	ESCREVE

	MOVLW	'.'
	CALL	ESCREVE

	MOVF	MIN_DEZ, W
	ADDLW	D'48'
	CALL 	ESCREVE

	MOVF	MIN_UNI, W
	ADDLW	D'48'
	CALL 	ESCREVE	

	MOVLW	'.'
	CALL	ESCREVE

	MOVF	SEG_DEZ, W
	ADDLW	D'48'
	CALL 	ESCREVE

	MOVF	SEG_UNI, W
	ADDLW	D'48'
	CALL 	ESCREVE
	
	;BCF		FLAG, 5
	;BCF		FLAG, 4
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA