# ----------- thanks @ fbartolic for this template ----------- #
# Generates a .so library from the data

CC = g++ # define the C/C++ compiler to use
CFLAGS = -std=c++17 -O3 -Wall -Wall -Wextra -pedantic -fPIC
# define any directories containing header files other than /usr/include
INCLUDES = -I$(shell pwd)
# define the C++ source files
SRCS = rmi.cpp 
# define the C/C++ object files 
# This uses Suffix Replacement within a macro:
#   $(name:string1=string2)
#         For each word in 'name' replace 'string1' with 'string2'
OBJS = $(SRCS:.c=.o)
# define the shared library name
TARGET = $(notdir $(shell pwd)).so		# rmi_hg37.so
# define the symbols file name
NAMES = $(notdir $(shell pwd)).sym		# rmi_hg37.sym

.PHONY: clean
    
all: $(NAMES)
	@echo  Successfully compiled a .so library.

$(NAMES): $(TARGET)
	@touch $(NAMES)
	@nm -gD $(TARGET) | grep -oh "\w*load\w*" >> $(NAMES)
	@nm -gD $(TARGET) | grep -oh "\w*lookup\w*" >> $(NAMES)
	@nm -gD $(TARGET) | grep -oh "\w*cleanup\w*" >> $(NAMES)
	@echo "Symbols loaded!"

# compile object file to .so shared library
$(TARGET): $(OBJS)
	@echo $(TARGET)
	@echo $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -shared -o $(TARGET) $(OBJS) 

# compile source files to object files

# this is a suffix replacement rule for building .o's from .c's
# it uses automatic variables $<: the name of the prerequisite of
# the rule(a .c file) and $@: the name of the target of the rule (a .o file) 
# (see the gnu make manual section about automatic variables)
.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -cpp $<  -o $@
clean:
	$(RM) *.o 