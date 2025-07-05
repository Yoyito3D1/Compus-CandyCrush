/*------------------------------------------------------------------------------

	$ candy2_main.c $

	Programa principal para la práctica de Computadores: candy-crash para NDS
	(2º curso de Grado de Ingeniería Informática - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: xxx.xxx@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: jonjordi.salvado@estudiants.urv.cat
	Programador 4: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include <candy2_incl.h>

#define MAX_MAPS 7


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de números aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// número de movimientos restantes
int gelees;						// número de gelatinas restantes

extern short escNum;

/* actualizar_contadores(code): actualiza los contadores que se indican con el
	parámetro 'code', que es una combinación binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}


/* inicializa_interrupciones(): configura las direcciones de las RSI y los bits
	de habilitación (enable) del controlador de interrupciones para que se
	puedan generar las interrupciones requeridas.*/ 
void inicializa_interrupciones()
{
    // Detener el temporizador antes de configurarlo
    TIMER1_CR = 0x00;

    // Configurar la frecuencia del temporizador según tus necesidades
    TIMER1_DATA = -3277; // Ajusta este valor según sea necesario

    // Configurar el temporizador en modo temporizador, habilitar la interrupción y establecer el divisor
    TIMER1_CR = TIMER_ENABLE | TIMER_DIV_1024 | TIMER_IRQ_REQ;

    // Configurar la rutina de servicio de interrupción
    irqSet(IRQ_TIMER1, rsi_timer1);

    // Habilitar la interrupción del temporizador
    irqEnable(IRQ_TIMER1);
}


/* Programa principal: control general del juego */
int main(void)
{
	int lapse = 0;				// contador de tiempo sin actividad del usuario
	int change = 0;				// =1 indica que ha habido cambios en la matriz
	int falling = 0;			// =1 indica que los elementos estan bajando
	int fall_init = 1;			// =1 inicializa la frecuencia de movimiento
	int initializing = 1;		// =1 indica que hay que inicializar un juego
	int mX, mY, dX, dY;			// variables de detección de pulsaciones

	seed32 = time(NULL);		// fijar semilla de números aleatorios
	init_grafA();
	inicializa_interrupciones();

	consoleDemoInit();			// inicialización de pantalla de texto
	printf("candyNDS (version 2: graficos)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	printf("\x1b[39m\x1b[2;0H puntos:");
	printf("\x1b[38m\x1b[1;15H movimientos:");
	printf("\x1b[37m\x1b[2;15H   gelatinas:");
	printf("\x1b[38m\x1b[3;0H despl.fondo (tecla Y): no");
	actualizar_contadores(15);
	
	do							// bucle principal del juego
	{
		if (initializing)		//////	SECCIÓN DE INICIALIZACIÓN	//////
		{
			inicializa_matriz(matrix, level);
			copia_mapa(matrix, level);
			genera_sprites(matrix);
			genera_mapa1(matrix);
			genera_mapa2(matrix);
			escribe_matriz(matrix);
			retardo(5);
			initializing = 0;
			falling = 0;
			change = 0;
			lapse = 0;
			points = pun_obj[level];
			movements = max_mov[level];
			gelees = contar_gelatinas(matrix);
			actualizar_contadores(15);
			
		}
		else if (falling)		//////	SECCIÓN BAJADA DE ELEMENTOS	//////
		{
			falling = baja_elementos(matrix);	// realiza la siguiente bajada
			if (falling)
			{									// si hay bajadas
				activa_timer0(fall_init);		// activar timer de movimientos
				while (timer0_on) swiWaitForVBlank();	// espera final
				fall_init = 0;					// continuar acelerando
			}
			escribe_matriz(matrix);			// visualiza bajadas o eliminaciones
		}
		else					//////	SECCIÓN DE JUGADAS	//////
		{
			if (procesar_touchscreen(matrix, &mX, &mY, &dX, &dY))
			{
				intercambia_posiciones(matrix, mX, mY, dX, dY);
				escribe_matriz(matrix);	  // muestra el movimiento por pantalla
			}
			while (keysHeld() & KEY_TOUCH)		// esperar a liberar la
			{	swiWaitForVBlank();				// pantalla táctil
				scanKeys();
			}
		}
		if (!falling)			//////	SECCIÓN DE DEPURACIÓN	//////
		{
			swiWaitForVBlank();
			scanKeys();
			if (keysHeld() & KEY_B)		// forzar cambio de nivel
			{	
				change = 1;
				printf("\x1b[2;8H      ");	// borra puntos anteriores
				initializing = 1;			// passa a inicializar nivel
			}
			lapse++;					// incrementar paso del tiempo
		}
		if (change)				//////	SECCIÓN CAMBIO DE NIVEL	//////
		{
			change = 0;
			printf("\x1b[39m\x1b[8;20H (Pulsa A)");
			do
			{	
				swiWaitForVBlank();
				scanKeys();					// esperar pulsación tecla 'A'
			} while (!(keysHeld() & KEY_A));
			printf("\x1b[6;20H           ");
			printf("\x1b[8;20H           ");	// borra mensajes
			printf("\x1b[2;8H      ");	// borra puntos anteriores
			level++;
			initializing = 1;			// passa a inicializar nivel
			borra_puntuaciones();
			lapse = 0;
		}
		if (escNum == 5)
		{
			swiWaitForVBlank();
			printf("\x1b[8;00H 5");
		}
		if (escNum == 12)
		{
			swiWaitForVBlank();
			printf("\x1b[8;05H 12");
		}
		if (escNum == 22)
		{
			swiWaitForVBlank();
			printf("\x1b[8;10H 22");
		}
		if (escNum == 32)
		{
			swiWaitForVBlank();
			printf("\x1b[8;15H 32");
		}
	} while (level <= MAX_MAPS);				// bucle
	
	return(0);					// nunca retornará del main
}

