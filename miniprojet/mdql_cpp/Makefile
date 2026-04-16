# Compilation
mdql: lex.yy.c mdql.tab.c ast.h
	g++ lex.yy.c mdql.tab.c -o mdql -std=c++17

# Generer le code C depuis Bison
mdql.tab.c mdql.tab.h: mdql.y
	bison -d mdql.y

# Generer le code C depuis Flex
lex.yy.c: mdql.l mdql.tab.h
	flex mdql.l

clean:
	rm -f lex.yy.c mdql.tab.c mdql.tab.h mdql
