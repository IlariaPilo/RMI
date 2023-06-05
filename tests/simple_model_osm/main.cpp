#include <vector>
#include <iostream>
#include <fstream>
#include "rmi.h"

// these global will be in the Reference object - FIXME
std::vector<uint64_t> keyv;
uint64_t nkeyv;

uint64_t lookup(uint64_t key) {
    // suppose index has been already loaded with rmi::load("rmi_data")
    size_t err;
    uint64_t guess_key, guess_pos;
    uint64_t l, r;
    // call the lookup function of the index
    guess_pos = rmi::lookup(key, &err);
    // set up l and r for the bounded binary search
    l = std::max(int64_t(0), static_cast<int64_t>(guess_pos-err));
    r = std::min(static_cast<int64_t>(guess_pos+err), static_cast<int64_t>(nkeyv-1));
    if (key == 33246697004540789) {
      std::cout << "First guess: " << guess_pos << std::endl;
      std::cout << "Error: " << err << std::endl;
      std::cout << "------ Binary search ------" << std::endl;
      std::cout << "l: " << l << std::endl;
      std::cout << "r: " << r << std::endl << std::endl;
    }
    // check in the keyv array
    while (l <= r) {
        guess_key = keyv[guess_pos];
        // if it's the same, done
        if (guess_key == key)
            return guess_pos;
        // else, do binary search
        if (guess_key < key) {
            l = guess_pos + 1;
        } else {
            r = guess_pos - 1;
        }
        // update guess_pos
        guess_pos = l + (r-l)/2;

        if (key == 33246697004540789) {
          std::cout << "Guessed key: " << guess_key << std::endl;
          std::cout << "------ Binary search ------" << std::endl;
          std::cout << "Next guess: " << guess_pos << std::endl;
          std::cout << "l: " << l << std::endl;
          std::cout << "r: " << r << std::endl << std::endl;
        }
    }
    return -1;
}

int main() {
  // load the keyv
  std::ifstream in("../osm_cellids_200M_uint64",
                   std::ios::binary);
  
  // Read nkeyv.
  in.read(reinterpret_cast<char*>(&nkeyv), sizeof(uint64_t));
  keyv.resize(nkeyv);
  // Read values.
  in.read(reinterpret_cast<char*>(keyv.data()), nkeyv*sizeof(uint64_t));
  in.close();

  std::cout << "Data loaded." << std::endl;

  std::cout << "RMI status: " << rmi::load("rmi_data") << std::endl;
  
  for (uint64_t key_index = 0; key_index < nkeyv; key_index++) {
    uint64_t key = keyv[key_index];
    uint64_t true_index = (uint64_t)
      std::distance(keyv.begin(), std::lower_bound(keyv.begin(),
                                                   keyv.end(),
                                                   key));
    uint64_t pos = lookup(key);
    if (pos != key_index) {
      std::cout << "*panic* I don't want to die! *dies* (key " << key << ", returned: " << pos << ", true index: " << true_index << ")" << std::endl;
      exit(-1);
    }
  }
  
  rmi::cleanup();
  std::cout << "Everything is fine!" << std::endl;
  exit(0);
}
