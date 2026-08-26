# c07b-the-grammar

Companion repository for **c07b — The Grammar** at
[thecodingidiot.com](https://thecodingidiot.com), the second of four
parts making up the c07 — The Console arc.

---

## Follow my journey

Working through c07b alongside the implementation pages? Continue
from c07a — this repository does not stand alone; it starts from a
working c07a shell and adds a real lexer and parser to it.

```bash
git clone https://github.com/thecodingidiot-com/c07b-the-grammar.git c07b-practice
cd c07b-practice/solution
make -C libtci re
make re
bash ../test.sh
```

Copy `test_parser.c` alongside the built object files and run the
structural unit tests too:

```bash
gcc -Wall -Wextra -std=c99 -I libtci -c test_parser.c -o test_parser.o
gcc test_parser.o lexer.o parser.o libtci/libtci.a libtci/libtciutil.a -o test_parser
./test_parser
```

All tests must pass before the part is complete.

---

## Follow your journey

Building this independently? Here is the full brief.

Starting from a working shell that naively splits a line on whitespace
(no quote handling) and runs one external command via
`fork`/`execve`/`waitpid`, add:

- A **lexer** turning a raw line into tokens — words (quote- and
  escape-aware), pipes, all four redirection forms, `&&`/`||`, and
  parentheses.
- A **parser** building a tree from those tokens — a simple command
  node (`argv` + redirections), and binary nodes for pipes, `&&`/`||`,
  and subshells. The full grammar parses correctly even though only a
  single simple command actually executes at this stage.
- The two changes above should fix the shell's existing quoting bug
  (`echo "hi there"` must become one argument, not two) without
  regressing anything that already worked.

Source, one file per concern:

| File | Contents |
| --- | --- |
| `lexer.c` / `lexer.h` | raw line → token list |
| `parser.c` / `parser.h` | token list → tree (`t_node`) |
| `main.c` | lexes, parses, and executes each line |
| `exec.c` | runs a `t_node` — only `NODE_CMD` is real at this stage |
| `builtins.c` | `cd`, `pwd`, `exit` — unchanged from c07a |

Build and test your own version first. Use `solution/` to compare
once you are done, not before.

---

## Building the solution

```bash
cd solution
make -C libtci re
make re
```

```
$ echo "hi there"
hi there
$ a | b
c07shell: this checkpoint does not execute that yet
```

---

## What the tester checks

**Structural parser unit tests** (`test_parser.c`, built separately
from `main.c`/`exec.c` — pure lexer/parser logic, nothing forks or
executes) — a quoted argument, a word spliced across a quote boundary,
a 3-stage pipe chain, all four redirection token types, `&&`/`||`
associativity, a subshell group, and an unterminated quote.

**A bash-comparison regression suite** (`test.sh`) — every case from
c07a (single external commands, `cd`/`pwd`/`exit`, a nonexistent
command), re-run through the real lexer and parser instead of naive
splitting, still diffed against real bash output.

---

## License

MIT License. See [LICENSE](LICENSE).
