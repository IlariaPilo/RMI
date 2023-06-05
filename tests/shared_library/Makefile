CC = g++
CFLAGS = -Wall -Wextra -pedantic -std=c++11


# The target executable
TARGET = main

# Source files
SRCS = main.cpp ../../wrapper/rmi.cpp

# Object files
OBJS = $(SRCS:.cpp=.o)

# Build rule for the target executable
# main: main.o wrapper/rmi.o
#	g++ -Wall -Wextra -pedantic -std=c++11 -o main main.o wrapper/rmi.o
$(TARGET): $(OBJS)								
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)			

# Build rule for object files
main.o: main.cpp ./rmi_1/rmi_1.so ./rmi_2/rmi_2.so
	$(CC) $(CFLAGS) -c main.cpp -o main.o -ldl

../../wrapper/rmi.o: ../../wrapper/rmi.cpp
	$(CC) $(CFLAGS) -c $< -o $@

./rmi_1/rmi_1.so: ./rmi_1/rmi.cpp
	cd rmi_1 && make && cd ..

./rmi_2/rmi_2.so: ./rmi_2/rmi.cpp
	cd rmi_2 && make && cd ..

./rmi_1/rmi.cpp: ../rmi
	mkdir -p rmi_1
	cp ../../Makefile ./rmi_1/.
	cd rmi_1 && ../../rmi ../../osm_cellids_200M_uint64 rmi robust_linear,linear 262144 && cd ..

./rmi_2/rmi.cpp: ../rmi
	mkdir -p rmi_2 
	cp ../../Makefile ./rmi_2/.
	cd rmi_2 && ../../rmi ../../osm_cellids_200M_uint64 rmi linear_spline,linear 262144 && cd ..

clean:
	rm -f $(TARGET) $(OBJS)
	rm -fr rmi_1
	rm -fr rmi_2

.PHONY: clean
