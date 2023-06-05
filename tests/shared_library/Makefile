CC = g++
CFLAGS = -Wall -Wextra -pedantic -std=c++11

#LIBRARY_PATH = path/to/library.so

all: main

main: main.cpp
	$(CC) $(CFLAGS) -o main main.cpp -ldl

run:
	./main

clean:
	rm -f main

.PHONY: all run clean
