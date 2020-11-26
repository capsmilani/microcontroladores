; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CÓDIGO FONTE P/ DATAPOLL PIC-2377                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Projeto: Teclado e Display 7 Segmentos
; Aluno: Matheus Milani de Assunção	
; Data:	07/04/2016

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRIÇÃO GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; Ao pressionar as teclas 0 a F (borda de descida do I/O), o valor 
; correspondente a tecla deve ser escrito no display 7 segmentos.

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
; RE0 habilita o display 7 segmentos.

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
T1	EQU		.250
VEZES	EQU	D'30'
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                	        	MACROS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINIÇÃO DAS VARIÁVEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CBLOCK	0X20				; POSIÇÃO INICIAL DA RAM
		UAU				; VARIÁVEL PARA CONTAR APROX. 1 ms
		TEMPO_XMS			; PERÍODO PARA COMANDO DO LED
		FLAG				; AUXILIAR PARA DETECTAR SE BOTÃO ESTÁ LIGADO
		LINHA				; VARIAVEL QUE RECEBE A LINHA A QUE ESTÁ SENDO USADO	
		COLUNA				; VARIAVEL QUE RECEBE A COLUNA A QUE ESTÁ SENDO USADO	
		CASA				; LUGAR ONDE QUERO IMPRIMIR
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
#DEFINE FLAG0	FLAG, 0
#DEFINE FLAG1	FLAG, 1
#DEFINE FLAG2	FLAG, 2
#DEFINE FLAG3	FLAG, 3
#DEFINE FLAG4	FLAG, 4
#DEFINE FLAG5	FLAG, 5
#DEFINE FLAG6	FLAG, 6
#DEFINE FLAG7	FLAG, 7

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                               ENTRADAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE COL0	PORTB, 0
#DEFINE COL1	PORTB, 1
#DEFINE COL2	PORTB, 2
#DEFINE COL3	PORTB, 3

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                SAÍDAS                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE LIN0	PORTC, 0
#DEFINE LIN1	PORTC, 1
#DEFINE LIN2	PORTC, 2
#DEFINE LIN3	PORTC, 3
#DEFINE LIN4	PORTC, 4
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
	MOVLW	B'00000000'		; DEFINE AS PORTAS 0 A 7 COMO SAIDA
	MOVWF	TRISC
	MOVLW	B'11111111'		; DEFINE AS PORTAS 0 A 7 COMO ENTRADA
	MOVWF	TRISB
	MOVLW	B'00000000'		; DEFINE AS PORTAS 0 A 7 COMO SAIDA
	MOVWF	TRISD
	BANK0					; RETORNA PARA O BANCO 0.
	MOVLW	H'FF'
	MOVWF	PORTD			; ALTA TODAS AS SAÍDAS
	MOVLW	B'11111110'		
	MOVWF	PORTC			; ALTERNADA NAS SAIDAS DE C
	MOVLW	H'00'
	MOVWF	FLAG			; DEFININDO BAIXO PARA TODA A FLAG
	MOVLW	H'00'
	MOVWF	COLUNA			; INICIALIZANDO COM 0 PARA TODA A VARIAVEL COLUNA
	MOVLW	H'00'
	MOVWF	LINHA			; INICIALIZANDO COM 0 PARA TODA A VARIAVEL LINHA
	MOVLW	H'00'
	MOVWF	CASA			; INICIALIZANDO COM 0 PARA TODA A VARIAVEL CASA

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
MAIN

; * * * * * *INICIALIZA OS VALORES DAS CONSTANTES
	MOVLW	T1				; INCICIALIZA TODO INICIO DE CODIGO AS VARIAVEIS 
	MOVWF	TEMPO_XMS			; TEMPO_XMS E A VARIAVEL UAU
	MOVLW	VEZES
	MOVWF	UAU	

; * * * * * *ALTERNA OS VALORES DE LINHA
	BSF STATUS, 0				; LIMPA O CARRY PARA FAZER A ROTAÇÃO
	RLF	PORTC, 1			; ALTERNA OS VALORES DAS LINHAS 3X1 E 1X0
	INCF	LINHA, 1			; COLOCA NA VARIAVEL LINHA QUAL O LINHA ESTÁ SENDO TRABALHADO
	BTFSS	LIN4				; VERIFICA SE O 0 ROTACIONOU POR TODAS AS SAIDAS DA PORTC
		CALL	VALOR_INICIAL		; DEFINE UM VALOR INICIAL PARA A PORTC E PARA A VARIAVEL LINHA
; * * * * * *TESTA PARA VER SE ALGUMA COLUNA FOI PRESSIONADA
	BTFSC	COL0				;-------
		GOTO $ + 7			; DEBOUNCE
	CALL ENROLAÇAO				;-------
	BTFSC	COL0				; VE SE A COLUNA ESTÁ COM NIVEL 0
		GOTO $ + 4
	BSF FLAG0				; ATRIBUI VALOR PARA A FLAG, SE 1 O BOTÃO ESTÁ PRESSIONADO 
	MOVLW	D'0'				; ATRIBUI VALOR 0 PARA A VARIAVEL COLUNA
	GOTO FIM

	BTFSC	COL1
		GOTO $ + 7
	CALL ENROLAÇAO
	BTFSC	COL1
		GOTO $ + 4
	BSF FLAG0
	MOVLW	D'1'
	GOTO FIM	

	BTFSC	COL2
		GOTO $ + 7
	CALL ENROLAÇAO
	BTFSC	COL2
		GOTO $ + 4
	BSF FLAG0
	MOVLW	D'2'
	GOTO FIM

	BTFSC	COL3
		GOTO $ + 7
	CALL ENROLAÇAO
	BTFSC	COL3
		GOTO $ + 4
	BSF FLAG0
	MOVLW	D'3'
	GOTO FIM		
FIM:
	MOVWF	COLUNA
	BTFSS	FLAG0				; TESTA SE O BOTÃO FOI PRESSIONADO
		GOTO	MAIN
; * * * * *FORMULA PARA LEITURA DO TECLADO
	MOVF	LINHA, 0			; MOVE O VALOR DE LINHA PARA WORK
	MOVWF	CASA				; FAZ COM QUE CASA RECEBA LINHA
	BCF	STATUS, 0			; LIMPA A CARRY
	RLF	CASA, 1				; ROTACIONA O VALOR DA CASA (CASAX2)
	BCF 	STATUS, 0			
	RLF	CASA, 1				; ROTACIONA O VALOR DA CASA (CASAX2)
	MOVF	COLUNA, 0			; MOVE COLUNA PARA WORK
	ADDWF	CASA, 1				; SOMA CASAX4 COM COLUNA
; * * * * *CHAMA A TABELA PARA VER QUAL LED ACENDER
	CALL	TABELA				
	BCF	FLAG0				; FALA QUE JÁ ENTROU UMA VEZ NESSA FUNÇÃO, ENTÃO O BOTÃO FOI SOLTO
	MOVWF	PORTD				; ATRIBUI O QUE FOI RETORNADO DE TABELA PARA A PORTD
GOTO	MAIN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
TABELA:
	MOVLW	B'00001111'			; MASCARA PARA QUE O VALOR NÃO PASSE DE 16
	ANDWF	CASA, W				; PARA ISSO UTILIZA-SE AND
	ADDWF PCL, 1				; ADICIONA O VALOR DA CASA AO PCL, QUE PULA PARA QUAL RETORNO DESEJA
;		RETLW	B'11111111'
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
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	movlw	T1				; INCICIALIZA TODO INICIO DE CODIGO AS VARIAVEIS 
	movwf	TEMPO_XMS		; TEMPO_XMS E A VARIAVEL UAU
	movlw	VEZES
	movwf	UAU	

						; VERIFICA SE ALGUM BOTÃO FOI APERTADO
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	               ROTINA DE DELAY (DE 1ms ATÉ 255ms)       	            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
ENROLAÇAO						; FUNÇÃO DELAY
	movlw	T1					; MOVE A CONST. DE TEMPO "250" PARA WORK
	movwf	TEMPO_XMS				; MOVE O CONTEUDO DE WORK PARA A VARIAVEL TEMPO_XMS
AUX
	NOP						; REPETE-SE 10x NOP PARA DAR 10 CICLOS DE MAQUINA
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
		GOTO	AUX
	DECFSZ	UAU,F				; DECREMENTA UAU ATÉ QUE SEJA 0
		GOTO	ENROLAÇAO
	MOVLW	VEZES
	MOVWF	UAU
	RETURN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *	               VALOR INICIAL DA LINHA				       	            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
VALOR_INICIAL
	MOVLW	B'11111110'
	MOVWF	PORTC				; PARA QUE O 0 RETORNE NA POSIÇÃO INICIAL
	MOVLW	H'00'
	MOVWF	LINHA				; LOGO ZERA-SE O VALOR DA LINHA
RETURN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          	FIM DO PROGRAMA                             *
; *                                                                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END				; FIM DO PROGRAMA