build/exe: build/main.o build/util.o
	cc -o build/exe build/main.o build/util.o

build/%.o: src/%.c src/util.h
	cc -c -o $@ $<

build/util.o: src/util.h

include uservars.mk
