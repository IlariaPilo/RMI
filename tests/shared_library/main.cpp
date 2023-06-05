// main.cpp
#include <iostream>
#include <fstream>
#include <string>
#include <dlfcn.h> // for Linux
// #include <windows.h> // for Windows
#include "rmi.h"

#define DEBUG 0

typedef bool (*load_type)(char const*);
typedef uint64_t (*lookup_type)(uint64_t, size_t*);
typedef void (*cleanup_type)();

void* library_handle;
load_type rmi_load;
lookup_type rmi_lookup;
cleanup_type rmi_cleanup;

int load_library(const char* library_prefix) {
    std::string library_name = std::string(library_prefix) + ".so";
    std::string library_sym = std::string(library_prefix) + ".sym";
    #if DEBUG
        std::cout << library_prefix << std::endl;
        std::cout << library_name << std::endl;
        std::cout << library_sym << std::endl;
    #endif

    // first, open the library
    library_handle = dlopen(library_name.c_str(), RTLD_LAZY);
    if (!library_handle)
        return 1;
    // now, read the symbols from library_sym and load stuff
    std::ifstream f(library_sym);
    std::string line;
    // -------- LOAD --------
    std::getline(f, line);
    #if DEBUG
        std::cout << line << std::endl;
    #endif
    rmi_load = reinterpret_cast<load_type>(dlsym(library_handle, line.c_str()));
    // -------- LOOKUP --------
    std::getline(f, line);
    #if DEBUG
        std::cout << line << std::endl;
    #endif
    rmi_lookup = reinterpret_cast<lookup_type>(dlsym(library_handle, line.c_str()));
    // -------- CLEANUP --------
    std::getline(f, line);
    #if DEBUG
        std::cout << line << std::endl;
    #endif
    rmi_cleanup = reinterpret_cast<cleanup_type>(dlsym(library_handle, line.c_str()));
    f.close();
    if (!rmi_load || !rmi_lookup || !rmi_cleanup) 
        return 1;
    return 0;
}

void cleanup_library() {
    dlclose(library_handle);
}

int main(int argc, char** argv) {
    if (argc == 1) {
        std::cout << "*panic* AAAA! *commits sudoku*" << std::endl;
        exit(1);
    }
    const char* path_to_library = argv[1];
    if(load_library(path_to_library)) {
        std::cout << "*panic* something went wrong (and it's not me)" << std::endl;
        return 1;
    }
    cleanup_library();
    return 0;
}
