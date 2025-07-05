@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos 	===
@;=                                                          			=
@;=== Programador tarea 1E: jonjordi.salvado@estudiants.urv.cat			===
@;=== Programador tarea 1F: jonjordi.salvado@estudiants.urv.cat			===
@;=                                                         	      	=


.include "../include/candy1_incl.i"


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el n�mero de
@;	repeticiones del elemento situado en la posici�n (f,c) de la matriz, 
@;	visitando las siguientes posiciones seg�n indique el par�metro de
@;	orientaci�n 'ori'.
@;	Restricciones:
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;		* la primera posici�n tambi�n se tiene en cuenta, de modo que el n�mero
@;			m�nimo de repeticiones ser� 1, es decir, el propio elemento de la
@;			posici�n inicial
@;	Par�metros:
@;		R0 = direcci�n base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientaci�n 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = n�mero de repeticiones detectadas (m�nimo 1)
.global cuenta_repeticiones    
cuenta_repeticiones:           
		push {r1-r2, r4-r9, lr}  
		
		mov r4, #ROWS             
		mov r5, #COLUMNS          
		
		@; C�lcul de posici� inicial de la matriu (apliquem f�rmula)
		mul r6, r1, r5            @; �ndex de fila * nombre de columnes
		add r6, r6, r2            @; r2 + l'�ndex de fila * nombre de columnes
		add r6, r6, r0            @; Direcci� base de la matriu + r6
		ldrb r7, [r6]             @; Carrega a r7 el valor de la posici� inicial
		and r7, r7, #0x07         @; Guardem sol 3 bits de menor pes per obtenir valor de 0-7
		
		mov r9, #1                @; r9 = num de repeticions
		
	.LBuclePrincipal:
		cmp r3, #0                @; (0 -> Est)
		beq .LEst
		cmp r3, #1                @; (1 -> Sud)
		beq .LSud
		cmp r3, #2                @; (2 -> Oest)
		beq .LOest
		cmp r3, #3                @; (3 -> Nord)
		beq .LNord
		b .LFinalPrograma          @; Gesti� d'errors: si no es compleix cap orientaci� es surt del bucle
		
	.LEst:
		add r2, r2, #1            @; Columna++
		cmp r2, r5                
		bhs .LFinalPrograma       
		add r6, r6, #1            @; Actualitza la posici� a la matriu
		b .LComprovarFinal
		
	.LSud:
		add r1, r1, #1            @; Fila++
		cmp r1, r4                
		bhs .LFinalPrograma        
		add r6, r6, r5            @; Nova posici� de mem�ria actualitzat
		b .LComprovarFinal
		
	.LOest:
		sub r2, r2, #1            @; Columna--
		cmp r2, #0                
		blt .LFinalPrograma        
		sub r6, r6, #1            @; Nova posici� de mem�ria actualitzat
		b .LComprovarFinal
		
	.LNord:
		sub r1, r1, #1            @; Fila--
		cmp r1, #0                
		blt .LFinalPrograma        
		sub r6, r6, r5            @; Nova posici� de mem�ria actualitzat
		
	.LComprovarFinal:
		ldrb r8, [r6]             
		and r8, r8, #0x07         
		cmp r8, r7                
		bne .LFinalPrograma        
		add r9, r9, #1            @; Augmenterem el contador de repeticions si el nou element i el 1r element son iguals
		b .LBuclePrincipal         
		
	.LFinalPrograma:
		mov r0, r9                @; Guardem resultat a r0
		pop {r1-r2, r4-r9, pc}  


@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vac�as, primero en vertical y despu�s en sentido inclinado; cada llamada a
@;	la funci�n s�lo baja elementos una posici�n y devuelve cierto (1) si se ha
@;	realizado alg�n movimiento, o falso (0) si est� todo quieto.
@;	Restricciones:
@;		* para las casillas vac�as de la primera fila se generar�n nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado alg�n movimiento, de modo que puede que
@;				queden movimientos pendientes. 
.global baja_elementos
baja_elementos:
		push {r4, lr}
		
		mov r4, r0				@; Passem la direccio de la matriu a r4 per a poder cridar les funcions
		bl baja_verticales	
		cmp r0, #1				@; Si retorna un 1 acabem i no entrem a laterals
		beq .LFinal
		bl baja_laterales
		
	.LFinal:
		
		pop {r4, pc}


@;:::RUTINAS DE SOPORTE:::

@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en vertical; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
.global baja_verticales
baja_verticales:
		push {r1-r3, r5-r12, lr}
		
		mov r1, #ROWS		
		mov r2, #COLUMNS	 
		mov r3, r1
		mov r0, #0
		
	.Lforx:						@; Comencem el recorregut invers
		sub r3, r3, #1			@; Fila--		
		mov r5, r2
		
	.Lfory:	
		sub r5, r5, #1			@; Columna--	
		mla r6, r2, r3, r5		@; r6 = Fila * NC + Columna
		add r6, r6, r4
		ldrb r7, [r6]			@; r7 = Matriu[Fila][Columna]		
		and r8, r7, #0x07		@; Omitim els bits de pes x>3
		cmp r8, #0			
		beq .LVerOLat
		
	.LFifory:					@; r3 = filaActual ; r5 = columnaActual		
		cmp r5, #0
		bhi .Lfory				@; Quan columnaActual == 0, �ltima columna
		cmp r3, #0			
		bhi .Lforx			
		b .Lfi					@; Acabarem la funci� quan arribi a (0,0)				
		
	.LVerOLat:
		cmp r3, #0		
		beq .LPrimeraFila		@; Comprovar si estema a x = 0 (1a fila)
		mov r8, r3
		
	.LBaixaVert:
		sub r8, r8, #1			
		cmp r8, #0				
		blt .LFifory
		mla r9, r8, r2, r5
		add r9, r9, r4
		ldrb r10, [r9]			
		cmp r10, #7				@; Codi per tenir en compte blocs s�lids	
		beq .LFifory	
		and r11, r10, #7		@; Codi per tenir en compte buids
		cmp r11, #0				
		beq .LFifory		
		cmp r10, #15			@; Codi per tenir en compte espais buids		
		beq .LBaixaVert			
		add r12, r11, r7		@; Finalment fusi� amb el tipus especial	
		and r11, r10, #0x18		@; Fem que no sigui una gelatina
		strb r11, [r9]			@; Actualitzem valors		
		strb r12, [r6]			
		mov r0, #1				@; Hi ha hagut moviment
		b .LFifory
		
	.LPrimeraFila:
		
		push {r0}
		
		mov r0, #6				
		bl mod_random			
		add r0, r0, #1			@; Fem que no pugui ser valor inv�lid						
		
		and r0, r0, #7			@; Error Management
		cmp r0, #7
		movge r0, #6
		cmp r0, #0
		moveq r0, #1
		
		add r1, r0, r7 			@; Special Value Management	
		strb r1, [r6]
		mov r1, #0
		mov r2, r5
		
		pop {r0}
		
		mov r0, #1				@; Hi ha hagut moviment			
		b .LFifory
		
	.Lfi:
		
		pop {r1-r3, r5-r12, pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en diagonal; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_laterales:
		push {r1-r3, r5-r12, lr}
		mov r2, #COLUMNS	
		mov r3, #1				@; x = 1		
		mov r0, #0				@; Moviment = 0
		
	.LforxAxis:					@; Seguim la mateixa logica de bucles que a baja_lat
		mov r5, #0				@; y = 0			
		
	.LforyAxis:	
		mov r1, #ROWS		
		mla r6, r2, r3, r5
		add r6, r6, r4
		ldrb r7, [r6]			
		and r8, r7, #0x07		
		cmp r8, #0				
		beq .LmovEsquerra
		
	.LFiforxAxis:
		add r5, #1			
		cmp r5, r2				@; Primer comprovem que no estiguem fora de la matriu
		blo .LforyAxis
		add r3, #1			
		cmp r3, r1				@; Despr�s que no la sobrepassem
		blo .LforxAxis
		b .Lend
		
	.LmovEsquerra:				@; Comencem intentant carregar el valor esquerra
		mov r1, #0
		sub r10, r3, #1			@; x--
		sub r7, r5, #1			@; y--	
		cmp r7, #0						
		blt .LmovDreta			@; Condicio = sortir de la matriu
		mla r8, r10, r2, r7		@; Si no surtim carreguem el valor i mirem que no sigui 0
		add r8, r8, r4	
		ldrb r9, [r8]
		and r10, r9, #0x07	
		
		cmp r10, #0				@; Cas buid
		beq .LmovDreta
		
		cmp r9, #7				@; Cas solid
		beq .LmovDreta
		
		cmp r9, #15				@; Cas forat
		beq .LmovDreta
		
		mov r1, #1				@; Si no es cap dels 3 then r1 = 1
		
	.LmovDreta:					@; Igual pero amb la dreta
		sub r10, r3, #1			
		add r7, r5, #1			
		cmp r7, r2
		bhs .LtriaOpcio
		mla r12, r10, r2, r7
		add r12, r12, r4		
		ldrb r11, [r12]
		and r10, r11, #0x07
		
		cmp r10, #0
		beq .LtriaOpcio
		
		cmp r11, #7
		beq .LtriaOpcio
		
		cmp r11, #15
		beq .LtriaOpcio
		
		add r1, r1, #2
		
	.LtriaOpcio:				@; Bucle per discernis si anirem o dreta o esquerra				
		cmp r1, #3				
		beq .LEsquerraoDreta		
		cmp r1, #2				
		beq .LDreta		
		cmp r1, #1				
		beq .LEsquerra
		b .LFiforxAxis
		
	.LEsquerraoDreta:			@; Al poder anar als 2 llocs ho farem aleatori
		mov r11, r0
		mov r0, #1
		bl mod_random			
		cmp r0, #0
		beq .LDreta	
		
	.LEsquerra:	
		
		push {r0-r5}			@;Funcio 2Id
			mov r4, r1
			mov r5, r2
			sub r0, r4, #1
			sub r1, r5, #1
			mov r2, r4
			mov r3, r5
			bl activa_elemento
		pop {r0-r5}
		
		ldrb r7, [r6]			@; Carreguem element i inserim la suposada gelatina
		and r11, r9, #0x07		@; Valor de base
		add r11, r11, r7			 
		and r12, r9, #0x18		@; Agreguem valor base amb la gelatina
		strb r12, [r8]		
		strb r11, [r6]			@; Guardem elements	
		mov r0, #1				@; Moviment = true
		b .LFiforxAxis
		
	.LDreta:					@; Igual pero amb esquerra
		
		push {r0-r5}			@;Funcio 2Id
			mov r4, r1
			mov r5, r2
			sub r0, r4, #1
			sub r1, r5, #1
			mov r2, r4
			mov r3, r5
			bl activa_elemento
		pop {r0-r5}
		
		and r8, r11, #0x07		
		ldrb r7, [r6]
		add r8, r8, r7			
		and r9, r11, #0x18		
		strb r9, [r12]		
		strb r8, [r6]		 
		mov r0, #1				@; Moviment = true
		b .LFiforxAxis
		
	.Lend:
		
		pop {r1-r3, r5-r12, pc}


.end
