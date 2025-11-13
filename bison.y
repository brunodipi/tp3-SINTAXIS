%{
#include <stdio.h>
#include <stdlib.h> 
#include <math.h>
#include <string.h>
extern char *yytext;
extern int yyleng;
extern int yylex(void);
extern void yyerror(char*);

extern int yylinea;

//Rutina semantica 1: Tabla de simbolos

typedef struct {
	char nombre[33]; //max 32 caracteres
} Simbolo;

#define TAM_MAX_TABLA 100
Simbolo tablaDeSimbolos[TAM_MAX_TABLA]; //esta bien poner cantidad fija?
int tamañoTS = 0;

int buscarSimbolo(char* simb){
	for (int i = 0; i < tamañoTS; i++){
		if(strcmp(tablaDeSimbolos[i].nombre, simb)== 0){
			return 1;
		}
	}
	return 0;
}

void insertarSimbolo(char* simb){
	if(!buscarSimbolo(simb)){ //si no esta ya en la tabla
		if(tamañoTS < TAM_MAX_TABLA){
			strncpy(tablaDeSimbolos[tamañoTS].nombre, simb, 32);
			tablaDeSimbolos[tamañoTS].nombre[32] = '\0';
			tamañoTS++;
		} 
	}
}
	
void mostrarTS() {
    printf("TABLA DE SIMBOLOS\n");
    for (int i = 0; i < tamañoTS; i++) {
        printf("ID: %s\n", tablaDeSimbolos[i].nombre);
    }
    printf("\n");
}		


%}

%union{
   char* cadena;
   int num;
} 

%token ASIGNACION PYCOMA SUMA RESTA PARENIZQUIERDO PARENDERECHO COMA
%token <cadena> ID
%token <num> CONSTANTE

%token INICIO FIN LEER ESCRIBIR // palabras reservadas de micro

%%
// Estructura sintactica
programa: INICIO sentencias FIN {
    printf("\nAnalisis Sintactico Completo!!!\n");
    mostrarTS(); 
}
;

sentencias: sentencias sentencia 
|sentencia
;

sentencia: sentencia_asignacion | sentencia_entrada
;

sentencia_asignacion: ID {
	printf("el id es: %s de longitud: %d ",yytext,yyleng);
	if(yyleng>32) yyerror("el identificador es muy largo");
	//Rutina semantica 2: Verificar que este declarado ???
	if(!buscarSimbolo($1)){
		insertarSimbolo($1);
		printf(" '%s' Declarado implicitamente \n", $1);
	}
	
} 
ASIGNACION expresion PYCOMA
;

sentencia_entrada: LEER PARENIZQUIERDO lista_id PARENDERECHO PYCOMA // sintaxis de LEER
| ESCRIBIR PARENIZQUIERDO lista_expresiones PARENDERECHO PYCOMA
;

lista_id: ID {
    if (!buscarSimbolo($1)) {
        insertarSimbolo($1); // Rutina Semántica: Registra el ID en la TS
        printf("Semantica: ID '%s' registrado por LEER.\n", $1);
    }
}
| lista_id COMA ID {
    if (!buscarSimbolo($3)) {
        insertarSimbolo($3); // Rutina Semántica: Registra el siguiente ID
        printf("Semantica: ID '%s' registrado por LEER.\n", $3);
    }
}
;

lista_expresiones: expresion
| lista_expresiones COMA expresion
;

expresion: primaria | expresion operadorAditivo primaria 
; 

primaria: ID {
	//Rutina semantica: Verificar ID en expresion
	if(!buscarSimbolo($1)) {
		char buffer[256];
		sprintf(buffer, "Error semantico: Uso de ID ('%s') no declarado", $1);
		yyerror(buffer);
		//yyerror("Error semantico: Uso de ID ('%s') no declarado", $1);
	}
}
|CONSTANTE {printf("valores %d ",$1); }
|PARENIZQUIERDO expresion PARENDERECHO
;

operadorAditivo: SUMA 
| RESTA
;

%%

int main(int argc, char *argv[]) {
	printf("Iniciando analisis de programa Micro!\n");

	if (argc > 1) {
        extern FILE *yyin; // Declara la variable de entrada de Flex
        
        if (!(yyin = fopen(argv[1], "r"))) {
            fprintf(stderr, "ERROR: No se pudo abrir el archivo de entrada: %s\n", argv[1]);
            return 1; 
        }
    } else {
        printf("Leyendo desde la entrada estandar (stdin)....\n");
    }

	yyparse();
	return 0;
}

void yyerror (char *s){
	fprintf (stderr, "\n --- ERROR (Linea %d): %s --- \n", yylinea, s);
}

int yywrap(void) { 
	return 1; 
}