build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/%.o: src/%.c
	cc -c -o $@ $<

build/util.o: src/util.h

ctags:
	ctags --c-kinds=+l --exclude=Makefile -R .
