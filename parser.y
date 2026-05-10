%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol_table.h"

int yylex(void);
void yyerror(const char *s);

static char current_scope[64] = "global";

#define MAX_PENDING_IDS 128

static char pending_ids[MAX_PENDING_IDS][64];
static int pending_id_count = 0;

static void add_pending_id(const char *name);
static void insert_pending_ids(SymbolType type);
static SymbolType check_identifier(const char *name);
static int is_numeric(SymbolType type);
static SymbolType numeric_result(SymbolType left, SymbolType right);
static void check_assignment(const char *name, SymbolType expr_type);
static void check_condition(SymbolType expr_type);
%}

%union {
    char *str;
    int type;
}

%token TOK_PROGRAM TOK_VAR TOK_PROCEDURE
%token TOK_BEGIN TOK_END
%token TOK_IF TOK_THEN TOK_ELSE
%token TOK_WHILE TOK_DO
%token TOK_NOT
%token TOK_INTEGER TOK_REAL

%token TOK_PLUS TOK_MINUS TOK_OR
%token TOK_STAR TOK_SLASH TOK_DIV TOK_MOD TOK_AND

%token TOK_EQ TOK_GT TOK_LT TOK_GE TOK_LE TOK_NE
%token TOK_ASSIGN

%token TOK_LPAREN TOK_RPAREN
%token TOK_SEMI TOK_COLON TOK_COMMA TOK_DOT

%token <str> TOK_ID
%token <str> TOK_NUM

%type <type> type
%type <type> expression
%type <type> simple_expression
%type <type> term
%type <type> factor

%%

program:
    header declarations block TOK_DOT
    {
        printf("\nAnálise sintática concluída com sucesso!\n");
        printf("Análise semântica concluída.\n");
        print_symbol_table();
    }
;

header:
    TOK_PROGRAM TOK_ID TOK_SEMI
    {
        insert_symbol($2, SYMBOL_PROCEDURE, TYPE_NONE, "global");
        free($2);
    }
;

declarations:
    variable_declaration_section procedure_declarations
;

variable_declaration_section:
    TOK_VAR variable_declarations
    |
;

variable_declarations:
    variable_declarations variable_declaration
    | variable_declaration
;

variable_declaration:
    identifier_list TOK_COLON type TOK_SEMI
    {
        insert_pending_ids($3);
    }
;

identifier_list:
    identifier_list TOK_COMMA TOK_ID
    {
        add_pending_id($3);
        free($3);
    }
    | TOK_ID
    {
        add_pending_id($1);
        free($1);
    }
;

type:
    TOK_INTEGER
    {
        $$ = TYPE_INTEGER;
    }
    | TOK_REAL
    {
        $$ = TYPE_REAL;
    }
;

procedure_declarations:
    procedure_declarations procedure_declaration
    |
;

procedure_declaration:
    procedure_header declarations block TOK_SEMI
    {
        strcpy(current_scope, "global");
    }
;

procedure_header:
    TOK_PROCEDURE TOK_ID TOK_SEMI
    {
        insert_symbol($2, SYMBOL_PROCEDURE, TYPE_NONE, "global");
        strncpy(current_scope, $2, sizeof(current_scope) - 1);
        current_scope[sizeof(current_scope) - 1] = '\0';
        free($2);
    }
;

block:
    TOK_BEGIN statements TOK_END
;

statements:
    statements TOK_SEMI statement
    | statement
;

statement:
    TOK_ID TOK_ASSIGN expression
    {
        check_assignment($1, $3);
        free($1);
    }
    | TOK_ID TOK_LPAREN TOK_RPAREN
    {
        Symbol *symbol = find_symbol($1, current_scope);

        if (!symbol) {
            fprintf(stderr,
                "[ERRO SEMÂNTICO] Procedure '%s' não declarada.\n",
                $1
            );
        } else if (symbol->category != SYMBOL_PROCEDURE) {
            fprintf(stderr,
                "[ERRO SEMÂNTICO] Identificador '%s' não é uma procedure.\n",
                $1
            );
        }

        free($1);
    }
    | block
    | TOK_IF expression TOK_THEN statement else_clause
    {
        check_condition($2);
    }
    | TOK_WHILE expression TOK_DO statement
    {
        check_condition($2);
    }
    |
;

else_clause:
    TOK_ELSE statement
    |
;

expression:
    simple_expression relop simple_expression
    {
        if (!is_numeric($1) || !is_numeric($3)) {
            fprintf(stderr,
                "[ERRO SEMÂNTICO] Operação relacional exige operandos numéricos.\n"
            );
            $$ = TYPE_ERROR;
        } else {
            $$ = TYPE_BOOLEAN;
        }
    }
    | simple_expression
    {
        $$ = $1;
    }
;

simple_expression:
    simple_expression addop term
    {
        $$ = numeric_result($1, $3);
    }
    | addop term
    {
        $$ = $2;
    }
    | term
    {
        $$ = $1;
    }
;

term:
    term mulop factor
    {
        $$ = numeric_result($1, $3);
    }
    | factor
    {
        $$ = $1;
    }
;

factor:
    TOK_ID
    {
        $$ = check_identifier($1);
        free($1);
    }
    | TOK_NUM
    {
        if (strchr($1, '.') != NULL || strchr($1, 'e') != NULL || strchr($1, 'E') != NULL) {
            $$ = TYPE_REAL;
        } else {
            $$ = TYPE_INTEGER;
        }

        free($1);
    }
    | TOK_LPAREN expression TOK_RPAREN
    {
        $$ = $2;
    }
    | TOK_NOT factor
    {
        if ($2 != TYPE_BOOLEAN) {
            fprintf(stderr,
                "[ERRO SEMÂNTICO] Operador NOT exige expressão booleana.\n"
            );
            $$ = TYPE_ERROR;
        } else {
            $$ = TYPE_BOOLEAN;
        }
    }
;

relop:
    TOK_EQ
    | TOK_GT
    | TOK_LT
    | TOK_GE
    | TOK_LE
    | TOK_NE
;

addop:
    TOK_PLUS
    | TOK_MINUS
    | TOK_OR
;

mulop:
    TOK_STAR
    | TOK_SLASH
    | TOK_DIV
    | TOK_MOD
    | TOK_AND
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "\nErro sintático: %s\n", s);
}

static void add_pending_id(const char *name) {
    if (pending_id_count >= MAX_PENDING_IDS) {
        fprintf(stderr, "[ERRO SEMÂNTICO] Lista de identificadores cheia.\n");
        return;
    }

    strncpy(pending_ids[pending_id_count], name, 63);
    pending_ids[pending_id_count][63] = '\0';
    pending_id_count++;
}

static void insert_pending_ids(SymbolType type) {
    for (int i = 0; i < pending_id_count; i++) {
        insert_symbol(
            pending_ids[i],
            SYMBOL_VARIABLE,
            type,
            current_scope
        );
    }

    pending_id_count = 0;
}

static SymbolType check_identifier(const char *name) {
    Symbol *symbol = find_symbol(name, current_scope);

    if (!symbol) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Identificador '%s' não declarado no escopo '%s'.\n",
            name,
            current_scope
        );

        return TYPE_ERROR;
    }

    if (symbol->category != SYMBOL_VARIABLE) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Identificador '%s' não é uma variável.\n",
            name
        );

        return TYPE_ERROR;
    }

    return symbol->type;
}

static int is_numeric(SymbolType type) {
    return type == TYPE_INTEGER || type == TYPE_REAL;
}

static SymbolType numeric_result(SymbolType left, SymbolType right) {
    if (!is_numeric(left) || !is_numeric(right)) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Operação aritmética exige operandos numéricos.\n"
        );

        return TYPE_ERROR;
    }

    if (left == TYPE_REAL || right == TYPE_REAL) {
        return TYPE_REAL;
    }

    return TYPE_INTEGER;
}

static void check_assignment(const char *name, SymbolType expr_type) {
    Symbol *symbol = find_symbol(name, current_scope);

    if (!symbol) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Variável '%s' não declarada no escopo '%s'.\n",
            name,
            current_scope
        );
        return;
    }

    if (symbol->category != SYMBOL_VARIABLE) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] '%s' não é uma variável.\n",
            name
        );
        return;
    }

    if (symbol->type == TYPE_INTEGER && expr_type == TYPE_REAL) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Não é possível atribuir real à variável integer '%s'.\n",
            name
        );
    }
}

static void check_condition(SymbolType expr_type) {
    if (expr_type != TYPE_BOOLEAN) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Condição de IF/WHILE deve ser expressão relacional/booleana.\n"
        );
    }
}

int main(void) {
    init_symbol_table();

    printf("Analisador Sintático/Semântico - Subconjunto de Pascal\n");
    printf("-----------------------------------------------------\n");

    yyparse();

    return 0;
}