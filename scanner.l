%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"
#include "tokens.h"

#define MAX_TOKENS 4096

static TokenEntry token_table[MAX_TOKENS];
static int token_count = 0;

static int cur_line = 1;
static int cur_col = 1;

static void record(int tok);
void print_token_table(void);
%}

%option noyywrap
%option nounput
%option noinput

LETTER      [a-zA-Z]
DIGIT       [0-9]
DIGITS      {DIGIT}+
ID          {LETTER}({LETTER}|{DIGIT})*
NUM         {DIGITS}(\.{DIGITS})?([eE][+-]?{DIGITS})?
WHITESPACE  [ \t\r]+

%%

\{[^}]*\} {
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\n') {
            cur_line++;
            cur_col = 1;
        } else {
            cur_col++;
        }
    }
}

\n {
    cur_line++;
    cur_col = 1;
}

{WHITESPACE} {
    cur_col += yyleng;
}

[Pp][Rr][Oo][Gg][Rr][Aa][Mm] {
    record(TOK_PROGRAM);
    return TOK_PROGRAM;
}

[Vv][Aa][Rr] {
    record(TOK_VAR);
    return TOK_VAR;
}

[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee] {
    record(TOK_PROCEDURE);
    return TOK_PROCEDURE;
}

[Bb][Ee][Gg][Ii][Nn] {
    record(TOK_BEGIN);
    return TOK_BEGIN;
}

[Ee][Nn][Dd] {
    record(TOK_END);
    return TOK_END;
}

[Ii][Ff] {
    record(TOK_IF);
    return TOK_IF;
}

[Tt][Hh][Ee][Nn] {
    record(TOK_THEN);
    return TOK_THEN;
}

[Ee][Ll][Ss][Ee] {
    record(TOK_ELSE);
    return TOK_ELSE;
}

[Ww][Hh][Ii][Ll][Ee] {
    record(TOK_WHILE);
    return TOK_WHILE;
}

[Dd][Oo] {
    record(TOK_DO);
    return TOK_DO;
}

[Nn][Oo][Tt] {
    record(TOK_NOT);
    return TOK_NOT;
}

[Ii][Nn][Tt][Ee][Gg][Ee][Rr] {
    record(TOK_INTEGER);
    return TOK_INTEGER;
}

[Rr][Ee][Aa][Ll] {
    record(TOK_REAL);
    return TOK_REAL;
}

[Oo][Rr] {
    record(TOK_OR);
    return TOK_OR;
}

[Dd][Ii][Vv] {
    record(TOK_DIV);
    return TOK_DIV;
}

[Mm][Oo][Dd] {
    record(TOK_MOD);
    return TOK_MOD;
}

[Aa][Nn][Dd] {
    record(TOK_AND);
    return TOK_AND;
}

{NUM} {
    record(TOK_NUM);
    yylval.str = strdup(yytext);
    return TOK_NUM;
}

{ID} {
    record(TOK_ID);
    yylval.str = strdup(yytext);
    return TOK_ID;
}

">=" {
    record(TOK_GE);
    return TOK_GE;
}

"<=" {
    record(TOK_LE);
    return TOK_LE;
}

"<>" {
    record(TOK_NE);
    return TOK_NE;
}

"=" {
    record(TOK_EQ);
    return TOK_EQ;
}

">" {
    record(TOK_GT);
    return TOK_GT;
}

"<" {
    record(TOK_LT);
    return TOK_LT;
}

":=" {
    record(TOK_ASSIGN);
    return TOK_ASSIGN;
}

"+" {
    record(TOK_PLUS);
    return TOK_PLUS;
}

"-" {
    record(TOK_MINUS);
    return TOK_MINUS;
}

"*" {
    record(TOK_STAR);
    return TOK_STAR;
}

"/" {
    record(TOK_SLASH);
    return TOK_SLASH;
}

"(" {
    record(TOK_LPAREN);
    return TOK_LPAREN;
}

")" {
    record(TOK_RPAREN);
    return TOK_RPAREN;
}

";" {
    record(TOK_SEMI);
    return TOK_SEMI;
}

":" {
    record(TOK_COLON);
    return TOK_COLON;
}

"," {
    record(TOK_COMMA);
    return TOK_COMMA;
}

"." {
    record(TOK_DOT);
    return TOK_DOT;
}

<<EOF>> {
    record(0);
    print_token_table();
    return 0;
}

. {
    fprintf(stderr,
        "[ERRO LÉXICO] Linha %d, Coluna %d: caractere inesperado '%s'\n",
        cur_line,
        cur_col,
        yytext
    );

    record(TOK_UNKNOWN);
    return TOK_UNKNOWN;
}

%%

static void record(int tok) {
    if (token_count >= MAX_TOKENS) {
        fprintf(stderr, "ERRO: tabela de tokens cheia.\n");
        exit(1);
    }

    TokenEntry *entry = &token_table[token_count++];

    entry->token = tok;
    entry->line = cur_line;
    entry->column = cur_col;

    strncpy(entry->lexeme, yytext, sizeof(entry->lexeme) - 1);
    entry->lexeme[sizeof(entry->lexeme) - 1] = '\0';

    cur_col += yyleng;
}

void print_token_table(void) {
    printf("\nTABELA DE TOKENS\n");
    printf("------------------------------------------------------------\n");
    printf("%-6s %-12s %-8s %-8s %-20s\n",
           "Index", "Token", "Linha", "Coluna", "Lexema");
    printf("------------------------------------------------------------\n");

    for (int i = 0; i < token_count; i++) {
        TokenEntry *entry = &token_table[i];

        printf("%-6d %-12s %-8d %-8d %-20s\n",
               i,
               token_name(entry->token),
               entry->line,
               entry->column,
               entry->token == 0 ? "<EOF>" : entry->lexeme);
    }

    printf("------------------------------------------------------------\n");
    printf("Total: %d token(s)\n", token_count);
}