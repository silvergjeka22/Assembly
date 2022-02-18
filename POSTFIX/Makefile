all:bin/postfix

bin/postfix: obj/postfix.o obj/main.o
	gcc -m32 obj/main.o obj/postfix.o -o bin/postfix

obj/postfix.o:src/postfix.s
	gcc -m32 -c src/postfix.s -o obj/postfix.o

obj/main.o:src/main.c	
	gcc -m32 -c src/main.c -o obj/main.o

clean:
	rm -rf obj/*
	rm -rf bin/*
