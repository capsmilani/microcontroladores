# MPLAB IDE generated this makefile for use with GNU make.
# Project: Lab01.mcp
# Date: Fri Apr 01 20:09:30 2016

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

LED.cof : LED.o
	$(CC) /p16F877 "LED.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"LED.cof" /M"LED.map" /W /x

LED.o : LED.ASM C:/Program\ Files\ (x86)/Microchip/MPASM\ Suite/P16F877.INC
	$(AS) /q /p16F877 "LED.ASM" /l"LED.lst" /e"LED.err" /d__DEBUG=1

clean : 
	$(CC) "LED.o" "LED.hex" "LED.err" "LED.lst" "LED.cof"

