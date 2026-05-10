#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 1024

typedef enum {
    SYMBOL_VARIABLE,
    SYMBOL_PROCEDURE
} SymbolCategory;

typedef enum {
    TYPE_INTEGER,
    TYPE_REAL,
    TYPE_BOOLEAN,
    TYPE_NONE,
    TYPE_ERROR
} SymbolType;

typedef struct {
    char name[64];
    SymbolCategory category;
    SymbolType type;
    char scope[64];
} Symbol;

void init_symbol_table(void);

int insert_symbol(
    const char *name,
    SymbolCategory category,
    SymbolType type,
    const char *scope
);

Symbol *find_symbol(const char *name, const char *scope);

int symbol_exists_in_scope(const char *name, const char *scope);

void print_symbol_table(void);

const char *symbol_category_name(SymbolCategory category);
const char *symbol_type_name(SymbolType type);

#endif