// main.cpp
#include <iostream>
#include "../../wrapper/rmi.h"

int main(int argc, char** argv) {
    if (argc == 1) {
        std::cout << "*panic* AAAA! *commits sudoku*" << std::endl;
        exit(1);
    }
    const char* path_to_library = argv[1];
    RMI rmi;
    rmi.init(path_to_library);
    return 0;
}
