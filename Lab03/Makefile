# MPLAB IDE generated this makefile for use with GNU make.
# Project: Lab03.mcp
# Date: Fri Apr 08 16:25:27 2016

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

Lab03.cof : LED.o
	$(CC) /p16F877 "LED.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"Lab03.cof" /M"Lab03.map" /W

LED.o : LED.ASM C:/Program\ Files\ (x86)/Microchip/MPASM\ Suite/P16F877.INC
	$(AS) /q /p16F877 "LED.ASM" /l"LED.lst" /e"LED.err" /o"LED.o" /d__DEBUG=1

clean : 
	$(CC) "LED.o" "LED.err" "LED.lst" "Lab03.cof" "Lab03.hex"

