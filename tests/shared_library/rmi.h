#include <cstddef>
#include <cstdint>
namespace rmi {
    bool load(char const* dataPath);
    void cleanup();
    //const size_t RMI_SIZE = 6291472;
    //const uint64_t BUILD_TIME_NS = 69692346317;
    const char NAME[] = "rmi";
    uint64_t lookup(uint64_t key, size_t* err);
}
