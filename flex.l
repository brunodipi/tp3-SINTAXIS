%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "bison.tab.h"

	//arrancan agregados
	#include <string.h>
	#define MAX_TAM_ID 32
	extern int yyleng;
	int yylinea = 1;

%}
DIGITO [0-9]

LETRA [a-zA-Z]

IDENTIFICADOR {LETRA}({LETRA}|{DIGITO})*

constEntera {DIGITO}({DIGITO})*

SEPARADOR [ \t\n]

%%
":=" {return ASIGNACION;}
";" {return PYCOMA;}
"(" {return PARENIZQUIERDO;}
")" {return PARENDERECHO;}
"+" {return SUMA;}
"-" {return RESTA;}
"," {return COMA;} // la usa dentro de los leer y escribir
"inicio" {return INICIO; printf("Detecto palabra reservada "inicio"\n");}
"fin" {return FIN; printf("Detecto palabra reservada "fin"\n");}
"leer" {return LEER; printf("Detecto palabra reservada "leer"\n");}
"escribir" {return ESCRIBIR; printf("Detecto palabra reservada "escribir"\n");}

{constEntera} {
	yylval.num=atoi(yytext);
	return CONSTANTE;
}

{IDENTIFICADOR} {
	if(yyleng > MAX_TAM_ID) {
		fprintf(stderr, "Error Lexico en linea %d - Identificador '%s' demasiado largo\n", yylinea, yytext); /* reportar error*/
	}
	yylval.cadena = strdup(yytext);
	return ID;
}

{SEPARADOR} {/* omitir */}


. {   /*Carácter no reconocido*/
    fprintf(stderr, "Error Lexico en linea %d: Caracter no reconocido '%s'.\n", yylinea, yytext);
}

%%