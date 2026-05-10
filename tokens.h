#ifndef TOKENS_H
#define TOKENS_H

#define TOK_UNKNOWN 999

typedef struct {
    int  token;
    char lexeme[256];
    int  line;
    int  column;
} TokenEntry;

static const char *token_name(int tok) {
    switch (tok) {
        case TOK_PROGRAM:   return "PROGRAM";
        case TOK_VAR:       return "VAR";
        case TOK_PROCEDURE: return "PROCEDURE";
        case TOK_BEGIN:     return "BEGIN";
        case TOK_END:       return "END";
        case TOK_IF:        return "IF";
        case TOK_THEN:      return "THEN";
        case TOK_ELSE:      return "ELSE";
        case TOK_WHILE:     return "WHILE";
        case TOK_DO:        return "DO";
        case TOK_NOT:       return "NOT";
        case TOK_INTEGER:   return "INTEGER";
        case TOK_REAL:      return "REAL";

        case TOK_PLUS:      return "PLUS";
        case TOK_MINUS:     return "MINUS";
        case TOK_OR:        return "OR";

        case TOK_STAR:      return "STAR";
        case TOK_SLASH:     return "SLASH";
        case TOK_DIV:       return "DIV";
        case TOK_MOD:       return "MOD";
        case TOK_AND:       return "AND";

        case TOK_EQ:        return "EQ";
        case TOK_GT:        return "GT";
        case TOK_LT:        return "LT";
        case TOK_GE:        return "GE";
        case TOK_LE:        return "LE";
        case TOK_NE:        return "NE";

        case TOK_ASSIGN:    return "ASSIGN";

        case TOK_LPAREN:    return "LPAREN";
        case TOK_RPAREN:    return "RPAREN";
        case TOK_SEMI:      return "SEMI";
        case TOK_COLON:     return "COLON";
        case TOK_COMMA:     return "COMMA";
        case TOK_DOT:       return "DOT";

        case TOK_ID:        return "ID";
        case TOK_NUM:       return "NUM";

        case 0:             return "EOF";
        case TOK_UNKNOWN:   return "UNKNOWN";
        default:            return "UNKNOWN";
    }
}

#endif