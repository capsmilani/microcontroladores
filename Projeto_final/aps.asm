;----------------------------------------------------------------------------
;							ENGENHARIA ELETRONICA							|
; Disciplina: Microcontroladores											|
; ATIVIDADE PRÁTICA SUPERVISIONADA											|
; Projeto: 2 - Sensor de temperatura										|
; Alunos: Rodrigo Antonio Sbardeloto Kraemer								|
; 		  Mateus Milani														|
;Data:	30/06/2016															|
;																			|
;----------------------------------------------------------------------------
;                             DESCRICAO GERAL                             

;Le o sensor de temperatura, escreve a temperatura no display e envia para o 
;terminal, no PC. Salva a temperatura na memoria E2PROM (cada 30 s). Via 
;teclado do PC consegue ler os valores salvos. Atraves da lampada controla-se 
;a temperatura.

;----------------------------------------------------------------------------
;                       CONFIGURACAO DOS JUMPERS DE PLACA                  

; Habilitar o dip CH1,2 e 3.
; Habilitar todos os dips CH4 (ON).
; Habilitar o dip CH3,1.
; Habilitar o dip CH6,1-2.
; Habilitar o dip CH5,1-4.
; Desabilitar as demais chaves DIP.
; Manter o jumper J3 na posicao A e J4 na posição B.
;----------------------------------------------------------------------------
;                          CONFIGURACOES PARA GRAVACAO                     

 __CONFIG _WDT_OFF & _XT_OSC & _LVP_OFF & _DEBUG_ON & _BODEN_OFF

;_CP_OFF 	==> MEMORIA DE PROGRAMA DESPROTEGIDA CONTRA LEITURA.
;_WRT_OFF 	==> SEM PERMISSÃO PARA ESCREVER NA MEMORIA DE PROGRAMA
;				DURANTE EXECUCAO DO PROGRAMA.
;_DEBUG_ON	==> DEBUG ATIVADO.
;_CPD_OFF 	==> MEMÓRIA EEPROM PROTEGIDA CONTRA LEITURA.
;_LVP_OFF 	==> PROGRAMACAO EM BAIXA TENSÃO DESABILITADA.
;_WDT_OFF 	==> WDT DESATIVADO.
;_BODEN_OFF	==> BROWN-OUT DESATIVADO. 
;_PWRTE_ON 	==> POWER-ON RESET ATIVADO.
;_XT_OSC 	==> OSCILADOR CRISTAL (4MHz).

;----------------------------------------------------------------------------
;                           ARQUIVOS DE DEFINICOES                         

#INCLUDE	<P16F877.INC>		;Arquivo padrão microchip para 16F877

;----------------------------------------------------------------------------
;                          DEFINICOES DAS CONSTANTES                        


;----------------------------------------------------------------------------
;                 					MACROS                 				    

;----------------------------------------------------------------------------
;                            DEFINICAO DAS VARIAVEIS                      

	CBLOCK	0x20			;Posicao inicial da RAM
		
		STATUS_TEMP			;Variavel para armazenamento do STATUS na interrupcao.
		W_TEMP				;Variavel para armazenamento de W na interrupcao.
		PULSO_seg
		TEMPO_gravar
		FLAG
		BOTAO				;biblioteca	USER
		;ENDERECO			;biblioteca E2PROM
		;DADO
		 ENDERECO		;Biblioteca MemoriasDec							   *
		 ENDERECO_H	;Biblioteca MemoriasDec						       *
		 ENDERECO_L	;Biblioteca MemoriasDec						   	   *
		 DADO			;Biblioteca MemoriasDec							   *
		 DADO_H		;Biblioteca MemoriasDec							   *
		 DADO_L		;Biblioteca MemoriasDec							   *
		 AUXTECLA		;Biblioteca MemoriasDec	
		AUX					;biblioteca PWM
		TEMPO_xms			;biblioteca DISPLAY
		xxx_PRINT			;biblioteca DISPLAY
		TEMPO_ms			;biblioteca DISPLAY
		TEMPO_us			;biblioteca DISPLAY
		AUXTRANS			;biblioteca TERMINAL
		xxx_SEND			;biblioteca TERMINAL
		ENDERECO1			;biblioteca USER
		ENDERECO2
		TEMPERATURA_c 		;biblioteca lm35
		TEMPERATURA
		TEMPERATURA_d		;biblioteca lm35
		TEMPERATURA_u		;biblioteca lm35
		TEMPERATURA_m		;biblioteca lm35
		TEMPERATURA_x 		;biblioteca lm35
		MULT_1				;biblioteca math
		MULT_2				;biblioteca math
		PRODUTO				;biblioteca math
		PRODUTO_H
		PRODUTO_L
		MULT_TMP
		MULT_1_H								
		MULT_1_L
		QUOCIENTE_H
		QUOCIENTE_L	
		DIVIDENDO_H
		DIVIDENDO_L
		RESTOTMP_H
		RESTOTMP_L
		RESTO_H
		RESTO_L	
		DIVISOR_H
		DIVISOR_L
		NUM1
		NUM2
		NUM3
		NUM4
		NUM5	
		DIVIDENDOTMP_H	
		DIVIDENDOTMP_L	
		DIVISORTMP_H	;biblioteca math
		DIVISORTMP_L	;biblioteca math
					
	ENDC
;----------------------------------------------------------------------------
;                       DEFINICAO DOS BANCOS DA RAM                        

BANK0	MACRO					;Seleciona Bank0 de memória.
				bcf STATUS,RP1
				bcf	STATUS,RP0
		ENDM					;Fim da MACRO Bank0

BANK1	MACRO					;Seleciona Bank1 de memória.
				bcf STATUS,RP1
				bsf	STATUS,RP0
		ENDM					;Fim da MACRO Bank1.
		
BANK2	MACRO					;SELECIONA BANK2 DE MEMÓRIA.
				bsf STATUS,RP1
				bcf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK2.

BANK3	MACRO					;SELECIONA BANK3 DE MEMÓRIA.
				bsf STATUS,RP1
				bsf	STATUS,RP0
		ENDM					;FIM DA MACRO BANK3.

;----------------------------------------------------------------------------
;                                FLAGS 

;----------------------------------------------------------------------------
;                                ENTRADAS                                  
;Pinos que serao utilizados como entrada.
#DEFINE		RS			PORTE,0		;Selecao de registro
#DEFINE		ENABLE		PORTE,1		;Inicia o ciclo de leitura/escrita
#DEFINE		TECLA		PORTB		;Colunas do teclado multiplexado.

;----------------------------------------------------------------------------
;                                 SAIDAS                                   
;Pinos que serao utilizados como saida.

#DEFINE		LINHA		PORTC		;Linhas do teclado multiplexado

;----------------------------------------------------------------------------


;----------------------------------------------------------------------------
;                    VETOR DE RESET DO MICROCONTROLADOR                    

	ORG	0x00			;Endereco inicial de processamento.
	goto	Inicio

;----------------------------------------------------------------------------
;                VETOR DE INTERRUPCAO DO MICROCONTROLADOR                  


	ORG	0x04			;Endereco inicial de interrupcao

Interrupcao:				;Funcao para tratamento de interrupcao

	movwf	W_TEMP			;Guarda o valor de W
	swapf	STATUS,W		;Inverte os nibbles para nao ter risco de altera-los
	movwf	STATUS_TEMP		;Guarda o STATUS
	
	btfsc	PIR1,RCIF
	goto	RECEPCAO
	
	btfsc	INTCON,2		;Testa se foi a interrupcao de TMR0
	goto	TEMPO
	
	bsf		T1CON,0
	
	goto	INT_OUT
	
RECEPCAO:
	bsf		FLAG,6
	movf	RCREG,W
	movwf	ENDERECO2
	goto	INT_OUT
	
TEMPO:
	bcf		INTCON,2		;Sim, limpa a flag
	movlw	.6				;Reinicia TMR0 com 6, para contar 250
	movwf	TMR0		
	
	decfsz	PULSO_seg		;Decrementa PULSO_seg
	goto	INT_OUT			;Se nao for 0, vai para o final da funcao
	
	movlw	.250			;Se for 0, reinicia ele pra contar mais 1 segundo
	movwf	PULSO_seg
	bsf		FLAG,3
	
	incf	TEMPO_gravar	
	
INT_OUT:
	swapf	 STATUS_TEMP,W
	movwf	 STATUS 	;Recupera STATUS
	swapf	 W_TEMP,F
	swapf	 W_TEMP,W 	;Recupera W

	retfie
	
;----------------------------------------------------------------------------
;               CONFIGURACOES INICIAIS DE HARDWARE E SOFTWARE              
; Nesta rotina sao inicializadas as portas de I/O do microcontrolador, os
; perifericos que serao usados e as configuracoes dos registradores 
; especiais (SFR). 
;----------------------------------------------------------------------------
Inicio:
	
	BANK1					;Altera para o Bank1.
	movlw	B'00001111'
	movwf	TRISA
	movlw	B'00001111'
	movwf	TRISB
	movlw	B'11000000'
	movwf	TRISC
	movlw	B'00000000'
	movwf	TRISD			;Toda PORTD e saida.
	movlw	B'00000000'
	movwf	TRISE
	
	movlw	B'00000001'
	movwf	PIE1			;Configuracao PIE1
							;interrupcoes
							;5: enable USART receive (RCIE)
							;4: enable USART transmit (TXIE)
	movlw	B'11100000'
	movwf	INTCON
	movlw	B'10000100'
	movwf	ADCON1			;sera reconfigurado de acordo com a funcao
	MOVLW	B'11000101'	
	MOVWF	OPTION_REG
	movlw	B'00100100'
	movwf	TXSTA			;Configuracao TXSTA
							;7: p/ assincrono don't care (CSRC)
							;6: 9-bit transmt enable bit(TX9)
							;5: transmit disable bit (setara TXIF) (TXEN)
							;4: USART mode - 0 = assincrono (SYNC)
							;2: baud rate - 1 = high speed (BRGH)
							;1: transmit shift register - 1 = TSR empty (TRMT)
							;0: bit de paridade (TX9D)
	movlw	.51
	movwf	SPBRG			;De acordo com a tabela do datasheet este registrador
							;e carregado com 51, para ter um baud rate de 19200 bps

	BANK0					;Retorna para o Bank0.
	movlw	B'10010000'
	movwf	RCSTA			;Configuracao RCSTA
							;7: serial port enable - RC7 e RC6 (SPEN)
							;6: 0 = 8bit reception (RX9)
							;5: assincrono - don't care (SREN)
							;4: enable continous recieve (CREN)
							;3: adress detect - disable (ADDEN)
							;2: framming error (FERR)
							;1: overrun error (OERR)
							;0: bit de paridade (RX9D)
	movlw	B'00110000'
	movwf	T1CON
	movlw	B'10001101'
	movwf	ADCON0			
							
	movlw	.250
	movwf	PR2				;Carrega PR2 com 250 - freq (16 kHz)
	movlw	B'00000100'
	movwf	T2CON			;Prescaler 1:1 (bit 0 e 1), ON (bit 2) TMR2
	movlw	B'00001100'
	movwf	CCP1CON			;Configura o modulo como PWM
	
	movlw	B'00000000'			;Limpa os registradores do PWM
	movwf	CCPR1L
	bcf		CCP1CON,5
	bcf		CCP1CON,4
	
	movlw	B'11111111'
	movwf	TMR1H
	movlw	B'00000000'
	movwf	TMR1L
	
	movlw	B'00000000'		
	movwf	PORTD			;Inicializa a PORTD.
	
	movlw	.6				;Inicia timer com 6, para contar 250.
	movwf	TMR0
	movlw	.250			;Inicia com 250, para fechar 1s.
	movwf	PULSO_seg
	movlw	.0
	movwf	TEMPO_gravar
	
	movlw	.1
	movwf	xxx_SEND
	movlw	.1
	movwf	xxx_PRINT
	
	clrf	FLAG

	call	ON_LCD
	call	INICIALIZA_E2PROM 
	
	movlw	0X00
	movwf	ENDERECO
	
;----------------------------------------------------------------------------
;                     INICIALIZACAO DA RAM                       

;  LIMPA DE TODA A RAM DO BANC0 0, INDO DE 0X20 A 0X7F.
	movlw	0x20
	movwf	FSR				;APONTA O ENDEREÇAMENTO INDIRETO PARA
							;A PRIMEIRA POSIÇAO DA RAM.
LIMPA_RAM
	clrf	INDF			;LIMPA A POSIÇAO ATUAL.
	incf	FSR,F			;INCREMENTA PONTEIRO P/ A PROX. POS.
	movf	FSR,W
	xorlw	0x80			;COMPARA PONTEIRO COM A ULT. POS. +1.
	btfss	STATUS,Z		;JA LIMPOU TODAS AS POSIÇOES?
	goto	LIMPA_RAM		;NAO, LIMPA A PROXIMA POSICAO.
							;SIM, CONTINUA O PROGRAMA.

;----------------------------------------------------------------------------
;					INICIALIZACAO DE VARIAVEIS E PERIFÉRICOS			
;Cristal de 16MHz.



;----------------------------------------------------------------------------
;             				ROTINA PRINCIPAL         
;Rotina principal do programa.                   
;----------------------------------------------------------------------------
Main:
	

	ESTADO1:
		call	SENSOR	
	
	ESTADO2:
		call	IMPRIME
	
	ESTADO3:
		btfsc	FLAG,3
		call	SEND

	
	ESTADO4:
		call	PWM
		
	ESTADO5:
		movf	TEMPO_gravar,W
		xorlw	.5
		btfss	STATUS,Z
		goto	ESTADO6
		call	MEMORIA
		movlw	.0
		movwf	TEMPO_gravar
		
	ESTADO6:
		btfsc	FLAG,6
		call	USUARIO
	
	goto	Main

;---------------------------------------------------------------------------------
;                           	FIM DO PROGRAMA                             
#INCLUDE <lm35.inc>
#INCLUDE <display.inc>
#INCLUDE <pot.inc>	
#INCLUDE <MemoriasDec.inc>
#INCLUDE <math.inc>
#INCLUDE <terminal.inc>
#INCLUDE <user.inc>

	END				; Fim do programa.
;---------------------------------------------------------------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	