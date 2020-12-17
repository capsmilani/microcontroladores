# Microcontroladores
Repositorio com o intuito de divulgar atividades desenvolvidas durante a matéria de microcntroladores da UTFPR - campus Toledo, para todos os exercicios realizados neste projeto foi utilizado o kit de desenvolvimento "datapool", que segue o esquematico a seguir.

Figura 01 - Esquematico utilizado no projeto.
![Schematic](https://github.com/capsmilani/microcontroladores/blob/main/M%C3%B3dulo.png?raw=true)


# Atividades

## Atividade 01 - Chaves e LED's
Ao acionar chaves, os LEDs são ligados.Chave A liga LEDs 0 e 4, B liga LEDs 1 e 5, C liga LEDs 2 e 6, D liga LEDs 3 e 7;
* Chave ligada, liga LED, chave desligada, desliga LED;
* Habilitar o dip switch CH3 posição 5 (pino RC5) (posição ON para cima);
* Habilitar o dip CH5,1-4 (posição ON para cima);
* Habilitar todos os dips de CH4 (posição ON para cima);
* Desabilitar as demais chaves DIP;
* Manter o jumper J3 e J4 na posição A (1 e 2);
* Analisem o esquema elétrico do kit, para identificar as portas do PIC.

## Atividade 02 - Teclado e LED's
Ao pressionar as teclas de 1 a 8, os LEDs correspondentes (1 a 8) são ligados. Após soltar a tecla, continua ligado. Somente ao pressionar novamente são desligados.
* Habilitar o dip switch CH3,1-4 (posição ON para cima);
* Habilitar o dip CH5,1-4 (posição ON para cima);
* Habilitar todos os dips de CH4 (posição ON para cima);
* Desabilitar as demais chaves DIP;
* Manter o jumper J3 e J4 na posição A (1 e 2);
* L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...
* Analisem o esquema elétrico do kit, para identificar as portas do PIC.

## Atividade 03 - Teclado e Display de 7 segmentos
Ao pressionar as teclas 0 a F (borda de descida do I/O), o valor correspondente a tecla deve ser escrito no display 7 segmentos.
* Habilitar o dip switch CH3,1-4 (posição ON para cima);
* Habilitar todos os dips de CH4 (posição ON para cima);
* Habilitar o dip CH5,1-4 (posição ON para cima);
* Habilitar o dip CH6,1-4 (posição ON para cima);
* Desabilitar as demais chaves DIP;
* Manter o jumper J3 na posição B e J4 na posição A;
* L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...
* RE0 habilita o display 7 segmentos;
* D0 = ., D1 = g, D2 = f, D3 = e...

## Atividade 04 - Timer 0 e LED
A cada segundo é comandado o LED 1, ligando-o e desligando-o, alternadamente. A temporização deve ser realizada pelo Timer 0, sem o uso de interrupção.
* Habilitar CH4,1 (posição ON para cima);
* Desabilitar as demais chaves DIP;
* Manter o jumper J3 e J4 na posição A (1 e 2).

## Atividade 05 - Cronômetro
* Utilize a interrupção do Timer 0 como referência para temporizar 1 segundo.
* Escreva o tempo no display 7 segmentos: 00.00 (MM.SS).
* Ao pressionar a tecla 1 deve iniciar a contagem do cronômetro, atualizando o display a cada segundo.
* Ao pressionar a tecla 2, a contagem deve ser parada.
* Com a tecla 3 a contagem é zerada, voltando o display para 00.00.
  - Habilitar o dip switch CH3,1-4 (posição ON para cima);
  - Habilitar todos os dips de CH4 (posição ON para cima);
  - Habilitar o dip CH5,1-4 (posição ON para cima);
  - Habilitar o dip CH6,1-4 (posição ON para cima);
  - Desabilitar as demais chaves DIP;
  - Manter o jumper J3 na posição B e J4 na posição A;
  - L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...
  - RE0 habilita o display 7 segmentos;
  - D0 = ., D1 = g, D2 = f, D3 = e...
 
 ## Atividade 06 - Display LCD

* Utilize a interrupção do Timer 0 como referência para temporizar 1 segundo.
* Escreva o tempo no display LCD:
  - Linha 1: seus nomes, centralizado;
  - Linha 2: 00:00:00 (HH:MM:SS);
* Ao pressionar a tecla 1 deve iniciar a contagem do cronômetro, atualizando o display a cada segundo.
* Ao pressionar a tecla 2, a contagem deve ser parada.
* Com a tecla 3 a contagem é zerada, voltando o display para 00:00:00.
  - Habilitar o dip switch CH3,1-4 (posição ON para cima);
  - Habilitar todos os dips de CH4 (posição ON para cima);
  - Habilitar o dip CH5,1-4 (posição ON para cima);
  - Habilitar o dip CH6,1-2;
  - Desabilitar as demais chaves DIP;
  - Manter o jumper J3 na posição A e J4 na posição B;
  - L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...
 
##Atividade 07 - Timer 1

* Utilize a interrupção do Timer 0 e do Timer 1 para gerar as temporizações para teclado, display e cronômetro (1 segundo).
* Escreva o tempo no display LCD:
  - Linha 1: seus nomes, centralizado;
  - Linha 2: 00:00:00 (HH:MM:SS);
* Ao pressionar a tecla 1 deve iniciar a contagem do cronômetro, atualizando o display a cada segundo.
* Ao pressionar a tecla 2, a contagem deve ser parada.
* Com a tecla 3 a contagem é zerada, voltando o display para 00:00:00.
  - Habilitar o dip switch CH3,1-4 (posição ON para cima);
  - Habilitar todos os dips de CH4 (posição ON para cima);
  - Habilitar o dip CH5,1-4 (posição ON para cima);
  - Habilitar o dip CH6,1-2;
  - Desabilitar as demais chaves DIP;
  - Manter o jumper J3 na posição A e J4 na posição B;
  - L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...

## Atividade 08 - Teclado e LEDs Usando Linguagem C

* Ao pressionar as teclas de 1 a 8, os LEDs correspondentes (1 a 8) são ligados. Após soltar a tecla, continua ligado. Somente ao pressionar novamente são desligados.
  - Habilitar o dip switch CH3,1-4 (posição ON para cima);
  - Habilitar o dip CH5,1-4 (posição ON para cima);
  - Habilitar todos os dips de CH4 (posição ON para cima);
  - Desabilitar as demais chaves DIP;
  - Manter o jumper J3 e J4 na posição A (1 e 2);
  - L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...
 
## Atividade 09 - Calendário e Relógio

* Utilize a interrupção do Timer 0 e 1 para temporizações.
* Escreva o tempo no display LCD, centralizado:
  - Linha 1: data – DD/MM/AA;
  - Linha 2: hora – HH:MM:SS.
* Ao pressionar a tecla A, será iniciado a entrada de data e hora. Usando as teclas de 0 a 9, para cada dígito até concluir com os segundos.
* Após digitar os segundos, ao pressionar a tecla B, o calendário assume o valor digitado e começa a contagem. Só pode ser aceita data e horário válidos.
* Enviar documentação com: máquinas de estados, fluxogramas, descrição do projeto e funções, além do código fonte.
* Escrever o código em linguagem C.
  - Habilitar o dip switch CH3,1-4 (posição ON para cima);
  - Habilitar todos os dips de CH4 (posição ON para cima);
  - Habilitar o dip CH5,1-4 (posição ON para cima);
  - Habilitar o dip CH6,1-2;
  - Desabilitar as demais chaves DIP;
  - Manter o jumper J3 na posição A e J4 na posição B;
  - L1 – RC0; L2 – RC1; C1 – RB0; C2 – RB1...

## Atividade 10 - PWM 1

* Utilize a saída PWM1 (RC2), para controlar a intensidade luminosa da lâmpada;
* Utilize as teclas 0 a 3 para controlar a intensidade, com:
  - 0: 0%;
  - 1: 33%
  - 2: 66%
  - 3: 100%
* Configurar as chaves e jumpers:
  - Habilitar a chave CH2,2 (posição ON para cima)
  - Habilitar a chave CH3,1 (posição ON para cima)
  - Habilitar as chaves CH5,1 a CH5,4 (posição ON para cima)
  - Desabilitar as demais chaves DIP
  - Manter o jumper J1 e J2 na posição B
  - Manter o jumper J3 e J4 na posição A

## Atividade 11 - ADC

* Utilize o canal AN3 para ler a tensão no potenciômetro P1, 0 a 5 V;
* Mostre a tensão medida no display LCD;
* Configurar as chaves e jumpers:
  - Habilitar a chave CH1,3 (posição ON para cima)
  - Habilitar todos os dips de CH4 (posição ON para cima);
  - Desabilitar as demais chaves DIP;
  - Manter o jumper J3 na posição A e J4 na posição B;

## Atividade 12 - RS-232

* Configure a USART para comunicação RS-232, com 19200 bps, 8 bits, sem paridade;
* Pode utilizar interrupção ou flag;
* Utilize um terminal no computador para enviar ao kit, via RS-232, as teclas alfanuméricas pressionadas;
* O kit deve devolver a letra ou número seguinte ao pressionado;
* Configurar as chaves:
  - Habilitar a chave CH2,6 e 7 (posição ON para cima)
  - Desabilitar as demais chaves DIP.
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
