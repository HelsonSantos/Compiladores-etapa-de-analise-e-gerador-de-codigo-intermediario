# Compilador para um Subconjunto de Pascal

Projeto desenvolvido para a disciplina de Compiladores com o objetivo de implementar um compilador para um subconjunto da linguagem Pascal utilizando **Flex**, **Bison** e **linguagem C**.

## Objetivo

O projeto tem como finalidade aplicar os principais conceitos estudados na disciplina, incluindo:

- Análise Léxica
- Análise Sintática
- Análise Semântica
- Tabela de Símbolos
- Geração de Código Intermediário

---

# Estrutura do Projeto

```txt id="ks3z7s"
tokens.h
scanner.l
parser.y
symbol_table.h
symbol_table.c
exemplo.pas
```

| Arquivo             | Descrição                                                   |
| ------------------- | ----------------------------------------------------------- |
| `scanner.l`         | Implementação do analisador léxico com Flex                 |
| `parser.y`          | Implementação do analisador sintático e semântico com Bison |
| `tokens.h`          | Definição e identificação dos tokens                        |
| `symbol_table.h/.c` | Implementação da tabela de símbolos                         |
| `exemplo.pas`       | Programa de teste em Pascal                                 |

---

# Pré-requisitos

Para compilar e executar o projeto é necessário possuir:

- GCC
- Flex
- Bison

---

# Instalação das Dependências

## Linux (Fedora)

```bash id="rmjgw7"
sudo dnf install gcc flex bison
```

Opcionalmente:

```bash id="vtwtc7"
sudo dnf install make
```

---

## Linux (Ubuntu/Debian)

```bash id="o35x8r"
sudo apt update
sudo apt install gcc flex bison
```

Opcionalmente:

```bash id="9a18t6"
sudo apt install make
```

---

## Arch Linux

```bash id="2jg14k"
sudo pacman -S gcc flex bison
```

---

## Windows (WSL)

### Instalação do WSL

Abra o PowerShell como administrador e execute:

```powershell id="8ttq74"
wsl --install
```

Após a instalação:

- reinicie o computador;
- abra novamente o PowerShell;
- execute:

```powershell id="s3f5x7"
wsl
```

Isso abrirá o terminal Linux do WSL.

---

### Instalar dependências no Ubuntu (WSL)

Dentro do terminal WSL execute:

```bash id="5ry4tb"
sudo apt update
sudo apt install gcc flex bison
```

Opcionalmente:

```bash id="6ezqte"
sudo apt install make
```

---

# Funcionalidades Implementadas

## 1. Análise Léxica

O analisador léxico é responsável por transformar o código-fonte em tokens reconhecíveis pela linguagem.

### Tokens reconhecidos

- Palavras reservadas:
  - `program`
  - `var`
  - `procedure`
  - `begin`
  - `end`
  - `if`
  - `then`
  - `else`
  - `while`
  - `do`

- Identificadores

- Números inteiros e reais

- Operadores relacionais

- Operadores aritméticos

- Delimitadores

Além disso, o scanner:

- ignora comentários;
- controla linha e coluna;
- gera uma tabela de tokens.

---

## 2. Análise Sintática

A análise sintática foi implementada com Bison utilizando a gramática do subconjunto de Pascal fornecida na atividade.

O parser reconhece:

- declarações de variáveis;
- procedures;
- atribuições;
- estruturas `if/then/else`;
- estruturas `while/do`;
- expressões aritméticas e relacionais;
- blocos `begin/end`.

---

## 3. Análise Semântica

A etapa semântica implementa:

- tabela de símbolos;
- controle de escopo;
- verificação de redeclaração;
- verificação de identificadores não declarados;
- verificação de compatibilidade de tipos.

### Escopos suportados

- Escopo global
- Escopo local de procedures

---

# Exemplo de Saída

## Tabela de Símbolos

```txt id="g7fqf4"
Nome      Categoria   Tipo      Escopo
-----------------------------------------
x         variavel    integer   global
y         variavel    integer   global
z         variavel    real      global
teste     procedure   none      global
a         variavel    integer   teste
```

---

# Compilação

## Gerar o parser e scanner

```bash id="4jlwmx"
bison -d -o parser.c parser.y
flex -o scanner.c scanner.l
gcc -o parser parser.c scanner.c symbol_table.c
```

---

# Execução

```bash id="lr7kkw"
./parser < exemplo.pas
```

---

# Tecnologias Utilizadas

- C
- Flex
- Bison
- GCC

---

# Conceitos Aplicados

Durante o desenvolvimento foram aplicados conceitos fundamentais de compiladores, como:

- Expressões regulares
- Gramáticas livres de contexto
- Parsers LR
- Tokens
- Tabela de símbolos
- Escopo
- Verificação de tipos
- Estruturas sintáticas
- Análise semântica

---

# Autor

Helson Gonçalves dos Santos Filho && Joana Beatriz Silva Brandão
Projeto desenvolvido para fins acadêmicos na disciplina de Compiladores.
