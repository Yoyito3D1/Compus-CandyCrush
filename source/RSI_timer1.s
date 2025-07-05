@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: jonjordi.salvado@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	-5727,5		@;divisor de frecuencia para timer 1


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
		.global escNum
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;Factor actual de escalado
	escNum: .space	2				@;n�mero de variaciones del factor


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado seg�n el par�metro init.
@;	Par�metros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r1-r3, lr}
		ldr r1, =timer1_on
		ldrh r2, [r1]			@; r1 = timer1_on
		mov r2, #1
		strh r2, [r1]			@; timer1_on = 1		
		ldr r2, =divFreq1
		ldrh r3, [r2]			@; r3 = div_freq
		ldr r2, =0x04000104		@; direccio per timer1_data	
		orr r3, #0x00C10000		@; mascara que farem servir	per activar el timer amb freq d'entrada
		str r3, [r2]
		mov r1, #0
		ldr r2, =escNum
		strh r1, [r2]			@; @escNum = 0		
		ldr r1, =escSen
		strh r0, [r1]			@; escSen = init				
		cmp r0, #0
		bne .Lfinal
		mov r1, #1
		mov r0, r1, lsl #8		@; Guardarem 1,0 en format 0.8.8
		ldr r1, =escFac
		strh r0, [r1]			@; escFac = 1.0	
		mov r1, r0
		mov r2, r0
		mov r0, #0				@; Canviem r0 abans de cridar funci�
		bl SPR_fijarEscalado
	.Lfinal:			
		pop {r1-r3, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0, r1,lr}
		ldr r0, =timer1_on
		mov r1, #0
		strh r1, [r0] 			@; al guardar 0 desactivem timer1_on			
		ldr r0, =0x04000106		@; aquesta direccio es timer1_control	
		ldrh r1, [r0]
		bic r1, #128			@; posa bit 7 a 0 sempre per tancar timer (0111 1111)		
		strh r1, [r0]			@; guardem al registre de control	
		pop {r0, r1,pc}


@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	n�mero de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual seg�n el c�digo de la variable 'escSen'. Cuando se llega al m�ximo
@;	se desactivar� el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r2, lr}
		ldr r0, =escNum
		ldrh r1, [r0]
		add r1, #1				@; escnum++
		strh r1, [r0]				
		cmp r1, #32				@; if(escnum == 32) then desactivar_timer1
		bne .Linferior32
		bl desactiva_timer1		
		b .LfinalRSI
	.Linferior32:
		ldr r0, =escSen
		ldrh r1, [r0]
		ldr r0, =escFac
		ldrh r2, [r0]
		cmp r1, #0				@; if (escSen != 0) then esFac--			
		subne r2, #32
		cmp r1, #0				@; if (escSen == 0) then esFac++
		addeq r2, #32
		strh r2, [r0]			@; guardem escFac			
		mov r1, r2
		mov r0, #0
		bl SPR_fijarEscalado	@; actualitzem valor escalat	
		ldr r0, =update_spr
		mov r1, #1
		strh r1, [r0]			@; activem variable update_spr		
	.LfinalRSI:
		pop {r0-r2, pc}

.end
