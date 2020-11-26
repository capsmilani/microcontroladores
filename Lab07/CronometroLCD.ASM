; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CÓDIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Display LCD
; Aluno: Matheus Milani de Assunção	
; Data:	19/05/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRIÇÃO GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Utilize a interrupção do Timer 0 e do Timer 1 para gerar as temporizações
; para teclado, display e cronômetro (1 segundo).
; Escreva o tempo no display LCD:
; Linha 1: seus nomes, centralizado;
; Linha 2: 00:00:00 (HH:MM:SS);
; Ao pressionar a tecla 1 deve iniciar a contagem do cronômetro, atualizando o
; display a cada segundo.
; Ao pressionar a tecla 2, a contagem deve ser parada.
; Com a tecla 3 a contagem é zerada, voltando o display para 00:00:00.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      CONFIGURAÇÃO DOS JUMPERS DE PLACA                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Habilitar o dip switch CH3,1-4 (posição ON para cima);
; Habilitar todos os dips de CH4 (posição ON para cima);
; Habilitar o dip CH5,1-4 (posição ON para cima);
; Habilitar o dip CH6,1-2;
; Desabilitar as demais chaves DIP;
; Manter o jumper J3 na posição A e J4 na posição B;
; L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...

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

	CBLOCK	0X20			; POSIÇÃO INICIAL DA RAM
		TEMPO_1				; VARIAVEL PARA DELAY
		UAU					; VARIAVEL PARA DELAY
		SEG_UNI				; VARIAVEL PARA UNIDADE DE SEGUNDO
		SEG_DEZ				; VARIAVEL PARA DEZENA DE SEGUNDO
		MIN_UNI				; VARIAVEL PARA UNIDADE DE MINUTO
		MIN_DEZ				; VARIAVEL PARA DEZENA DE MINUTO
		HRS_UNI
		HRS_DEZ
		SAVE_W				; VARIAVEL PARA GUARDAR O VALOR DE W NA INTERUPÇÃO
		SAVE_STATUS			; VARIAVEL PARA GUARDAR O VALOR DE STATUS NA INTERRUPÇÃO
		VAR					; VARIAVEL RESPONSAVEL PARA AJUDAR NA CONTAGEM DE TMR0
		FLAG				; VARIAVEL RESPONSAVEL PELA MAQUINA DE FLAGS
		VARTMR1
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

#DEFINE		E			PORTE, 1
#DEFINE		RS			PORTE, 0	


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

	BTFSS	INTCON, 2		; VERIFICA SE A INTERRUPÇÃO FOI POR CAUSA DO TMR0
		GOTO	JAJAJA		; SE NÃO FOI VAI PARA O FIM
	BCF		INTCON, 2		; SE NÃO FOI LIMPA O FLAG DE OPTION_REG
	MOVLW	.6				; ATRIBUI VALOR 6 PARA O TIMER 0
	MOVWF	TMR0			; TIMER 0 VAI DE 6 ATÉ 256
	DECFSZ	VAR				; DECREMENTA VAR ATÉ CHEGAR A 0
		GOTO	COME		;  FAZ TMR0 250 VEZES QUE É O TAMANHO DE VAR
	MOVLW	D'250'			; RENOVA O VALOR DA VARIAVEL VAR
	MOVWF	VAR	
	BTFSC	FLAG, 6			; VERIFICA SE A FLAG DE PARAR O CONTADOR ESTÁ 1	
		INCF	SEG_UNI, F	; SE NÃO ESTIVER, INCREMENTA O VALOR DE UNIDADES DE SEGUNDOS

JAJAJA:
	BTFSS	PIR1, 0			; VERIFICA SE A INTERRUPÇÃO É PELO TMR1
		GOTO	COME
	BCF		PIR1, 0			; LIMPA A FLAG DO TIMER 1
	CLRF	T1CON			; DESLIGA O TIMER 1
	MOVLW	D'0'			; MOVE 0 PARA TMR1L PARA QUE NÃO INCREMENTE TMR1H
	MOVWF	TMR1L
	MOVLW	H'FF'			; ATRIBUI VALOR FF PARA OBTER VALOR DESEJADO
	MOVWF	TMR1H
	MOVLW	D'96'			; ATRIBUI VALOR 96 PARA QUE CONTE ATÉ 256 E ENTRE NA INTERRUPÇÃO
	MOVWF	TMR1L
	BSF		FLAG, 5			; VAI PARA O PROXIMO ESTADO DA MAQUINA DE FLAGS
	INCF	VARTMR1, F		; VARIA QUAL ESTADO PARA ESCREVER UM CARACTER
	MOVF	VARTMR1, W		
	XORLW	D'9'			; VERIFICA SE O ESTADO É INVALIDO
	BTFSS	STATUS, Z
		GOTO	COME
	CLRF	VARTMR1		

COME:

	SWAPF	 SAVE_STATUS,W
	MOVWF	 STATUS 	; RECUPERA STATUS
	SWAPF	 SAVE_W,F
	SWAPF	 SAVE_W,W 		

RETFIE
	
	
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *              CONFIGURAÇÕES INICIAIS DE HARDWARE E SOFTWARE              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Nesta rotina são inicializadas as portas de I/O do microcontrolador, os
; periféricos que serão usados e as configurações dos registradores 
; especiais (SFR). 

Inicio:

BANK1						; ALTERA PARA O BANCO 1.
	MOVLW	B'00000001'		; HABILITA O OVERFLOW DA INTERRUPÇÃO DO TIMER 1 
	MOVWF	PIE1			;
	MOVLW	B'11100000'		;;
	MOVWF	INTCON			;;
	MOVLW	B'00000101'		;; VALORES PARA FUNCIONAR O CONTADOR TMR0
	MOVWF	OPTION_REG		;;
	MOVLW	B'00000111'		;;
	MOVWF	ADCON1			;;
	MOVLW	B'11111111'		; PORTAS UTILIZADAS COMO ENTRADA 0, 1 E 2
	MOVWF	TRISB
	MOVLW	B'11111110'		; PORTA UTILIZADA COMO SAIDA PORTA 0
	MOVWF	TRISC
	MOVLW	B'00000000'		; TODAS AS PORTAS D SÃO SAIDAS
	MOVWF	TRISD
	MOVLW	B'00000000'		; PORTAS UTILIZADAS COMO SAIDA 0, 1 
	MOVWF	TRISE
BANK0						; RETORNA PARA O BANCO 0.
	MOVLW	B'00000001'		; REGISTRADOR PARA A FLAG DO TMR1
	MOVWF	PIR1
	MOVLW	B'00000000'		; REGISTRADOR PARA CONFIGURAÇÃO DO TMR1 
	MOVWF	T1CON
	MOVLW	B'11111110'		; LINHA 0 É A UNICA LIGADA 
	MOVWF	PORTC			
	MOVLW	B'11111111'		; VALORES DOS LED'S SÃO TODOS '1', APAGADO
	MOVWF	PORTD			


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
; *	                       	INICIALIZAÇÃO DO LCD                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	
INICIALIZA_LCD:
	BCF		RS
	MOVLW	H'38'
	CALL 	ESCREVE
	MOVLW	D'40'
	CALL 	DELAY_MS
	MOVLW	H'38' 		; ESCREVE COMANDO 0X38 PARA INICIALIZAÇÃO
	CALL	ESCREVE		 	
	MOVLW	D'40'
	CALL	DELAY_MS
	MOVLW	H'6' 		; ESCREVE COMANDO 0X38 PARA INICIALIZAÇÃO
	CALL	ESCREVE
	MOVLW	D'40'
	CALL	DELAY_MS 		 
	MOVLW	H'0C'		; ESCREVE COMANDO PARA
	CALL	ESCREVE		; INTERFACE DE 8 VIAS DE DADOS
	MOVLW	D'40'
	CALL	DELAY_MS
	MOVLW	H'01' 		; ESCREVE COMANDO PARA
	CALL	ESCREVE 	; LIMPAR TODO O DISPLAY
	MOVLW	D'40'
	CALL	DELAY_MS 		
	BSF		RS
						;INICIALIZANDO O NOME
	BCF		RS	; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW 	H'80' 		; COMANDO PARA POSICIONAR O CURSOR
	CALL 	ESCREVE 		; LINHA 0 / COLUNA 0
	MOVLW	D'1'
	CALL	DELAY_MS
	BSF 	RS 		; SELECIONA O DISPLAY P/ DADOS

	MOVLW	'R'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'o'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'd'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'r'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'i'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'g'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'o'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'M'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'a'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	't'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'h'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'e'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	'u'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS
	MOVLW	's'
	CALL	ESCREVE
	MOVLW	D'1'
	CALL	DELAY_MS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      INICIALIZAÇÃO DAS VARIAVEIS                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	B'01110001'			; MAQUINA DE FLAGS, SEMPRE ENTRA NA FLAG0 QUANDO INICIALIZADA 
	MOVWF	FLAG
	MOVLW	D'250'				; VARxTMR0x64 = 4000000
	MOVWF	VAR
	CLRF	VARTMR1
	GOTO	MAIN



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

DELAY_MS:
	MOVWF	UAU		; RECEBE W DETERMINADO ANTES DESTA FUNÇÃO
	MOVLW	.250			
	MOVWF	TEMPO_1		; MOVE 250 PARA A VARIAVEL TEMPO_1
	
	
DELAY_1:
	NOP					
	DECFSZ	TEMPO_1		; DECREMENTA A VARIACEL PARA CONTAR 1MS
		GOTO	DELAY_1			; SE NÃO FOR ZEROS VOLTA PARA O INICIO DA FUNCAO 
	
	DECFSZ	UAU		; DECREMENTA A VARIAVEL PARA MULTIPLICAR O 1MS
		GOTO	DELAY_1	
	
RETURN

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ESCREVE:
	BSF		E	 			;ENVIA UM PULSO DE ENABLE AO DISPLAY
	MOVWF	PORTD
	BCF 	E 			
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
	BTFSC	PORTB, 0		; TESTAR SE A PORTA DE COMEÇAR FOI PRESSIONADA
		GOTO	$ + 4		; SE NÃO VAI PARA A PROXIMA PORTA
		NOP
		BTFSS	PORTB, 0	; TESTANDO DE NOVO APOS O TEMPO DO DELAY
			BSF	FLAG, 1		; SE FOI PRESSIONADA ENTRA NO ESTADO DE INICIAR O CRONOMETRO
	
	BTFSC	PORTB, 1		; TESTAR SE A PORTA DE COMEÇAR FOI PRESSIONADA
		GOTO	$ + 4		; SE NÃO VAI PARA A PROXIMA PORTA
		NOP
		BTFSS	PORTB, 1	; TESTANDO DE NOVO APOS O TEMPO DO DELAY
			BSF	FLAG, 2		; SE FOI PRESSIONADA ENTRA NO ESTADO DE RESETAR O CRONOMETRO

	BTFSC	PORTB, 2		; TESTAR SE A PORTA DE COMEÇAR FOI PRESSIONADA
		GOTO	$ + 4		; SE NÃO VAI PARA A PROXIMA PORTA
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
RESET_CRON					; SE FOR PRESSIONADO O BOTÃO DE RESET 
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
STOP_CRON					; SE FOR PRESSIONADO O BOTÃO DE PARAR
	BCF	FLAG, 4				; NÃO ENTRA NO LAÇO DE ATUALIZAR O CRONOMETRO
	BCF	FLAG, 6
	BCF	FLAG, 3 
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ATUALIZA_CRON:
	MOVF	SEG_UNI, W
	XORLW	D'10'			; VERIFICA SE UNIDADES DE SGUNDOS É IGUAL A 10 
	BTFSS	STATUS, Z		; A "RESPOSTA" FICA ARMAZENADA EM STATUS, AI TESTAMOS 
		GOTO	AQUI		; SE NÃO FOR 10 VAI PARA O FINAL 
	INCF	SEG_DEZ, F		; SENÃO INCREMENTA A DEZENA DE SEGUNDOS 
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
					; TODA VEZ QUE O CRONOMETRO FOR ATUALIZADO O DISPLAY TAMBEM SERÁ 
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ATUALIZA_DISP
	MOVF	VARTMR1, W			; VERIFICA SE ESTÁ INSTRUÇÃO QUE DESEJA ESCREVER
	XORLW	D'0'				; VERIFICA SE A VARIAVEL TEM VALOR ADEQUADO
	BTFSS	STATUS, Z			; VERIFICA O REGISTRADOR STATUS E O BIT Z
		GOTO	NEXT1
	BCF 	RS 					; SELECIONA O DISPLAY P/ COMANDO
	MOVLW 	H'C0'				; COMANDO PARA POSICIONAR O CURSOR
	CALL 	ESCREVE 			; LINHA 2 / COLUNA 0
	BSF 	RS 
	MOVLW	B'00000001'			; LIGA A INTERRUPÇÃO DO TIMER 1
	MOVWF	T1CON	
	BCF		PIR1, 0				; DESATIVA A FLAG DA INTERRUPÇÃO DO TMR1

NEXT1:
	MOVF	VARTMR1, W
	XORLW	D'1'
	BTFSS	STATUS, Z
		GOTO	NEXT2
	MOVF	HRS_DEZ, W
	ADDLW	D'48'
	CALL 	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0	

NEXT2:
	MOVF	VARTMR1, W
	XORLW	D'2'
	BTFSS	STATUS, Z
		GOTO	NEXT3	
	MOVF	HRS_UNI, W
	ADDLW	D'48'
	CALL 	ESCREVE	
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT3:
	MOVF	VARTMR1, W
	XORLW	D'3'
	BTFSS	STATUS, Z
		GOTO	NEXT4
	MOVLW	'.'
	CALL	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT4:
	MOVF	VARTMR1, W
	XORLW	D'4'
	BTFSS	STATUS, Z
		GOTO	NEXT5
	MOVF	MIN_DEZ, W
	ADDLW	D'48'
	CALL 	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT5:
	MOVF	VARTMR1, W
	XORLW	D'5'
	BTFSS	STATUS, Z
		GOTO	NEXT6
	MOVF	MIN_UNI, W
	ADDLW	D'48'
	CALL 	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT6:
	MOVF	VARTMR1, W
	XORLW	D'6'
	BTFSS	STATUS, Z
		GOTO	NEXT7
	MOVLW	'.'
	CALL	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT7:
	MOVF	VARTMR1, W
	XORLW	D'7'
	BTFSS	STATUS, Z
		GOTO	NEXT8
	MOVF	SEG_DEZ, W
	ADDLW	D'48'
	CALL 	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT8:
	MOVF	VARTMR1, W
	XORLW	D'8'
	BTFSS	STATUS, Z
		GOTO	NEXT9
	MOVF	SEG_UNI, W
	ADDLW	D'48'
	CALL 	ESCREVE
	MOVLW	B'00000001'
	MOVWF	T1CON
	BCF		PIR1, 0

NEXT9:

	BCF		FLAG, 5
	;BCF		FLAG, 4
RETURN
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA