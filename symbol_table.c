#include <stdio.h>
#include <string.h>
#include "symbol_table.h"

static Symbol symbols[MAX_SYMBOLS];
static int symbol_count = 0;

void init_symbol_table(void) {
    symbol_count = 0;
}

const char *symbol_category_name(SymbolCategory category) {
    switch (category) {
        case SYMBOL_VARIABLE:
            return "variavel";
        case SYMBOL_PROCEDURE:
            return "procedure";
        default:
            return "desconhecido";
    }
}

const char *symbol_type_name(SymbolType type) {
    switch (type) {
        case TYPE_INTEGER:
            return "integer";
        case TYPE_REAL:
            return "real";
        case TYPE_BOOLEAN:
            return "boolean";
        case TYPE_NONE:
            return "none";
        case TYPE_ERROR:
            return "error";
        default:
            return "desconhecido";
    }
}

int symbol_exists_in_scope(const char *name, const char *scope) {
    for (int i = 0; i < symbol_count; i++) {
        if (
            strcmp(symbols[i].name, name) == 0 &&
            strcmp(symbols[i].scope, scope) == 0
        ) {
            return 1;
        }
    }

    return 0;
}

int insert_symbol(
    const char *name,
    SymbolCategory category,
    SymbolType type,
    const char *scope
) {
    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "[ERRO SEMÂNTICO] Tabela de símbolos cheia.\n");
        return 0;
    }

    if (symbol_exists_in_scope(name, scope)) {
        fprintf(stderr,
            "[ERRO SEMÂNTICO] Identificador '%s' já declarado no escopo '%s'.\n",
            name,
            scope
        );
        return 0;
    }

    Symbol *symbol = &symbols[symbol_count++];

    strncpy(symbol->name, name, sizeof(symbol->name) - 1);
    symbol->name[sizeof(symbol->name) - 1] = '\0';

    symbol->category = category;
    symbol->type = type;

    strncpy(symbol->scope, scope, sizeof(symbol->scope) - 1);
    symbol->scope[sizeof(symbol->scope) - 1] = '\0';

    return 1;
}

Symbol *find_symbol(const char *name, const char *scope) {
    for (int i = 0; i < symbol_count; i++) {
        if (
            strcmp(symbols[i].name, name) == 0 &&
            strcmp(symbols[i].scope, scope) == 0
        ) {
            return &symbols[i];
        }
    }

    if (strcmp(scope, "global") != 0) {
        for (int i = 0; i < symbol_count; i++) {
            if (
                strcmp(symbols[i].name, name) == 0 &&
                strcmp(symbols[i].scope, "global") == 0
            ) {
                return &symbols[i];
            }
        }
    }

    return NULL;
}

void print_symbol_table(void) {
    printf("\nTABELA DE SÍMBOLOS\n");
    printf("------------------------------------------------------------\n");
    printf("%-6s %-15s %-12s %-10s %-10s\n",
           "Index", "Nome", "Categoria", "Tipo", "Escopo");
    printf("------------------------------------------------------------\n");

    for (int i = 0; i < symbol_count; i++) {
        printf("%-6d %-15s %-12s %-10s %-10s\n",
               i,
               symbols[i].name,
               symbol_category_name(symbols[i].category),
               symbol_type_name(symbols[i].type),
               symbols[i].scope);
    }

    printf("------------------------------------------------------------\n");
}