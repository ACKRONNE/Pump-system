;Programa realizado por

;			N O M B R E 	|	C E D U L A 
;			Amparo Obando	|	28.210.570
;			Andres Lopez	|	30.114.256
;			Israel Mejias	|	28.149.883


		LIST P=16F84A			;Libreria del PIC a utilizar

OP		EQU		01H				;Registro Option
TMR0	EQU		01H				;Registro del Timer
INTCON	EQU		0BH				;Registo INTCON
TRISA	EQU		05H				;Registro de configuracion de Puerta A
PA		EQU		05H				;Puerta A
TRISB	EQU		06H				;Registro de configuracion de Puerta B
PB		EQU		06H				;Puerta B
STATUS	EQU		03H				;Registro para acceder a las posiciones del banco
VAR		EQU		10H				;Variable auxiliar utilizada como contador
						
;--------------------------------------------------------------
		ORG 	0				;El programa comienza en la direccion 0
		GOTO	INICIO			;Se redirigie a la etiqueta INICIO

INICIO	ORG		10				;La etiqueta INICIO	comienza en la direccion 10 da pie a la entrada de Datos y configuracion de registros
		BSF		STATUS,5		;Cambio al banco de memoria 1
		MOVLW	B'00000111'		;Muevo el valor de 00000111 a W
		MOVWF	OP				;Muevo el valor de W a OP
		CLRF	TRISA			;Se configura el puerto A como puerto de salida
		MOVLW	0xFF			;Muevo el valor de 0xFF HEX a W
		MOVFW	TRISB			;Muevo el valor de W a TRISB para configurarlo como puerto de entrada
		BCF		STATUS,5		;Cambio al banco de memoria 0

		BSF		PB,0			;Se configura el PIN0 del PB con el valor de 1
		BSF		PB,1			;Se configura el PIN1 del PB con el valor de 1
		BSF		PB,2			;Se configura el PIN2 del PB con el valor de 1
		BSF		PB,3			;Se configura el PIN3 del PB con el valor de 1

		BCF		PA,0			;Se configura el PIN0 del PA con el valor de 0
		BCF		PA,1			;Se configura el PIN1 del PA con el valor de 0
		
;--------------------------------------------------------------		
START	BTFSS	PB,0			;Se inicia la etiqueta START y se comprueba el PIN0 del PB, si es 1 salta una linea
		GOTO	BTN1			;Si el valor del PIN0 del PB es 0, el boton esta presionado y redirige a la etiqueta BTN1
		BTFSS	PB,1			;Se comprueba el PIN1 del PB, si es 1 salta una linea
		GOTO	BTN2			;Si el valor del PIN1 del PB es 0, el boton esta presionado y redirige a la etiqueta BTN2
		BTFSS	PB,2			;Se comprueba el PIN2 del PB, si es 1 salta una linea
		GOTO	BTN3			;Si el valor del PIN2 del PB es 0, el boton esta presionado y redirige a la etiqueta BTN3
		BTFSS	PB,3			;Se comprueba el PIN3 del PB, si es 1 salta una linea
		GOTO	BTN4			;Si el valor del PIN3 del PB es 0, el boton esta presionado y redirige a la etiqueta BTN4
		GOTO	START			;Redirige a la etiqueta START

BTN1	BSF		PA,0			;Enciende la Bomba 1 	| Etiqueta BTN1 da inicio a la rutina para el boton 1
		GOTO	BTN1			;Redirige a la etiqueta BTN1

BTN2	BSF		PA,1			;Enciende la Bomba 2	| Etiqueta BTN2 da inicio a la rutina para el boton 2
		GOTO	BTN2			;Redirige a la etiqueta BTN2

BTN3	ORG		90				;Se inicia la etiqueta BTN3 en la direccion 90 que da inicio a el boton 3
		MOVLW	B'10100000'		;Se carga el valor de B'10100000' a W
		MOVWF	INTCON			;Se mueve el valor de W a INTCON
		MOVLW	D'120'			;Se carga el valor de D'120' a W
		MOVWF	VAR				;Se mueve el valor de W a la variable VAR
		BSF		PA,0			;Se la Bomba 1
		MOVLW	D'12'			;Se carga el valor de D'12' a W
		MOVLW	TMR0			;Se mueve el valor de W a TMR0
BACK	NOP						;Se inicia la etiqueta BACK para gastar ciclos de reloj
		NOP						;NO OPERATION
		NOP						;NO OPERATION
		GOTO	BACK			;Redirije a la etiqueta BACK

BTN4	BSF		PA,0			;Enciende la Bomba 1	| Etiqueta 4 da inicio a la rutina para el boton 4
		BSF		PA,1			;Enciende la Bomba 2
		GOTO	BTN4			;Redirige a la etiqueta BTN4

;--------------------------------------------------------------		
		ORG		4				;Direccion del vector de interrupcion
		GOTO	INTER			;Redirige a la etiqueta INTER
	
INTER	ORG		100				;Se inicia la rutina de la interrumpcion en la direccion 100 que da inicio a las rutinas de interrupcion
		DECFSZ	VAR,1			;Decrementa el valor de la variable VAR, si es 0 salta una linea
		GOTO	SALIR			;Redirige a la etiqueta SALIR
		BTFSS	PA,0			;Explora un bit del PA0, si su valor es 1 salta una linea
		GOTO	GREEN			;Redirige a la etiqueta GREEN
		GOTO	YELLOW			;Redirige a la etiqueta YELLOW
		
YELLOW	BCF		PA,0			;Apaga la Bomba 1	| Etiqueta Yellow donde comienzan las instrucciones para que la bomba 2 este encendida 30s	
		BSF		PA,1			;Enciende la Bomba 2
		GOTO	PUS				;Redirige a la Etiqueta PUS
		
GREEN	BSF		PA,0			;Enciende la Bomba 1
		BCF		PA,1			;Apaga la Bomba 2

PUS		MOVLW	D'120'			;Se configura el valor de D'120' a W | Etiqueta PUS = Paso Un Segundo donde hace el conteo de los segundos necesarios
		MOVWF	VAR				;Se mueve el valor de W a VAR
SALIR	MOVLW	D'12'			;Se configura el valor de D'12' a W | Etiqueta SALIR donde realiza acciones necesarias para salir de la interrupcion
		MOVWF	TMR0			;Mueve el valor de W a TMR0
		BCF		INTCON,2		;Apago la bandera de INTCON en el bit 2
		RETFIE					;Vuelve a donde ocurrio la interrupcion

		END						;Fin del programa

