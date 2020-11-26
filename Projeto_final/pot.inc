;----------------------------------------------------------------------------
;						BIBLIOTECA PARA LCD									|
; Disciplina: Microcontroladores											|
; Desenvolvido por: Rodrigo Antonio Sbardeloto Kraemer						|
; 		 			Mateus Milani											|
;Data:	30/06/2016															|
;----------------------------------------------------------------------------
;                             DESCRICAO GERAL                             

;Utiliza o canal AN3 para ler a tensao no potenciometro P1, 0 a 5V.
;Transfere a potencia para o PWM e controla a intensidade da lampada.
;----------------------------------------------------------------------------
;                            DEFINICAO DAS VARIAVEIS                      
;		AUX					;Guarda valores LSB do conversor
;----------------------------------------------------------------------------
;			REGISTRADORES A SEREM CONFIGURADOS NO CODIGO PRINCIPAL
	
;	
;	PWM
;	PR2(61)			Carrega PR2 com 61 - freq (16 kHz)
;	T2CON(00000101)	Prescaler 1:4 (bit 0 e 1), ON (bit 2) TMR2
;	CCP1CON(00001100)	Configura o modulo como PWM
;----------------------------------------------------------------------------
;							INICIALIZACAO DE VARIAVEIS E PERIFÉRICOS			
;Cristal de 16MHz.
;	movlw	B'00000000'			;Limpa os registradores do PWM
;	movwf	CCPR1L
;	bcf		CCP1CON,5
;	bcf		CCP1CON,4
;----------------------------------------------------------------------------
;             				FUNCAO PWM         
;
;Esta funcao configura o pwm, de acordo com o estado do potenciometro
;para controle da intensidade luminosa da lampada.                  
;----------------------------------------------------------------------------
PWM:
	bcf		LINHA,0
	
	TECLA_0:					;Ton - 0%
		btfsc	TECLA,0
		goto	TECLA_1
		
		movlw	B'00000000'		
		movwf	CCPR1L
		bcf		CCP1CON,5
		bcf		CCP1CON,4		
		
	TECLA_1:					;Ton - 33%
		btfsc	TECLA,1
		goto	TECLA_2
		
		movlw	B'01010011'		
		movwf	CCPR1L
		bsf		CCP1CON,5
		bsf		CCP1CON,4	
		
	TECLA_2:					;Ton - 66%
		btfsc	TECLA,2
		goto	TECLA_3
		
		movlw	B'10100101'		
		movwf	CCPR1L
		bcf		CCP1CON,5
		bsf		CCP1CON,4	
		
	TECLA_3:					;Ton - 100%
		btfsc	TECLA,3
		return
		
		movlw	B'11111010'		
		movwf	CCPR1L
		bsf		CCP1CON,5
		bcf		CCP1CON,4
	
	return